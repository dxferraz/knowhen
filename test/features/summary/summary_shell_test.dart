import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_story_progress.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_shell.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

final _birthDate = DateTime(1991, 3, 14);

/// Três cartões simples: a casca é testada sem depender do conteúdo de cada seção.
List<SummaryCard> _cards({int count = 3, ShareSection? lastShare}) => [
  for (var i = 0; i < count; i++)
    (
      analyticsName: 'card_$i',
      section: Center(child: Text('Conteúdo $i')),
      share: i == count - 1 ? lastShare : (i.isEven ? ShareSection.moonPhase : null),
    ),
];

class _Harness {
  final viewed = <int>[];
  final shared = <ShareSection>[];
  int closed = 0;
  int otherDate = 0;
}

Future<_Harness> _pumpShell(
  WidgetTester tester, {
  List<SummaryCard>? cards,
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool disableAnimations = false,
  int initialPage = 0,
  Size size = const Size(360, 640),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final harness = _Harness();

  await tester.pumpWidget(
    TestDependencies().wrap(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark ? darkTheme : lightTheme,
        themeAnimationDuration: Duration.zero,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: disableAnimations),
          child: app!,
        ),
        home: SummaryShell(
          birthDate: _birthDate,
          cards: cards ?? _cards(),
          initialPage: initialPage,
          menu: const SizedBox(key: Key('menu'), width: 48, height: 48),
          onClose: () => harness.closed++,
          onShare: harness.shared.add,
          onChooseAnotherDate: () => harness.otherDate++,
          onPageViewed: harness.viewed.add,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

int _currentCard(WidgetTester tester) => tester.widget<KnStoryProgress>(find.byType(KnStoryProgress)).current;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  group('navegação', () {
    testWidgets('abre no primeiro cartão, com a data resumida no topo e o progresso em segmentos', (tester) async {
      final harness = await _pumpShell(tester);

      expect(find.text('Conteúdo 0'), findsOneWidget);
      expect(find.text(DateText.compact(_birthDate)), findsOneWidget);
      final progress = tester.widget<KnStoryProgress>(find.byType(KnStoryProgress));
      expect((progress.count, progress.current), (3, 0));
      expect(harness.viewed, [0]);
    });

    testWidgets('"Próximo" avança um cartão por vez e registra cada um', (tester) async {
      final harness = await _pumpShell(tester);

      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      expect(find.text('Conteúdo 1'), findsOneWidget);
      expect(_currentCard(tester), 1);
      expect(harness.viewed, [0, 1]);
    });

    testWidgets('toque na metade direita avança e na esquerda volta', (tester) async {
      await _pumpShell(tester);
      final body = tester.getRect(find.text('Conteúdo 0'));

      await tester.tapAt(Offset(body.center.dx + 120, body.center.dy));
      await tester.pumpAndSettle();
      expect(_currentCard(tester), 1);

      await tester.tapAt(Offset(body.center.dx - 120, body.center.dy));
      await tester.pumpAndSettle();
      expect(_currentCard(tester), 0);
    });

    testWidgets('toque na metade esquerda do primeiro cartão não faz nada', (tester) async {
      final harness = await _pumpShell(tester);
      final body = tester.getRect(find.text('Conteúdo 0'));

      await tester.tapAt(Offset(body.center.dx - 120, body.center.dy));
      await tester.pumpAndSettle();

      expect(_currentCard(tester), 0);
      expect(harness.viewed, [0]);
    });

    testWidgets('swipe troca de cartão', (tester) async {
      await _pumpShell(tester);

      await tester.fling(find.text('Conteúdo 0'), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Conteúdo 1'), findsOneWidget);
      expect(_currentCard(tester), 1);
    });

    testWidgets('initialPage abre direto no cartão pedido (toque na notificação)', (tester) async {
      final harness = await _pumpShell(tester, initialPage: 1);

      expect(find.text('Conteúdo 1'), findsOneWidget);
      expect(_currentCard(tester), 1);
      expect(harness.viewed, [1]);
    });

    testWidgets('com movimento reduzido a troca é imediata, sem animação', (tester) async {
      await _pumpShell(tester, disableAnimations: true);

      await tester.tap(find.text(l10n.next));
      await tester.pump();

      // Um único frame já basta: a página chegou ao cartão 1 sem passar pelo deslize.
      expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1.0);
      expect(find.text('Conteúdo 1'), findsOneWidget);
    });
  });

  group('rodapé', () {
    testWidgets('só oferece compartilhar nos cartões que têm o que compartilhar', (tester) async {
      final harness = await _pumpShell(tester);
      final share = find.byTooltip(l10n.summaryShareCard);

      expect(share, findsOneWidget);
      await tester.tap(share);
      expect(harness.shared, [ShareSection.moonPhase]);

      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();
      expect(share, findsNothing);
    });

    testWidgets('no último cartão o botão leva a outra data, em vez de um "Próximo" sem destino', (tester) async {
      final harness = await _pumpShell(tester, initialPage: 2);

      expect(find.text(l10n.next), findsNothing);
      await tester.tap(find.text(l10n.chooseAnotherDate));
      expect(harness.otherDate, 1);
    });

    testWidgets('fechar chama onClose', (tester) async {
      final harness = await _pumpShell(tester);

      await tester.tap(find.byTooltip(l10n.summaryClose));

      expect(harness.closed, 1);
    });

    testWidgets('com um cartão só, abre direto no botão final', (tester) async {
      await _pumpShell(tester, cards: _cards(count: 1));

      expect(find.text(l10n.chooseAnotherDate), findsOneWidget);
      expect(find.text(l10n.next), findsNothing);
    });
  });

  group('acessibilidade', () {
    testWidgets('o progresso anuncia "Cartão N de M" e muda a cada cartão', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpShell(tester);
      expect(find.bySemanticsLabel(l10n.summaryProgress(1, 3)), findsOneWidget);

      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(l10n.summaryProgress(2, 3)), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('os botões do rodapé e do topo têm rótulo e são botões', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpShell(tester);

      for (final label in [l10n.summaryClose, l10n.summaryShareCard]) {
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        expect(node.flagsCollection.isButton, isTrue, reason: label);
      }
      expect(tester.getSemantics(find.widgetWithText(KnButton, l10n.next)).flagsCollection.isButton, isTrue);
      semantics.dispose();
    });

    testWidgets('cada botão tem pelo menos 48 dp de área de toque', (tester) async {
      await _pumpShell(tester);

      for (final finder in [find.byTooltip(l10n.summaryClose), find.byTooltip(l10n.summaryShareCard), find.byType(KnButton)]) {
        final size = tester.getSize(finder);
        expect(size.height, greaterThanOrEqualTo(KnSize.touchTarget), reason: '$finder');
        expect(size.width, greaterThanOrEqualTo(KnSize.touchTarget), reason: '$finder');
      }
    });
  });

  group('layout', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        final name = brightness == Brightness.dark ? 'escuro' : 'claro';
        testWidgets('360x640 a ${(scale * 100).round()}% de fonte, tema $name: sem overflow e botões na tela', (tester) async {
          await _pumpShell(tester, brightness: brightness, scale: scale);
          const screen = Size(360, 640);

          for (var i = 0; i < 3; i++) {
            expect(tester.takeException(), isNull, reason: 'cartão $i');
            final bottomButton = tester.getRect(find.byType(KnButton));
            expect(bottomButton.bottom, lessThanOrEqualTo(screen.height));
            expect(bottomButton.left, greaterThanOrEqualTo(0));
            expect(bottomButton.right, lessThanOrEqualTo(screen.width));
            final bar = tester.getRect(find.byType(KnTopBar));
            expect(bar.left, greaterThanOrEqualTo(0));
            expect(bar.right, lessThanOrEqualTo(screen.width));
            if (i < 2) {
              await tester.tap(find.byType(KnButton));
              await tester.pumpAndSettle();
            }
          }
        });
      }
    }

    testWidgets('a data do topo encolhe em vez de estourar a 200% de fonte', (tester) async {
      await _pumpShell(tester, scale: 2);

      expect(tester.takeException(), isNull);
      expect(find.text(DateText.compact(_birthDate)), findsOneWidget);
    });
  });

  group('goldens', () {
    // Imagens geradas no Linux (o mesmo ambiente do CI) com as fontes empacotadas. Para regenerar depois de
    // uma mudança intencional: `flutter test test/features/summary --update-goldens`.
    for (final brightness in Brightness.values) {
      final name = brightness == Brightness.dark ? 'escuro' : 'claro';
      testWidgets('casca com o primeiro cartão, tema $name', (tester) async {
        await _pumpShell(tester, brightness: brightness);

        expect(tester.takeException(), isNull);
        await expectLater(find.byType(SummaryShell), matchesGoldenFile('goldens/summary_shell_$name.png'));
      });
    }
  });
}
