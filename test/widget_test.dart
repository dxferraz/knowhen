import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds and shows the birthdate page when onboarding was already seen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(showOnboarding: false),
      ),
    );
    await tester.pump();

    expect(find.byType(BirthdatePage), findsOneWidget);
    expect(find.text('Para começar selecione a sua data de nascimento:'), findsOneWidget);
  });
}
