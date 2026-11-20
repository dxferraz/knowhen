// Capturas do estado atual (main) para a auditoria de UX/UI — DXF-9.
//
// flutter test test/design/audit_capture.dart --update-goldens
//
// OnboardingPage e SummaryPage não podem ser montadas direto no teste
// (Firebase Analytics, Firestore e AdMob no initState). As "shells" abaixo
// reproduzem a mesma árvore de layout das páginas reais com as seções reais.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/core/theme/widgets/app_logo.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
import 'package:knowhen/core/theme/widgets/custom_icon_button.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_1.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_2.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_3.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'support.dart';

final DateTime birth = DateTime(1991, 3, 14);
const String fact =
    'Em 26 de março de 1991, Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção. '
    'O acordo criou o Mercado Comum do Sul, o Mercosul. '
    'Até hoje o bloco reúne os quatro países fundadores';

Widget app(Widget home, {required bool dark, double textScale = 1.0}) => ChangeNotifierProvider(
  create: (_) => ThemeProvider(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  ),
);

/// Mesma árvore de OnboardingPage.build, sem os eventos de analytics.
class OnboardingShell extends StatefulWidget {
  final int page;
  const OnboardingShell({super.key, required this.page});

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  late final PageController _controller = PageController(initialPage: widget.page);

  @override
  Widget build(BuildContext context) {
    final isLastPage = widget.page == 2;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const AppLogo(), actions: const [ThemeButton()]),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          children: const [OnboardingStep1(), OnboardingStep2(), OnboardingStep3()],
        ),
      ),
      bottomSheet: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isLastPage
                ? Container(width: 85)
                : CustomButton(
                    onPressed: () {},
                    backgroundColor: Colors.transparent,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    text: 'Pular',
                  ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                dotHeight: 14,
                dotWidth: 14,
                dotColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                activeDotColor: isLastPage
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            if (isLastPage)
              CustomButton(
                onPressed: () {},
                text: 'Começar',
                backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            else
              CustomButton(onPressed: () {}, text: 'Próximo', backgroundColor: Theme.of(context).colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}

/// Mesma árvore de SummaryPage.build no estado SummaryLoaded.
class SummaryShell extends StatefulWidget {
  final int page;
  final bool adult;
  const SummaryShell({super.key, required this.page, this.adult = true});

  @override
  State<SummaryShell> createState() => _SummaryShellState();
}

class _SummaryShellState extends State<SummaryShell> {
  late final PageController _controller = PageController(initialPage: widget.page);

  @override
  Widget build(BuildContext context) {
    final sections = [
      YearsOfLifeSection(birthDate: birth, birthTime: const TimeOfDay(hour: 7, minute: 32)),
      widget.adult ? ConceptionSection(birthDate: birth) : Container(),
      MoonPhaseSection(moonPhase: getMoonPhase(birth)),
      const BrazilCuriositySection(imageUrl: '', curiosity: fact),
    ];
    return Scaffold(
      appBar: AppBar(
        title: PrimaryH4(
          'Resumo de 14/03/1991',
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        centerTitle: true,
        actions: const [ThemeButton()],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          PageView(controller: _controller, scrollDirection: Axis.vertical, children: sections),
          Positioned(
            bottom: 50,
            right: MediaQuery.of(context).size.width / 2 - 25,
            child: CustomIconButton(
              icon: Icons.arrow_downward,
              iconColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {},
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 100,
            right: 10,
            child: SmoothPageIndicator(
              controller: _controller,
              axisDirection: Axis.vertical,
              count: sections.length,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                dotColor: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                activeDotColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de carregamento atual da SummaryPage.
Widget summaryLoading() => Builder(
  builder: (context) => Scaffold(
    appBar: AppBar(
      title: PrimaryH4('Resumo de 14/03/1991', color: Theme.of(context).colorScheme.onSurface),
      actions: const [ThemeButton()],
    ),
    body: Center(child: CircularProgressIndicator(value: 0.7, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  ),
);

/// Estado de erro atual: `Text(state.message)` com o `e.toString()` cru.
Widget summaryError() => Builder(
  builder: (context) => Scaffold(
    appBar: AppBar(
      title: PrimaryH4('Resumo de 14/03/1991', color: Theme.of(context).colorScheme.onSurface),
      actions: const [ThemeButton()],
    ),
    body: const Center(
      child: Text('[firebase_storage/unknown] An unknown error occurred, please check the server response.'),
    ),
  ),
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadCurrentAppFonts();
  });

  for (final dark in [false, true]) {
    final t = dark ? 'dark' : 'light';
    for (final page in [0, 1, 2]) {
      testWidgets('onboarding${page + 1} $t', (tester) async {
        await capture(tester, app(OnboardingShell(page: page), dark: dark), 'current/onboarding${page + 1}_$t');
      });
    }
    testWidgets('birthdate $t', (tester) async {
      await capture(tester, app(const BirthdatePage(), dark: dark), 'current/birthdate_$t');
    });
    for (final page in [0, 1, 2, 3]) {
      testWidgets('summary$page $t', (tester) async {
        await capture(tester, app(SummaryShell(page: page), dark: dark), 'current/summary${page + 1}_$t');
      });
    }
  }

  testWidgets('birthdate selected + time picker', (tester) async {
    await capture(
      tester,
      app(const BirthdatePage(), dark: false),
      'current/birthdate_selected_light',
      interact: (tester) async {
        await tester.tap(find.text('2001'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('mar.').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('14').first);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('time picker', (tester) async {
    await capture(
      tester,
      app(const BirthdatePage(), dark: false),
      'current/timepicker_light',
      interact: (tester) async {
        await tester.tap(find.text('2001'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('mar.').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('14').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('summary minor blank page', (tester) async {
    await capture(tester, app(const SummaryShell(page: 1, adult: false), dark: false), 'current/summary2_minor_light');
  });

  testWidgets('summary loading', (tester) async {
    await capture(tester, app(summaryLoading(), dark: false), 'current/summary_loading_light');
  });

  testWidgets('summary error', (tester) async {
    await capture(tester, app(summaryError(), dark: false), 'current/summary_error_light');
  });

  // Acessibilidade: fonte do sistema em 130% (comum em Android de entrada).
  for (final page in [0, 2, 3]) {
    testWidgets('summary$page textScale 1.3', (tester) async {
      await capture(
        tester,
        app(SummaryShell(page: page), dark: false, textScale: 1.3),
        'current/summary${page + 1}_scale130_light',
      );
    });
  }
  testWidgets('onboarding1 textScale 1.3', (tester) async {
    await capture(
      tester,
      app(const OnboardingShell(page: 1), dark: false, textScale: 1.3),
      'current/onboarding2_scale130_light',
    );
  });
  testWidgets('birthdate small screen', (tester) async {
    await capture(
      tester,
      app(const BirthdatePage(), dark: false),
      'current/birthdate_small_light',
      size: const Size(360, 640),
    );
  });
  testWidgets('summary small screen', (tester) async {
    await capture(
      tester,
      app(const SummaryShell(page: 0), dark: false),
      'current/summary1_small_light',
      size: const Size(360, 640),
    );
  });
}
