import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:knowhen/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/milestone_fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  final saved = SavedBirthdate(
    DateTime(1990, 5, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
  );
  final profile = LifeProfileService(
    storage: BirthdateStorage(),
    notifier: FakeMilestoneNotifier(),
    analytics: FakeMilestoneAnalytics(),
    l10n: lookupAppLocalizations(const Locale('pt')),
  );

  final deps = TestDependencies();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester, MyApp app) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(deps.analytics)),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: app,
      ),
    );
    await tester.pump();
  }

  Widget stubSummary(SavedBirthdate s, {required bool openMilestone}) =>
      Text('resumo ${s.date.year} ${s.time!.hour}h milestone=$openMilestone');

  testWidgets(
    'com data salva abre direto no resumo, mesmo antes do onboarding ser visto',
    (tester) async {
      await pumpApp(
        tester,
        MyApp(
          showOnboarding: true,
          savedBirthdate: saved,
          summaryBuilder: stubSummary,
        ),
      );

      expect(find.text('resumo 1990 8h milestone=false'), findsOneWidget);
      expect(find.byType(OnboardingPage), findsNothing);
      expect(find.byType(BirthdatePage), findsNothing);
    },
  );

  testWidgets(
    'aberto por uma notificação, o resumo recebe o pedido de abrir no card do marco',
    (tester) async {
      await pumpApp(
        tester,
        MyApp(
          showOnboarding: false,
          savedBirthdate: saved,
          openMilestone: true,
          summaryBuilder: stubSummary,
        ),
      );

      expect(find.text('resumo 1990 8h milestone=true'), findsOneWidget);
    },
  );

  testWidgets('sem data salva o fluxo é o de sempre', (tester) async {
    await pumpApp(tester, const MyApp(showOnboarding: false));
    expect(find.byType(BirthdatePage), findsOneWidget);
  });
}
