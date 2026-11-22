import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/moon_phase/presentation/moon_phase_l10n.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';

import '../../helpers/pump_app.dart';

void main() {
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

  testWidgets('a seção mostra os textos da fase vindos do l10n', (tester) async {
    final moonPhase = getMoonPhase(DateTime(2000, 1, 21));

    await tester.pumpApp(MoonPhaseSection(moonPhase: moonPhase), TestDependencies());

    expect(moonPhase.type, MoonPhaseType.fullMoon);
    expect(find.text(l10n.moonPhaseTitle), findsOneWidget);
    expect(find.text(l10n.moonPhaseFullMoonName), findsOneWidget);
    expect(find.text(l10n.moonPhaseFullMoonDescription), findsOneWidget);
    expect(find.text(l10n.moonPhaseFullMoonInfluence), findsOneWidget);
  });
}
