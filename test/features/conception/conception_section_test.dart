import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/pump_card.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('mostra a janela de 14 dias, 38 semanas antes do nascimento, com o ano de cada ponta', (tester) async {
    await pumpCard(tester, ConceptionSection(birthDate: DateTime(2000, 10, 10)));

    // 10/10/2000 menos 266 dias é 18/01/2000; a janela vai de 11/01 a 25/01.
    expect(find.text('11 jan'), findsOneWidget);
    expect(find.text('25 jan'), findsOneWidget);
    expect(find.text('2000'), findsNWidgets(2));
    expect(find.text(l10n.conceptionEyebrow.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.conceptionLead), findsOneWidget);
  });

  testWidgets('quando a janela cruza a virada do ano cada ponta mostra o seu ano', (tester) async {
    await pumpCard(tester, ConceptionSection(birthDate: DateTime(1990, 9, 20)));

    // 20/09/1990 menos 266 dias é 28/12/1989; a janela vai de 21/12/1989 a 04/01/1990.
    expect(find.text('21 dez'), findsOneWidget);
    expect(find.text('4 jan'), findsOneWidget);
    expect(find.text('1989'), findsOneWidget);
    expect(find.text('1990'), findsOneWidget);
  });

  testWidgets('a nota explica a estimativa e não traz a cegonha nem "provavelmente"', (tester) async {
    await pumpCard(tester, ConceptionSection(birthDate: DateTime(2000, 10, 10)));

    expect(find.text('Estimativa: cerca de 38 semanas antes do nascimento, com margem de uma semana para cada lado.'), findsOneWidget);
    expect(find.textContaining('cegonha'), findsNothing);
    expect(find.textContaining('provavelmente', findRichText: true), findsNothing);
  });

  testWidgets('o título é um cabeçalho para o leitor de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, ConceptionSection(birthDate: DateTime(2000, 10, 10)));

    expect(tester.getSemantics(find.text(l10n.conceptionLead)).flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow e a nota alcançável', (tester) async {
        await pumpCard(tester, ConceptionSection(birthDate: DateTime(2000, 10, 10)), brightness: brightness, scale: scale);

        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.textContaining('Estimativa'), 100, scrollable: find.byType(Scrollable));
        expect(find.textContaining('Estimativa'), findsOneWidget);
      });
    }
  }
}
