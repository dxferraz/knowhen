import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/life_clock.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/pump_card.dart';

final _birth = DateTime(1991, 3, 14);
final _now = DateTime(2026, 11, 20, 12);

Widget _section({DateTime? birth, TimeOfDay? time, DateTime? now}) =>
    YearsOfLifeSection(birthDate: birth ?? _birth, birthTime: time, now: now ?? _now);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  group('herói', () {
    testWidgets('mostra a idade exata por calendário, e não dias/365', (tester) async {
      await pumpCard(tester, _section());

      expect(find.text('35 anos'), findsOneWidget);
      expect(find.text('8 meses e 6 dias'), findsOneWidget);
      expect(find.text(l10n.lifeEyebrow.toUpperCase()), findsOneWidget);
    });

    testWidgets('a contagem sobe de perto de 0 até o valor, em 800 ms', (tester) async {
      int shown() => int.parse(RegExp(r'^(\d+) anos?$').firstMatch(tester.widgetList<Text>(find.textContaining('ano')).first.data!)!.group(1)!);

      await pumpCard(tester, _section(), settle: false);
      final start = shown();
      await tester.pump(const Duration(milliseconds: 300));
      final mid = shown();
      await tester.pump(const Duration(milliseconds: 600));

      expect(start, lessThan(mid));
      expect(mid, lessThan(35));
      expect(shown(), 35);
    });

    testWidgets('com movimento reduzido mostra o valor final direto', (tester) async {
      await pumpCard(tester, _section(), disableAnimations: true, settle: false);

      expect(find.text('35 anos'), findsOneWidget);
      expect(find.text('0 anos'), findsNothing);
    });

    testWidgets('o leitor de tela lê o valor final, e não os números da contagem', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _section(), settle: false);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.bySemanticsLabel('35 anos 8 meses e 6 dias'), findsOneWidget);
      expect(tester.getSemantics(find.bySemanticsLabel('35 anos 8 meses e 6 dias')).flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    testWidgets('singular: 1 ano, 1 mês e 1 dia', (tester) async {
      await pumpCard(tester, _section(birth: DateTime(2025, 10, 19)));

      expect(find.text('1 ano'), findsOneWidget);
      expect(find.text('1 mês e 1 dia'), findsOneWidget);
    });

    testWidgets('quem tem menos de 1 ano vê os meses, e não "0 anos"', (tester) async {
      await pumpCard(tester, _section(birth: DateTime(2026, 8, 15)));

      expect(find.text('3 meses'), findsOneWidget);
      expect(find.text('e 5 dias'), findsOneWidget);
      expect(find.textContaining('0 anos'), findsNothing);
    });

    testWidgets('quem tem menos de 1 mês vê os dias', (tester) async {
      await pumpCard(tester, _section(birth: DateTime(2026, 11, 1)));

      expect(find.text('19 dias'), findsOneWidget);
    });
  });

  group('até agora você viveu', () {
    testWidgets('dias, horas, minutos e segundos com separador de milhar', (tester) async {
      await pumpCard(tester, _section());

      final days = calculateDaysOfLife(_birth, _now);
      final lived = _now.difference(DateTime(1991, 3, 14));
      expect(days, 13035);
      expect(find.text('13.035'), findsOneWidget);
      expect(find.text(_thousands(lived.inHours)), findsOneWidget);
      expect(find.text(l10n.lifeSoFar), findsOneWidget);
      for (final label in [l10n.lifeUnitDays, l10n.lifeUnitHours, l10n.lifeUnitMinutes, l10n.lifeUnitSeconds]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('a hora de nascimento afina horas, minutos e segundos', (tester) async {
      await pumpCard(tester, _section(time: const TimeOfDay(hour: 6, minute: 30)));

      final lived = _now.difference(DateTime(1991, 3, 14, 6, 30));
      expect(find.text(_thousands(lived.inHours)), findsOneWidget);
      expect(find.text(_thousands(lived.inSeconds)), findsOneWidget);
    });

    testWidgets('os segundos correm ao vivo, um por segundo', (tester) async {
      var clock = DateTime(2026, 11, 20, 12, 0, 0);
      await pumpCard(
        tester,
        LifeClock(birthDate: _birth, clock: () => clock),
        settle: false,
      );
      final before = DateTime(2026, 11, 20, 12).difference(DateTime(1991, 3, 14)).inSeconds;
      expect(find.text(_thousands(before)), findsOneWidget);

      clock = clock.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(_thousands(before + 1)), findsOneWidget);
      expect(find.text(_thousands(before)), findsNothing);
    });

    testWidgets('o relógio para ao sair da tela', (tester) async {
      await pumpCard(tester, LifeClock(birthDate: _birth), settle: false);
      await tester.pumpWidget(const SizedBox());

      // Sem Timer pendente: o teste falharia ao terminar.
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('aniversário', () {
    testWidgets('mostra quantos dias faltam para o próximo aniversário', (tester) async {
      await pumpCard(tester, _section());

      expect(find.text('Faltam 114 dias para o seu próximo aniversário'), findsOneWidget);
    });

    testWidgets('no dia do aniversário comemora', (tester) async {
      await pumpCard(tester, _section(now: DateTime(2026, 3, 14, 9)));

      expect(find.text('Hoje é o seu aniversário!'), findsOneWidget);
    });

    testWidgets('um dia antes: "Falta 1 dia"', (tester) async {
      await pumpCard(tester, _section(now: DateTime(2026, 3, 13, 9)));

      expect(find.text('Falta 1 dia para o seu próximo aniversário'), findsOneWidget);
    });
  });

  group('layout', () {
    for (final scale in [1.0, 2.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow e o final do cartão alcançável', (tester) async {
          await pumpCard(tester, _section(time: const TimeOfDay(hour: 6, minute: 30)), brightness: brightness, scale: scale);

          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(find.textContaining('aniversário'), 100, scrollable: find.byType(Scrollable));
          expect(find.textContaining('aniversário'), findsOneWidget);
        });
      }
    }
  });
}

String _thousands(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
