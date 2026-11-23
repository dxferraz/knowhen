import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/components/kn_stat.dart';
import 'package:knowhen/core/theme/components/kn_story_progress.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';

import '../../../helpers/contrast.dart';

final _themes = {Brightness.light: lightTheme, Brightness.dark: darkTheme};

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: _themes[brightness],
    themeAnimationDuration: Duration.zero,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: disableAnimations),
      child: app!,
    ),
    home: Scaffold(body: child),
  );
}

void _phone(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('KnButton', () {
    testWidgets('toca e expõe semântica de botão habilitado', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _host(
          Center(
            child: KnButton(label: 'Descobrir', onPressed: () => taps++),
          ),
        ),
      );

      await tester.tap(find.text('Descobrir'));
      expect(taps, 1);

      final node = tester.getSemantics(find.byType(KnButton));
      expect(node.label, 'Descobrir');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);
      semantics.dispose();
    });

    testWidgets('sem onPressed fica desabilitado', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Center(child: KnButton(label: 'Descobrir', onPressed: null))));

      final node = tester.getSemantics(find.byType(KnButton));
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();
    });

    testWidgets('altura de 56 dp, ocupando a largura; ou só o conteúdo com expand: false', (tester) async {
      await tester.pumpWidget(
        _host(
          Center(
            child: SizedBox(
              width: 300,
              child: KnButton(label: 'Ok', onPressed: () {}),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(KnButton)), const Size(300, KnSize.button));

      await tester.pumpWidget(
        _host(
          Center(
            child: KnButton(label: 'Ok', expand: false, onPressed: () {}),
          ),
        ),
      );
      final size = tester.getSize(find.byType(KnButton));
      expect(size.height, KnSize.button);
      expect(size.width, lessThan(300));
    });

    testWidgets('cada tipo usa a cor do tema: primário, secundário (com borda) e ghost (sem fundo)', (tester) async {
      for (final brightness in Brightness.values) {
        final c = KnColors.forBrightness(brightness);
        Material materialOf(KnButtonKind kind) =>
            tester.widget<Material>(find.descendant(of: find.byType(KnButton), matching: find.byType(Material)).first);

        await tester.pumpWidget(
          _host(
            KnButton(label: 'x', onPressed: () {}),
            brightness: brightness,
          ),
        );
        expect(materialOf(KnButtonKind.primary).color, c.primary);

        await tester.pumpWidget(
          _host(
            KnButton(label: 'x', kind: KnButtonKind.secondary, onPressed: () {}),
            brightness: brightness,
          ),
        );
        final secondary = materialOf(KnButtonKind.secondary);
        expect(secondary.color, c.surfaceHi);
        expect((secondary.shape! as StadiumBorder).side.color, c.outline);

        await tester.pumpWidget(
          _host(
            KnButton(label: 'x', kind: KnButtonKind.ghost, onPressed: () {}),
            brightness: brightness,
          ),
        );
        expect(materialOf(KnButtonKind.ghost).color, Colors.transparent);
      }
    });

    testWidgets('mostra o ícone à direita do rótulo', (tester) async {
      await tester.pumpWidget(
        _host(
          Center(
            child: KnButton(label: 'Próximo', icon: Icons.arrow_forward, onPressed: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(
        tester.getTopLeft(find.byIcon(Icons.arrow_forward)).dx,
        greaterThan(tester.getTopRight(find.text('Próximo')).dx),
      );
    });
  });

  group('KnIconButton', () {
    testWidgets('área de toque de 48 dp, rótulo na semântica e na dica', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _host(
          Center(
            child: KnIconButton(icon: Icons.close, label: 'Fechar resumo', onPressed: () => taps++),
          ),
        ),
      );

      expect(tester.getSize(find.byType(KnIconButton)), const Size(KnSize.touchTarget, KnSize.touchTarget));
      final node = tester.getSemantics(find.byType(KnIconButton));
      expect(node.label, 'Fechar resumo');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);

      // Toca na borda da área de 48 dp, fora do círculo visível de 40.
      final topLeft = tester.getTopLeft(find.byType(KnIconButton));
      await tester.tapAt(topLeft + const Offset(2, 24));
      expect(taps, 1);

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Fechar resumo');
      semantics.dispose();
    });

    testWidgets('sem onPressed fica desabilitado', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const Center(
            child: KnIconButton(icon: Icons.close, label: 'Fechar resumo', onPressed: null),
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(KnIconButton)).flagsCollection.isEnabled, ui.Tristate.isFalse);
      semantics.dispose();
    });
  });

  group('KnCard', () {
    testWidgets('escuro: só borda; claro: sombra índigo de 6% e blur 24', (tester) async {
      BoxDecoration decorationOf() =>
          tester
                  .widget<Container>(find.descendant(of: find.byType(KnCard), matching: find.byType(Container)))
                  .decoration!
              as BoxDecoration;

      await tester.pumpWidget(_host(const KnCard(child: Text('x')), brightness: Brightness.dark));
      expect(decorationOf().boxShadow, isNull);
      expect(decorationOf().border, isNotNull);

      await tester.pumpWidget(_host(const KnCard(child: Text('x'))));
      await tester.pumpAndSettle();
      final shadow = decorationOf().boxShadow!.single;
      expect(shadow.blurRadius, 24);
      expect(shadow.color.a, closeTo(0.06, 0.005));
      expect(decorationOf().color, KnColors.dawn.surface);
    });

    testWidgets('padding padrão de 24', (tester) async {
      await tester.pumpWidget(
        _host(
          const Align(
            alignment: Alignment.topLeft,
            child: KnCard(child: SizedBox(height: 10)),
          ),
        ),
      );
      expect(tester.getSize(find.byType(KnCard)).height, 10 + 2 * KnSpace.xl + 2 /* bordas */);
    });
  });

  group('KnTopBar', () {
    testWidgets('laterais de 56 dp, centro centralizado, altura mínima de 56', (tester) async {
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.topCenter,
            child: KnTopBar(
              leading: KnIconButton(icon: Icons.close, label: 'Fechar', onPressed: () {}),
              center: const Text('Título'),
              trailing: KnIconButton(icon: Icons.brightness_6, label: 'Tema', onPressed: () {}),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(KnTopBar)).height, KnTopBar.height);
      final screen = tester.getSize(find.byType(Scaffold));
      expect(tester.getCenter(find.text('Título')).dx, closeTo(screen.width / 2, 0.5));
      expect(tester.getTopLeft(find.byType(KnIconButton).first).dx, closeTo(4, 0.5));
    });

    testWidgets('aceita só o centro', (tester) async {
      await tester.pumpWidget(
        _host(
          const Align(
            alignment: Alignment.topCenter,
            child: KnTopBar(center: Text('Só título')),
          ),
        ),
      );
      expect(find.text('Só título'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('KnStoryProgress', () {
    List<double> fills(WidgetTester tester) =>
        tester.widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox)).map((w) => w.widthFactor!).toList();

    testWidgets('anuncia o rótulo recebido e preenche até o cartão atual', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const Padding(
            padding: EdgeInsets.all(24),
            child: KnStoryProgress(count: 5, current: 1, semanticsLabel: 'Cartão 2 de 5'),
          ),
        ),
      );

      expect(tester.getSemantics(find.byType(KnStoryProgress)).label, 'Cartão 2 de 5');
      expect(fills(tester), [1, 1, 0, 0, 0]);
      semantics.dispose();
    });

    testWidgets('ao avançar o segmento novo enche em 250 ms', (tester) async {
      Widget progress(int current) => _host(
        Padding(
          padding: const EdgeInsets.all(24),
          child: KnStoryProgress(count: 3, current: current, semanticsLabel: 'x'),
        ),
      );
      await tester.pumpWidget(progress(0));
      expect(fills(tester), [1, 0, 0]);

      await tester.pumpWidget(progress(1));
      await tester.pump(const Duration(milliseconds: 125));
      final mid = fills(tester)[1];
      expect(mid, inExclusiveRange(0, 1));

      await tester.pump(const Duration(milliseconds: 125));
      expect(fills(tester), [1, 1, 0]);
    });

    testWidgets('com disableAnimations o segmento troca de uma vez', (tester) async {
      Widget progress(int current) => _host(
        Padding(
          padding: const EdgeInsets.all(24),
          child: KnStoryProgress(count: 3, current: current, semanticsLabel: 'x'),
        ),
        disableAnimations: true,
      );
      await tester.pumpWidget(progress(0));
      await tester.pumpWidget(progress(1));
      await tester.pump();
      expect(fills(tester), [1, 1, 0]);
    });

    test('rejeita índice fora do intervalo', () {
      expect(() => KnStoryProgress(count: 3, current: 3, semanticsLabel: 'x'), throwsAssertionError);
    });
  });

  group('KnStat', () {
    testWidgets('lê número e legenda juntos', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const Center(
            child: KnStat(value: '35', label: 'anos'),
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(KnStat)).label, '35 anos');
      semantics.dispose();
    });

    testWidgets('com fonte a 200% o número encolhe em vez de estourar a coluna', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _host(
          const Row(
            children: [
              Expanded(
                child: KnStat(value: '12.784.320', label: 'dias'),
              ),
              Expanded(
                child: KnStat(value: '35', label: 'anos'),
              ),
            ],
          ),
          scale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(KnStat).first).right,
        lessThanOrEqualTo(tester.getRect(find.byType(KnStat).last).left),
      );
    });

    testWidgets('KnEyebrow escreve em caixa alta', (tester) async {
      await tester.pumpWidget(_host(const KnEyebrow('Tempo de vida')));
      expect(find.text('TEMPO DE VIDA'), findsOneWidget);
    });
  });

  group('KnBackground', () {
    testWidgets('estrelas só no tema escuro', (tester) async {
      Iterable<CustomPaint> painters() => tester
          .widgetList<CustomPaint>(find.descendant(of: find.byType(KnBackground), matching: find.byType(CustomPaint)))
          .where((p) => p.painter != null);

      await tester.pumpWidget(_host(const KnBackground(child: SizedBox.expand()), brightness: Brightness.dark));
      expect(painters(), hasLength(1));

      await tester.pumpWidget(_host(const KnBackground(child: SizedBox.expand())));
      await tester.pumpAndSettle();
      expect(painters(), isEmpty);
    });

    testWidgets('gradiente de bgTop a bg do tema', (tester) async {
      await tester.pumpWidget(_host(const KnBackground(child: SizedBox.expand()), brightness: Brightness.dark));
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(KnBackground), matching: find.byType(DecoratedBox)).first,
      );
      final gradient = (box.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.colors, [KnColors.night.bgTop, KnColors.night.bg]);
    });
  });

  group('KnMoon', () {
    /// Fração de pixels claros (a parte iluminada) em cada metade da lua, sem o halo.
    Future<({double left, double right})> litHalves(WidgetTester tester, double phase, {bool southern = false}) async {
      const size = 200.0;
      final recorder = ui.PictureRecorder();
      KnMoonPainter(
        phase: phase,
        moon: const Color(0xFFFFFFFF),
        shadow: const Color(0xFF000000),
        glowAlpha: 0,
        southernHemisphere: southern,
      ).paint(Canvas(recorder), const Size(size, size));

      final bytes = await tester.runAsync(() async {
        final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
        return image.toByteData();
      });
      double lit(int x0, int x1) {
        var on = 0, total = 0;
        for (var y = 0; y < size; y++) {
          for (var x = x0; x < x1; x++) {
            final i = (y * size.toInt() + x) * 4;
            if (bytes!.getUint8(i + 3) == 0) continue; // fora do disco
            total++;
            if (bytes.getUint8(i) > 200) on++;
          }
        }
        return total == 0 ? 0 : on / total;
      }

      return (left: lit(0, size ~/ 2), right: lit(size ~/ 2, size.toInt()));
    }

    testWidgets('nova: nada iluminado', (tester) async {
      final h = await litHalves(tester, 0);
      expect(h.left, lessThan(0.02));
      expect(h.right, lessThan(0.02));
    });

    testWidgets('quarto crescente: só o lado direito', (tester) async {
      final h = await litHalves(tester, 0.25);
      expect(h.right, greaterThan(0.9));
      expect(h.left, lessThan(0.05));
    });

    testWidgets('quarto minguante: só o lado esquerdo', (tester) async {
      final h = await litHalves(tester, 0.75);
      expect(h.left, greaterThan(0.9));
      expect(h.right, lessThan(0.05));
    });

    testWidgets('hemisfério sul: a crescente é iluminada à esquerda e a minguante, à direita', (tester) async {
      final waxing = await litHalves(tester, 0.25, southern: true);
      expect(waxing.left, greaterThan(0.9));
      expect(waxing.right, lessThan(0.05));

      final waning = await litHalves(tester, 0.75, southern: true);
      expect(waning.right, greaterThan(0.9));
      expect(waning.left, lessThan(0.05));
    });

    testWidgets('hemisfério sul: nova e cheia não mudam', (tester) async {
      final full = await litHalves(tester, 0.5, southern: true);
      expect(full.left, greaterThan(0.95));
      expect(full.right, greaterThan(0.95));
      final none = await litHalves(tester, 0, southern: true);
      expect(none.left, lessThan(0.02));
      expect(none.right, lessThan(0.02));
    });

    testWidgets('cheia: os dois lados', (tester) async {
      final h = await litHalves(tester, 0.5);
      expect(h.left, greaterThan(0.95));
      expect(h.right, greaterThan(0.95));
    });

    testWidgets('crescente fina e gibosa: a iluminação cresce com a fase', (tester) async {
      final crescent = await litHalves(tester, 0.1);
      final gibbous = await litHalves(tester, 0.4);
      expect(crescent.right, inExclusiveRange(0.05, 0.6));
      expect(gibbous.right, greaterThan(crescent.right));
      expect(crescent.left, lessThan(0.02));
      expect(gibbous.left, inExclusiveRange(0.6, 0.95));
    });

    testWidgets('fase fora de [0, 1) dá a volta', (tester) async {
      final a = await litHalves(tester, 1.25);
      final b = await litHalves(tester, 0.25);
      expect(a.right, closeTo(b.right, 0.001));
      expect(a.left, closeTo(b.left, 0.001));
      expect(KnMoonPainter.normalize(-0.25), closeTo(0.75, 1e-9));
    });

    testWidgets('é decorativa sem rótulo e vira imagem com rótulo', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Center(child: KnMoon(phase: 0.3))));
      expect(find.bySemanticsLabel('Lua crescente'), findsNothing);

      await tester.pumpWidget(_host(const Center(child: KnMoon(phase: 0.3, semanticsLabel: 'Lua crescente'))));
      expect(find.bySemanticsLabel('Lua crescente'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('respeita o tamanho pedido', (tester) async {
      await tester.pumpWidget(_host(const Center(child: KnMoon(phase: 0.3, size: 96))));
      expect(tester.getSize(find.byType(KnMoon)), const Size.square(96));
    });
  });

  group('contraste dos pares usados pelos componentes (AA)', () {
    for (final c in [KnColors.night, KnColors.dawn]) {
      final name = c.isDark ? 'escuro' : 'claro';
      // O cartão escuro é 85% opaco sobre o fundo; o pior caso é o topo do gradiente.
      final card = c.isDark ? Color.alphaBlend(c.surface.withValues(alpha: 0.85), c.bgTop) : c.surface;

      test('$name: botão primário', () => expect(contrastRatio(c.onPrimary, c.primary), greaterThanOrEqualTo(aaText)));
      test('$name: botão secundário', () => expect(contrastRatio(c.ink, c.surfaceHi), greaterThanOrEqualTo(aaText)));
      test('$name: botão ghost sobre o fundo', () => expect(contrastRatio(c.ink, c.bg), greaterThanOrEqualTo(aaText)));
      test('$name: ícone do KnIconButton', () => expect(contrastRatio(c.ink, c.surfaceHi), greaterThanOrEqualTo(aaUi)));
      test('$name: eyebrow e legenda no cartão', () {
        expect(contrastRatio(c.accentText, card), greaterThanOrEqualTo(aaText));
        expect(contrastRatio(c.inkMuted, card), greaterThanOrEqualTo(aaText));
        expect(contrastRatio(c.ink, card), greaterThanOrEqualTo(aaText));
      });
      test('$name: segmento preenchido contra o vazio', () {
        expect(contrastRatio(c.primary, c.outline), greaterThanOrEqualTo(aaUi));
      });
    }
  });

  group('360x640 a 200% de fonte, sem overflow, nos dois temas', () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, (tester) async {
        _phone(tester);
        await tester.pumpWidget(
          _host(
            brightness: brightness,
            scale: 2,
            KnBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
                  child: Column(
                    children: [
                      KnTopBar(
                        leading: KnIconButton(icon: Icons.close, label: 'Fechar resumo', onPressed: () {}),
                        center: const Text('Knowhen', overflow: TextOverflow.ellipsis),
                        trailing: KnIconButton(icon: Icons.brightness_6, label: 'Mudar o tema', onPressed: () {}),
                      ),
                      const KnStoryProgress(count: 5, current: 2, semanticsLabel: 'Cartão 3 de 5'),
                      const SizedBox(height: KnSpace.xl),
                      const KnCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KnEyebrow('Tempo de vida'),
                            Row(
                              children: [
                                Expanded(
                                  child: KnStat(value: '12.784', label: 'dias'),
                                ),
                                Expanded(
                                  child: KnStat(value: '35', label: 'anos'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const KnMoon(phase: 0.3, size: 160),
                      KnButton(label: 'Compartilhar meu céu de nascimento', icon: Icons.ios_share, onPressed: () {}),
                      KnButton(label: 'Agora não', kind: KnButtonKind.ghost, onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        // Cada alvo interativo mantém no mínimo 48 dp mesmo com fonte grande.
        for (final finder in [find.byType(KnButton), find.byType(KnIconButton)]) {
          for (final element in finder.evaluate()) {
            final size = tester.getSize(find.byWidget(element.widget));
            expect(size.height, greaterThanOrEqualTo(KnSize.touchTarget));
            expect(size.width, greaterThanOrEqualTo(KnSize.touchTarget));
          }
        }
      });
    }
  });
}
