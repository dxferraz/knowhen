import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/share/presentation/widgets/share_card.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_end_section.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_shell.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

/// O cartão final dentro da casca de verdade, num celular de 360x640, com a data de hoje fixa para os goldens não
/// mudarem de um dia para o outro.
final _birth = DateTime(1991, 3, 14);
final _today = DateTime(2026, 11, 20, 12);

ShareCardContent _content({String? curiosity = 'Nasce o Mercosul. Brasil, Argentina, Paraguai e Uruguai assinam o Tratado de Assunção'}) {
  final data = ShareCardData(birthDate: _birth, now: _today, moonPhase: getMoonPhase(_birth), curiosity: curiosity);
  return ShareCardContent.build(l10n, ShareSection.summary, data, hideFullDate: false);
}

Future<void> _pumpEnd(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  Widget? endSlot,
  VoidCallback? onShare,
  VoidCallback? onChooseAnotherDate,
}) async {
  await initializeDateFormatting('pt');
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    TestDependencies().wrap(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark ? darkTheme : lightTheme,
        themeAnimationDuration: Duration.zero,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: app!,
        ),
        home: SummaryShell(
          birthDate: _birth,
          cards: [
            (
              analyticsName: 'summary_end',
              section: SummaryEndSection(birthDate: _birth, content: _content(), onShare: onShare ?? () {}),
              share: null,
            ),
          ],
          initialPage: 0,
          menu: const SizedBox(width: 48, height: 48),
          onClose: () {},
          onShare: (_) {},
          onChooseAnotherDate: onChooseAnotherDate ?? () {},
          endSlot: endSlot,
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

  /// Do tamanho do anúncio nativo real (100 dp), para o layout contar com o espaço dele.
  const adSlot = SizedBox(height: 100, child: Placeholder());

  group('layout na casca, 360x640', () {
    for (final scale in [1.0, 2.0]) {
      for (final brightness in Brightness.values) {
        for (final withAd in [false, true]) {
          testWidgets(
            '${(scale * 100).round()}% de fonte, tema ${brightness.name}, ${withAd ? 'com' : 'sem'} anúncio: sem overflow e as ações alcançáveis',
            (tester) async {
              await _pumpEnd(tester, brightness: brightness, scale: scale, endSlot: withAd ? adSlot : null);

              expect(tester.takeException(), isNull);
              // A ação do cartão pode ficar abaixo da dobra a 200%, desde que a rolagem a alcance; o botão do rodapé é fixo.
              await tester.scrollUntilVisible(find.text(l10n.endShare), 100, scrollable: find.byType(Scrollable).last);
              const screen = Rect.fromLTWH(0, 0, 360, 640);
              for (final label in [l10n.endShare, l10n.chooseAnotherDate]) {
                final rect = tester.getRect(find.text(label));
                expect(screen.contains(rect.topLeft) && screen.contains(rect.bottomRight), isTrue, reason: '$label em $rect');
              }
            },
          );
        }
      }
    }
  });

  group('comportamento', () {
    testWidgets('a 100% de fonte "Compartilhar meu resumo" está na tela sem rolar, mesmo com o anúncio abaixo', (tester) async {
      await _pumpEnd(tester, endSlot: adSlot);

      final rect = tester.getRect(find.text(l10n.endShare));
      expect(const Rect.fromLTWH(0, 0, 360, 640).contains(rect.bottomRight), isTrue, reason: '$rect');
      expect(rect.bottom, lessThan(tester.getRect(find.byType(Placeholder)).top));
    });

    testWidgets('mostra o cartão compartilhável real, com a lua na fase do nascimento', (tester) async {
      await _pumpEnd(tester);

      expect(find.byType(ShareCard), findsOneWidget);
      expect(find.descendant(of: find.byType(ShareCard), matching: find.byType(KnMoon)), findsOneWidget);
      expect(find.text(l10n.endEyebrow.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.endTitle('14 de março de 1991')), findsOneWidget);
    });

    testWidgets('a prévia é 9:16', (tester) async {
      await _pumpEnd(tester);

      final size = tester.getSize(find.byType(ShareCard));
      expect(size.width / size.height, closeTo(9 / 16, 0.001));
    });

    testWidgets('"Compartilhar meu resumo" e "Escolher outra data" chamam os callbacks', (tester) async {
      var shared = 0;
      var chose = 0;
      await _pumpEnd(tester, onShare: () => shared++, onChooseAnotherDate: () => chose++);

      await tester.tap(find.text(l10n.endShare));
      await tester.tap(find.text(l10n.chooseAnotherDate));

      expect((shared, chose), (1, 1));
    });

    testWidgets('o leitor de tela encontra a prévia como uma imagem descrita e o botão de compartilhar', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpEnd(tester);

      final preview = tester.getSemantics(find.bySemanticsLabel(RegExp('^${l10n.endPreviewLabel}')));
      expect(preview.label, _previewLabel());
      expect(preview.flagsCollection.isImage, isTrue);
      final share = tester.getSemantics(find.text(l10n.endShare));
      expect(share.flagsCollection.isButton, isTrue);
      expect(share.flagsCollection.isEnabled, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('a prévia fica noturna também no tema claro, igual à imagem que sai', (tester) async {
      await _pumpEnd(tester, brightness: Brightness.light);

      final background = tester
          .widgetList<DecoratedBox>(find.descendant(of: find.byType(ShareCard), matching: find.byType(DecoratedBox)))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.gradient)
          .whereType<LinearGradient>()
          .first;
      expect(background.colors.first, const Color(0xFF1C2154));
    });
  });

  group('goldens', () {
    // Para atualizar depois de uma mudança intencional: `flutter test test/features/summary --update-goldens`.
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.dark ? 'escuro' : 'claro';
      testWidgets('cartão final com anúncio, tema $theme', (tester) async {
        await _pumpEnd(tester, brightness: brightness, endSlot: adSlot);

        await expectLater(find.byType(SummaryShell), matchesGoldenFile('goldens/summary_end_$theme.png'));
      });
    }

    testWidgets('a imagem do cartão compartilhável, em tamanho real (a mesma nos dois temas)', (tester) async {
      await initializeDateFormatting('pt');
      tester.view
        ..physicalSize = ShareCard.logicalSize
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: lightTheme,
          home: Center(child: ShareCard(content: _content())),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(find.byType(ShareCard), matchesGoldenFile('goldens/share_card_summary.png'));
    });
  });
}

String _previewLabel() {
  final content = _content();
  return [l10n.endPreviewLabel, content.highlight, ...content.details].join('. ');
}
