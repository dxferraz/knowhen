import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_reveal.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

final _birthDate = DateTime(1991, 3, 14);

Future<void> _pumpReveal(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: brightness == Brightness.dark ? darkTheme : lightTheme,
      themeAnimationDuration: Duration.zero,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: disableAnimations),
        child: app!,
      ),
      home: SummaryReveal(birthDate: _birthDate),
    ),
  );
}

/// Os três passos, na ordem: `true` quando o passo já está marcado.
List<bool> _stepsDone(WidgetTester tester) {
  final checks = find.byIcon(Icons.check_circle_rounded).evaluate().length;
  return [for (var i = 0; i < 3; i++) i < checks];
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('mostra o título com a data por extenso e os três passos', (tester) async {
    await _pumpReveal(tester);

    expect(find.text(l10n.revealTitle(DateText.dayMonthYear(_birthDate))), findsOneWidget);
    expect(find.text(l10n.revealStepLife), findsOneWidget);
    expect(find.text(l10n.revealStepMoon), findsOneWidget);
    expect(find.text(l10n.revealStepFact), findsOneWidget);
  });

  testWidgets('os passos locais se marcam sozinhos e o do fato fica pendente enquanto a rede não responde', (tester) async {
    await _pumpReveal(tester);
    expect(_stepsDone(tester), [false, false, false]);

    await tester.pump(SummaryReveal.duration * 0.5);
    expect(_stepsDone(tester), [true, false, false]);

    await tester.pump(SummaryReveal.duration);
    expect(_stepsDone(tester), [true, true, false]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a lua cresce até a fase do nascimento, no hemisfério sul', (tester) async {
    await _pumpReveal(tester);
    double phase() => tester.widget<KnMoon>(find.byType(KnMoon)).phase;

    expect(phase(), 0);
    await tester.pump(SummaryReveal.duration * 0.5);
    final middle = phase();
    await tester.pump(SummaryReveal.duration);

    expect(middle, greaterThan(0));
    expect(phase(), greaterThan(middle));
    expect(tester.widget<KnMoon>(find.byType(KnMoon)).southernHemisphere, isTrue);
  });

  testWidgets('com movimento reduzido a lua já nasce na fase final e não há indicador girando', (tester) async {
    await _pumpReveal(tester, disableAnimations: true);

    expect(tester.widget<KnMoon>(find.byType(KnMoon)).phase, greaterThan(0));
    expect(_stepsDone(tester), [true, true, false]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
  });

  testWidgets('é uma região viva para o leitor de tela', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpReveal(tester);

    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true), findsOneWidget);
    semantics.dispose();
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      final name = brightness == Brightness.dark ? 'escuro' : 'claro';
      testWidgets('360x640 a ${(scale * 100).round()}% de fonte, tema $name: sem overflow', (tester) async {
        await _pumpReveal(tester, brightness: brightness, scale: scale);
        await tester.pump(SummaryReveal.duration * 2);

        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final brightness in Brightness.values) {
    final name = brightness == Brightness.dark ? 'escuro' : 'claro';
    testWidgets('golden da revelação, tema $name', (tester) async {
      await _pumpReveal(tester, brightness: brightness, disableAnimations: true);
      await tester.pump();

      expect(tester.takeException(), isNull);
      await expectLater(find.byType(SummaryReveal), matchesGoldenFile('goldens/summary_reveal_$name.png'));
    });
  }
}
