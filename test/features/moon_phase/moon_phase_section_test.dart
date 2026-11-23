import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/features/moon_phase/presentation/moon_phase_l10n.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/pump_card.dart';

/// Cheia: 21/01/2000. Nova: 06/01/2000 (referência do cálculo).
final _fullMoonDay = DateTime(2000, 1, 21);
final _newMoonDay = DateTime(2000, 1, 6);

Widget _section(DateTime birth) => MoonPhaseSection(moonPhase: getMoonPhase(birth), birthDate: birth);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  test('toda fase tem nome, descrição e influência diferentes no l10n', () {
    for (final getText in [l10n.moonPhaseName, l10n.moonPhaseDescription, l10n.moonPhaseInfluence]) {
      final texts = MoonPhaseType.values.map(getText).toList();

      expect(texts, everyElement(isNotEmpty));
      expect(texts.toSet(), hasLength(MoonPhaseType.values.length));
    }
  });

  test('o nome de cada fase continua o texto que já era exibido', () {
    expect(l10n.moonPhaseName(MoonPhaseType.newMoon), 'Lua nova');
    expect(l10n.moonPhaseName(MoonPhaseType.waxingGibbous), 'Lua gibosa crescente');
    expect(l10n.moonPhaseName(MoonPhaseType.lastQuarter), 'Lua quarto minguante');
  });

  testWidgets('o título diz a fase e o corpo traz a descrição e a influência, vindas do l10n', (tester) async {
    await pumpCard(tester, _section(_fullMoonDay));

    expect(getMoonPhase(_fullMoonDay).type, MoonPhaseType.fullMoon);
    expect(find.text(l10n.moonBornUnder(l10n.moonPhaseFullMoonName)), findsOneWidget);
    expect(find.text(l10n.moonEyebrow.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.moonPhaseFullMoonDescription), findsOneWidget);
    expect(find.text(l10n.moonPhaseFullMoonInfluence), findsOneWidget);
  });

  testWidgets('a lua é desenhada pelo app, sem baixar imagem', (tester) async {
    await pumpCard(tester, _section(_fullMoonDay));

    expect(find.byType(Image), findsNothing);
    // A grande e as 8 do ciclo, todas espelhadas para o hemisfério sul.
    final moons = tester.widgetList<KnMoon>(find.byType(KnMoon)).toList();
    expect(moons, hasLength(1 + MoonPhaseType.values.length));
    expect(moons.every((m) => m.southernHemisphere), isTrue);
  });

  testWidgets('a lua grande usa a fração real da fase, e não só a do nome', (tester) async {
    await pumpCard(tester, _section(_fullMoonDay));

    final big = tester.widgetList<KnMoon>(find.byType(KnMoon)).first;
    expect(big.phase, closeTo(getMoonPhaseFraction(_fullMoonDay), 1e-9));
    expect(big.phase, closeTo(0.5, 0.05));
    expect(big.size, 150);
  });

  testWidgets('o ciclo mostra as 8 fases em ordem, a do nascimento destacada pelo anel', (tester) async {
    await pumpCard(tester, _section(_fullMoonDay));

    final cycle = tester.widgetList<KnMoon>(find.byType(KnMoon)).skip(1).map((m) => m.phase).toList();
    expect(cycle, [for (var i = 0; i < 8; i++) i / 8]);

    final rings = tester.widgetList<Container>(find.byType(Container)).where((c) => c.decoration is BoxDecoration && (c.decoration! as BoxDecoration).shape == BoxShape.circle).toList();
    expect(rings, hasLength(8));
    bool hasRing(Container c) => ((c.decoration! as BoxDecoration).border! as Border).top.color.a > 0;
    expect([for (var i = 0; i < rings.length; i++) if (hasRing(rings[i])) i], [MoonPhaseType.fullMoon.index]);
  });

  testWidgets('a lua nova, que é invisível, fica compreensível: título, ciclo e anel na primeira', (tester) async {
    await pumpCard(tester, _section(_newMoonDay));

    expect(find.text(l10n.moonBornUnder(l10n.moonPhaseNewMoonName)), findsOneWidget);
    expect(find.text(l10n.moonPhaseNewMoonDescription), findsOneWidget);
  });

  testWidgets('o ciclo é lido como um só item, com a fase do nascimento', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, _section(_fullMoonDay));

    expect(find.bySemanticsLabel(l10n.moonCycleLabel(l10n.moonPhaseFullMoonName)), findsOneWidget);
    expect(tester.getSemantics(find.text(l10n.moonBornUnder(l10n.moonPhaseFullMoonName))).flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow e a influência alcançável', (tester) async {
        await pumpCard(tester, _section(_fullMoonDay), brightness: brightness, scale: scale);

        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text(l10n.moonPhaseFullMoonInfluence), 100, scrollable: find.byType(Scrollable));
        expect(find.text(l10n.moonPhaseFullMoonInfluence), findsOneWidget);
      });
    }
  }

  testWidgets('num celular de 320 dp de largura as 8 luas do ciclo cabem na linha', (tester) async {
    await pumpCard(tester, _section(_fullMoonDay));
    tester.view.physicalSize = const Size(320, 440);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
