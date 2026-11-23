import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_shell.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

/// Os quatro cartões do resumo dentro da casca de verdade, num celular de 360x640, com a data de hoje fixa para os
/// goldens não mudarem de um dia para o outro.
final _birth = DateTime(1991, 3, 14);
final _today = DateTime(2026, 11, 20, 12);

const _fact =
    'Nasce o Mercosul. Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção, que criou o Mercado Comum do Sul. Até hoje o bloco reúne os quatro países.';

final _pixel = MemoryImage(
  base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='),
);

typedef _Card = ({String name, Widget section});

List<_Card> _cards({bool failedFact = false}) => [
  (name: 'tempo_de_vida', section: YearsOfLifeSection(birthDate: _birth, birthTime: null, now: _today)),
  (name: 'concepcao', section: ConceptionSection(birthDate: _birth)),
  (name: 'lua', section: MoonPhaseSection(moonPhase: getMoonPhase(_birth), birthDate: _birth)),
  (
    name: 'fato',
    section: BrazilCuriositySection(
      birthDate: _birth,
      imageUrl: failedFact ? '' : 'https://example.com/fato.png',
      curiosity: failedFact ? null : _fact,
      loadFailed: failedFact,
      onRetry: () {},
      onSeeReady: () {},
      imageProviderFor: (_) => _pixel,
    ),
  ),
];

Future<void> _pumpCard(WidgetTester tester, int index, {Brightness brightness = Brightness.light, double scale = 1, bool failedFact = false}) async {
  await initializeDateFormatting('pt');
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final cards = _cards(failedFact: failedFact);

  await tester.pumpWidget(
    TestDependencies().wrap(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark ? darkTheme : lightTheme,
        themeAnimationDuration: Duration.zero,
        builder: (context, app) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: app!),
        home: SummaryShell(
          birthDate: _birth,
          cards: [for (final c in cards) (analyticsName: c.name, section: c.section, share: ShareSection.moonPhase)],
          initialPage: index,
          menu: const SizedBox(width: 48, height: 48),
          onClose: () {},
          onShare: (_) {},
          onChooseAnotherDate: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  const names = ['tempo_de_vida', 'concepcao', 'lua', 'fato'];

  group('layout na casca, 360x640', () {
    for (var i = 0; i < names.length; i++) {
      for (final scale in [1.0, 2.0]) {
        for (final brightness in Brightness.values) {
          testWidgets('${names[i]}, ${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow e o botão do rodapé na tela', (tester) async {
            await _pumpCard(tester, i, brightness: brightness, scale: scale);

            expect(tester.takeException(), isNull);
            // No último cartão o botão leva a outra data, em vez de "Próximo".
            final next = tester.getRect(find.text(i == names.length - 1 ? l10n.chooseAnotherDate : l10n.next));
            expect((Offset.zero & const Size(360, 640)).contains(next.topLeft) && (Offset.zero & const Size(360, 640)).contains(next.bottomRight), isTrue, reason: 'Próximo em $next');
          });
        }
      }
    }

    for (final scale in [1.0, 2.0]) {
      testWidgets('falha parcial no fato, ${(scale * 100).round()}% de fonte: sem overflow e botões alcançáveis', (tester) async {
        await _pumpCard(tester, 3, scale: scale, failedFact: true);

        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text(l10n.factSeeWhatIsReady), 100, scrollable: find.byType(Scrollable).last);
        expect(find.text(l10n.factSeeWhatIsReady), findsOneWidget);
      });
    }
  });

  group('goldens', () {
    // Para atualizar depois de uma mudança intencional: `flutter test test/features/summary --update-goldens`.
    for (var i = 0; i < names.length; i++) {
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.dark ? 'escuro' : 'claro';
        testWidgets('cartão ${names[i]}, tema $theme', (tester) async {
          await _pumpCard(tester, i, brightness: brightness);

          await expectLater(find.byType(SummaryShell), matchesGoldenFile('goldens/summary_card_${names[i]}_$theme.png'));
        });
      }
    }

    testWidgets('fato com falha parcial, tema claro', (tester) async {
      await _pumpCard(tester, 3, failedFact: true);

      await expectLater(find.byType(SummaryShell), matchesGoldenFile('goldens/summary_card_fato_falha_claro.png'));
    });
  });
}
