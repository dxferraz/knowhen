import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  late TestDependencies deps;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    deps = TestDependencies();
  });

  testWidgets('logs the start of the onboarding and the first step', (tester) async {
    await tester.pumpApp(const OnboardingPage(), deps);

    expect(find.text(l10n.onboarding1Title), findsOneWidget);
    expect(deps.firebaseAnalytics.names, ['onboarding_started', 'onboarding_step_viewed']);
    expect(deps.firebaseAnalytics.events.last.parameters, {'step_index': 0});
  });

  testWidgets('"Próximo" goes to the next step', (tester) async {
    await tester.pumpApp(const OnboardingPage(), deps);

    await tester.tap(find.text(l10n.next));
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboarding2Title), findsOneWidget);
    expect(deps.firebaseAnalytics.events.last.name, 'onboarding_step_viewed');
    expect(deps.firebaseAnalytics.events.last.parameters, {'step_index': 1});
  });

  testWidgets('"Pular" jumps to the last step and logs onboarding_skipped', (tester) async {
    await tester.pumpApp(const OnboardingPage(), deps);

    await tester.tap(find.text(l10n.skip));
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboarding3Title), findsOneWidget);
    expect(find.text(l10n.start), findsOneWidget);
    final skipped = deps.firebaseAnalytics.events.firstWhere((e) => e.name == 'onboarding_skipped');
    expect(skipped.parameters, {'step_index': 0});
  });

  testWidgets('"Começar" saves the flag, logs completion and opens the birthdate page', (tester) async {
    await tester.pumpApp(const OnboardingPage(), deps);
    await tester.tap(find.text(l10n.skip));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.start));
    await tester.pumpAndSettle();

    expect(find.byType(BirthdatePage), findsOneWidget);
    expect(deps.firebaseAnalytics.names, contains('onboarding_completed'));
    expect((await SharedPreferences.getInstance()).getBool('showOnboarding'), isFalse);
  });
}
