import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_entrance.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';

import '../../../helpers/load_app_fonts.dart';

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(360, 440), double scale = 1, bool disableAnimations = false}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: disableAnimations),
        child: app!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

double _opacity(WidgetTester tester, String text) => tester.widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first).opacity;

double _dy(WidgetTester tester, String text) => tester.widget<Transform>(find.ancestor(of: find.text(text), matching: find.byType(Transform)).first).transform.getTranslation().y;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  group('KnEntrance', () {
    testWidgets('entra com fade e 16 dp de deslocamento, em 400 ms', (tester) async {
      await _pump(tester, const Center(child: KnEntrance(child: Text('a'))));

      expect(_opacity(tester, 'a'), 0);
      expect(_dy(tester, 'a'), 16);

      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacity(tester, 'a'), inExclusiveRange(0, 1));
      expect(_dy(tester, 'a'), inExclusiveRange(0, 16));

      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacity(tester, 'a'), 1);
      expect(_dy(tester, 'a'), 0);
    });

    testWidgets('cada elemento começa 60 ms depois do anterior', (tester) async {
      await _pump(
        tester,
        const Column(children: [KnEntrance(child: Text('a')), KnEntrance(order: 1, child: Text('b')), KnEntrance(order: 2, child: Text('c'))]),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(_opacity(tester, 'a'), greaterThan(_opacity(tester, 'b')));
      expect(_opacity(tester, 'b'), greaterThan(_opacity(tester, 'c')));

      await tester.pump(const Duration(milliseconds: 500));
      for (final t in ['a', 'b', 'c']) {
        expect(_opacity(tester, t), 1);
      }
    });

    testWidgets('com movimento reduzido já aparece no lugar, sem animar', (tester) async {
      await _pump(tester, const Center(child: KnEntrance(child: Text('a'))), disableAnimations: true);

      expect(_opacity(tester, 'a'), 1);
      expect(_dy(tester, 'a'), 0);
    });

    testWidgets('o texto continua na árvore durante a entrada', (tester) async {
      await _pump(tester, const Center(child: KnEntrance(child: Text('a'))));

      expect(find.text('a'), findsOneWidget);
    });
  });

  group('KnStoryPage', () {
    testWidgets('mostra o eyebrow em caixa alta, o título como cabeçalho e o conteúdo, nessa ordem', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const KnStoryPage(eyebrow: 'Fase da Lua', title: 'Título', children: [Text('corpo')]));
      await tester.pumpAndSettle();

      expect(find.text('FASE DA LUA'), findsOneWidget);
      expect(tester.getSemantics(find.text('Título')).flagsCollection.isHeader, isTrue);
      expect(tester.getTopLeft(find.text('FASE DA LUA')).dy, lessThan(tester.getTopLeft(find.text('Título')).dy));
      expect(tester.getTopLeft(find.text('Título')).dy, lessThan(tester.getTopLeft(find.text('corpo')).dy));
      handle.dispose();
    });

    testWidgets('eyebrow e título são opcionais', (tester) async {
      await _pump(tester, const KnStoryPage(children: [Text('só o corpo')]));
      await tester.pumpAndSettle();

      expect(find.text('só o corpo'), findsOneWidget);
    });

    testWidgets('rola na vertical quando o conteúdo não cabe, sem overflow', (tester) async {
      await _pump(tester, KnStoryPage(title: 'Título', children: [for (var i = 0; i < 12; i++) Text('linha $i', style: const TextStyle(fontSize: 40))]), size: const Size(360, 300));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
      expect(position.maxScrollExtent, greaterThan(0));
      expect(tester.getBottomLeft(find.text('linha 11')).dy, greaterThan(300), reason: 'fora da área visível');

      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(tester.getBottomLeft(find.text('linha 11')).dy, lessThanOrEqualTo(300));
    });

    testWidgets('usa o espaço que recebe, e não o da tela: dentro de uma área menor o conteúdo centralizado fica nela', (tester) async {
      await _pump(tester, const Align(alignment: Alignment.topCenter, child: SizedBox(height: 200, child: KnStoryPage(centered: true, children: [Text('meio')]))), size: const Size(360, 800));
      await tester.pumpAndSettle();

      expect(tester.getCenter(find.text('meio')).dy, closeTo(100, 20));
    });

    testWidgets('centered centraliza o conteúdo quando sobra espaço e não quando falta', (tester) async {
      await _pump(tester, const KnStoryPage(centered: true, children: [Text('meio')]), size: const Size(360, 600));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('meio')).dy, closeTo(300, 30));

      await _pump(tester, const KnStoryPage(children: [Text('topo')]), size: const Size(360, 600));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('topo')).dy, lessThan(80));
    });

    testWidgets('altura zero não derruba o layout', (tester) async {
      await _pump(tester, const SizedBox(height: 10, child: KnStoryPage(children: [Text('x')])));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
