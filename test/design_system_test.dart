import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/showcase/design_system_page.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_1.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_2.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_3.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';

final DateTime birth = DateTime(1991, 3, 14);

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(
      File('lib/core/assets/fonts/$f').readAsBytes().then(
            (b) => ByteData.view(Uint8List.fromList(b).buffer),
          ),
    );
  }
  await loader.load();
}

Widget app(Widget home, {bool dark = true}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Widget onboardingShell(Widget step) => GlassScaffold(
      appBar: const GlassAppBar(
        titleWidget: AppLogo(),
        automaticallyImplyLeading: false,
        bottomDivider: false,
        actions: [ThemeButton()],
      ),
      body: step,
      bottomBar: GlassBottomBar(
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: GlassButton(
                  label: 'Pular',
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.small,
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(width: 40, height: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: GlassButton(
                  label: 'Próximo',
                  size: AppButtonSize.small,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );

Widget summaryShell(Widget section) => GlassScaffold(
      appBar: const GlassAppBar(
        title: 'Resumo de 14/03/1991',
        actions: [ThemeButton()],
      ),
      padBodyForAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: section,
      ),
    );

/// Smoke test de todas as telas do design system, nos dois temas.
///
/// Renderiza cada tela em 390x844 com as fontes reais do app e falha se
/// houver exceção de build/layout (incluindo overflow). Não usa goldens de
/// propósito: imagens de referência ficariam desatualizadas a cada ajuste de
/// token e pesariam ~13 MB no repositório.
void main() {
  setUpAll(() async {
    await loadFont('Inter', [
      'Inter-Regular.ttf',
      'Inter-SemiBold.ttf',
      'Inter-Bold.ttf',
    ]);
    await loadFont('Sora', ['Sora-SemiBold.ttf', 'Sora-Bold.ttf']);
    await loadFont('YatraOne', ['YatraOne-Regular.ttf']);
  });

  final cases = <String, Widget>{
    'onboarding1': onboardingShell(const OnboardingStep1()),
    'onboarding2': onboardingShell(const OnboardingStep2()),
    'onboarding3': onboardingShell(const OnboardingStep3()),
    'birthdate': const BirthdatePage(),
    'summary_years': summaryShell(
      YearsOfLifeSection(
        birthDate: birth,
        birthTime: const TimeOfDay(hour: 7, minute: 32),
      ),
    ),
    'summary_conception': summaryShell(ConceptionSection(birthDate: birth)),
    'summary_moon': summaryShell(MoonPhaseSection(moonPhase: getMoonPhase(birth))),
    'summary_fact': summaryShell(
      const BrazilCuriositySection(
        imageUrl: '',
        curiosity:
            'Em março de 1991 o Brasil assinava o Tratado de Assunção e criava '
            'o Mercosul. O acordo mudou a economia da região por décadas',
      ),
    ),
    'design_system': const DesignSystemPage(),
  };

  for (final entry in cases.entries) {
    for (final dark in [true, false]) {
      testWidgets('${entry.key} ${dark ? 'dark' : 'light'}', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(app(entry.value, dark: dark));
        // As entradas em cascata (`GlassReveal`) precisam de frames reais:
        // um único `pump` longo avança o relógio mas não anima.
        for (int i = 0; i < 48; i++) {
          await tester.pump(const Duration(milliseconds: 25));
        }

        // Falha se qualquer widget estourou o layout ou lançou durante o
        // build/paint — é o contrato mínimo de uma tela do design system.
        expect(tester.takeException(), isNull);
      });
    }
  }
}
