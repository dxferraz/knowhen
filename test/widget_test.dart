import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:knowhen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds and shows the birthdate page when onboarding was already seen', (WidgetTester tester) async {
    await tester.pumpWidget(TestDependencies().wrap(const MyApp(showOnboarding: false)));
    await tester.pump();

    expect(find.byType(BirthdatePage), findsOneWidget);
    expect(find.text(l10n.birthdateTitle), findsOneWidget);
  });

  testWidgets('App starts on the onboarding the first time', (WidgetTester tester) async {
    await tester.pumpWidget(TestDependencies().wrap(const MyApp(showOnboarding: true)));
    await tester.pump();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
