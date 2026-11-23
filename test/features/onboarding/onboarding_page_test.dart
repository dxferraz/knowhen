import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme_provider.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

/// Onboarding num celular de 360x640 com o tema do app, igual ao que roda em produção. Segue o
/// [ThemeProvider] para o botão de tema valer de verdade.
Future<void> _pumpPhone(
  WidgetTester tester,
  TestDependencies deps, {
  Brightness brightness = Brightness.light,
  double scale = 1,
}) async {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    deps.wrap(
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode == ThemeMode.system
              ? (brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light)
              : themeProvider.themeMode,
          themeAnimationDuration: Duration.zero,
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: app!,
          ),
          home: const OnboardingPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late TestDependencies deps;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    deps = TestDependencies();
  });

  testWidgets('logs the start of the onboarding and its only step', (
    tester,
  ) async {
    await tester.pumpApp(const OnboardingPage(), deps);

    expect(deps.firebaseAnalytics.names, [
      'onboarding_started',
      'onboarding_step_viewed',
    ]);
    expect(deps.firebaseAnalytics.events.last.parameters, {'step_index': 0});
  });

  testWidgets('shows the title, the intro, the four reveals and a single CTA', (
    tester,
  ) async {
    await tester.pumpApp(const OnboardingPage(), deps);

    expect(find.text(l10n.onboardingTitle), findsOneWidget);
    expect(find.text(l10n.onboardingIntro), findsOneWidget);
    expect(find.text(l10n.onboardingRevealLife), findsOneWidget);
    expect(find.text(l10n.onboardingRevealConception), findsOneWidget);
    expect(find.text(l10n.onboardingRevealMoon), findsOneWidget);
    expect(find.text(l10n.onboardingRevealFact), findsOneWidget);
    expect(find.text(l10n.onboardingTakesLess), findsOneWidget);
    expect(find.widgetWithText(KnButton, l10n.start), findsOneWidget);
    // As promessas de "personalidade" e "insights" e os botões de várias telas saíram.
    expect(find.text(l10n.skip), findsNothing);
    expect(find.text(l10n.next), findsNothing);
  });

  testWidgets(
    '"Começar" saves the flag, logs completion and opens the birthdate page',
    (tester) async {
      await tester.pumpApp(const OnboardingPage(), deps);

      await tester.tap(find.text(l10n.start));
      await tester.pumpAndSettle();

      expect(find.byType(BirthdatePage), findsOneWidget);
      expect(deps.firebaseAnalytics.names, contains('onboarding_completed'));
      expect(
        (await SharedPreferences.getInstance()).getBool('showOnboarding'),
        isFalse,
      );
    },
  );

  testWidgets('does not log onboarding_skipped: there is nothing to skip', (
    tester,
  ) async {
    await tester.pumpApp(const OnboardingPage(), deps);
    await tester.tap(find.text(l10n.start));
    await tester.pumpAndSettle();

    expect(deps.firebaseAnalytics.names, isNot(contains('onboarding_skipped')));
  });

  group('acessibilidade', () {
    testWidgets(
      'título é cabeçalho, o CTA é botão e cada revelação é um único nó',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpApp(const OnboardingPage(), deps);

        final title = tester.getSemantics(find.text(l10n.onboardingTitle));
        expect(title.flagsCollection.isHeader, isTrue);

        final cta = tester.getSemantics(find.byType(KnButton));
        expect(cta.flagsCollection.isButton, isTrue);
        expect(cta.label, l10n.start);

        // O ícone decorativo não vira nó separado do texto da revelação.
        final row = tester.getSemantics(find.text(l10n.onboardingRevealMoon));
        expect(row.label, l10n.onboardingRevealMoon);
        semantics.dispose();
      },
    );

    testWidgets('o botão de tema diz para qual tema vai e tem alvo de 48 dp', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpPhone(tester, deps);

      expect(
        tester.getSize(find.byType(KnIconButton)),
        const Size(KnSize.touchTarget, KnSize.touchTarget),
      );
      expect(
        tester.getSemantics(find.byType(KnIconButton)).label,
        l10n.themeSwitchToDark,
      );

      await tester.tap(find.byType(KnIconButton));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(KnIconButton)).label,
        l10n.themeSwitchToLight,
      );
      expect(deps.firebaseAnalytics.names, contains('theme_changed'));
      semantics.dispose();
    });

    testWidgets('o CTA tem pelo menos 56 dp de altura', (tester) async {
      await _pumpPhone(tester, deps);

      expect(
        tester.getSize(find.byType(KnButton)).height,
        greaterThanOrEqualTo(KnSize.button),
      );
    });
  });

  group('layout', () {
    for (final brightness in Brightness.values) {
      final name = brightness == Brightness.dark ? 'escuro' : 'claro';

      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '360x640 a ${(scale * 100).round()}% de fonte, tema $name: sem overflow e CTA alcançável',
          (tester) async {
            await _pumpPhone(
              tester,
              deps,
              brightness: brightness,
              scale: scale,
            );

            expect(tester.takeException(), isNull);
            final screen =
                tester.view.physicalSize / tester.view.devicePixelRatio;
            final cta = tester.getRect(find.byType(KnButton));
            // O CTA fica fixo no rodapé, sempre dentro da tela.
            expect(cta.bottom, lessThanOrEqualTo(screen.height));
            expect(cta.left, greaterThanOrEqualTo(0));
            expect(cta.right, lessThanOrEqualTo(screen.width));

            // O conteúdo rola até o fim: a última revelação pode ser trazida para a tela.
            await tester.ensureVisible(find.text(l10n.onboardingRevealFact));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('goldens', () {
    // Imagens geradas no Linux (o mesmo ambiente do CI) com as fontes empacotadas. Para regenerar depois de
    // uma mudança intencional: `flutter test test/features/onboarding --update-goldens`.
    for (final brightness in Brightness.values) {
      final name = brightness == Brightness.dark ? 'escuro' : 'claro';

      testWidgets('tela única, tema $name', (tester) async {
        await _pumpPhone(tester, deps, brightness: brightness);

        expect(tester.takeException(), isNull);
        expect(
          Theme.of(tester.element(find.byType(OnboardingPage))).brightness,
          brightness,
        );
        await expectLater(
          find.byType(OnboardingPage),
          matchesGoldenFile('goldens/onboarding_$name.png'),
        );
      });
    }
  });
}
