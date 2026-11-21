import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/features/milestones/presentation/widgets/next_milestone_section.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/milestone_fakes.dart';

void main() {
  final birth = DateTime(1990, 5, 15);
  // 5 dias antes dos 10.000 dias de vida (30/09/2017).
  final now = DateTime(2017, 9, 25, 10);

  late FakeMilestoneNotifier notifier;
  late FakeMilestoneAnalytics analytics;
  late LifeProfileService profile;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifier = FakeMilestoneNotifier();
    analytics = FakeMilestoneAnalytics();
    profile = LifeProfileService(
      storage: BirthdateStorage(),
      notifier: notifier,
      analytics: analytics,
      l10n: lookupAppLocalizations(const Locale('pt')),
      clock: () => now,
    );
  });

  Future<void> pumpSection(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: profile,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: NextMilestoneSection(
              birthDate: birth,
              birthTime: null,
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mostra o próximo marco com a contagem regressiva e a data', (
    tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('Próximo marco'), findsOneWidget);
    expect(find.text('10.000 dias de vida'), findsOneWidget);
    expect(find.text('Faltam 5 dias'), findsOneWidget);
    expect(find.text('Em 30/09/2017'), findsOneWidget);
    expect(find.text('Me avise'), findsOneWidget);
    // Só abrir o card não pede permissão.
    expect(notifier.permissionRequests, 0);
  });

  testWidgets(
    '"Me avise" com permissão agenda os lembretes e troca o botão por "desativar"',
    (tester) async {
      await pumpSection(tester);

      await tester.tap(find.text('Me avise'));
      await tester.pumpAndSettle();

      expect(notifier.permissionRequests, 1);
      expect(notifier.scheduled, isNotEmpty);
      expect(find.text('Me avise'), findsNothing);
      expect(find.text('Desativar lembrete'), findsOneWidget);
    },
  );

  testWidgets(
    'recusar a permissão mostra o aviso, mantém o botão e não quebra',
    (tester) async {
      notifier.grantsOnRequest = false;
      await pumpSection(tester);

      await tester.tap(find.text('Me avise'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(notifier.scheduled, isEmpty);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Me avise'), findsOneWidget);
      expect(find.text('Próximo marco'), findsOneWidget);
    },
  );

  testWidgets('falha ao agendar mostra o aviso e o card continua funcionando', (
    tester,
  ) async {
    notifier.permission = true;
    notifier.scheduleError = StateError('sem alarme');
    await pumpSection(tester);

    await tester.tap(find.text('Me avise'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Me avise'), findsOneWidget);
  });
}
