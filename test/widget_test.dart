import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App builds and pumps successfully', (WidgetTester tester) async {
    // Duas condições para este teste rodar sem infraestrutura:
    // 1. `MyApp` consome o `ThemeProvider` — o teste fornece o mesmo escopo
    //    que `main()` monta em produção;
    // 2. `showOnboarding: false` porque o onboarding registra evento de
    //    analytics já no `initState`, o que exige o Firebase inicializado.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(showOnboarding: false),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
