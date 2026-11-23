import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';

void main() {
  group('getMoonPhase em datas de fases conhecidas', () {
    final knownPhases = <DateTime, MoonPhaseType>{
      // Luas cheias (várias com eclipse lunar).
      DateTime(2000, 1, 21): MoonPhaseType.fullMoon,
      DateTime(1990, 2, 9): MoonPhaseType.fullMoon,
      DateTime(1985, 6, 3): MoonPhaseType.fullMoon,
      DateTime(2022, 11, 8): MoonPhaseType.fullMoon,
      DateTime(2025, 3, 14): MoonPhaseType.fullMoon,
      DateTime(2025, 9, 7): MoonPhaseType.fullMoon,
      // Luas novas (dias de eclipse solar).
      DateTime(1925, 1, 24): MoonPhaseType.newMoon,
      DateTime(2017, 8, 21): MoonPhaseType.newMoon,
      DateTime(2019, 7, 2): MoonPhaseType.newMoon,
      DateTime(2023, 10, 14): MoonPhaseType.newMoon,
      DateTime(2024, 4, 8): MoonPhaseType.newMoon,
      // Ciclo de janeiro/2000: nova em 06/01, quarto crescente em 14/01, cheia em 21/01, quarto minguante em 28/01.
      DateTime(2000, 1, 10): MoonPhaseType.waxingCrescent,
      DateTime(2000, 1, 14): MoonPhaseType.firstQuarter,
      DateTime(2000, 1, 18): MoonPhaseType.waxingGibbous,
      DateTime(2000, 1, 24): MoonPhaseType.waningGibbous,
      DateTime(2000, 1, 28): MoonPhaseType.lastQuarter,
      DateTime(2000, 2, 2): MoonPhaseType.waningCrescent,
    };

    for (final entry in knownPhases.entries) {
      final date = entry.key;
      test('${date.day}/${date.month}/${date.year} é ${entry.value}', () {
        expect(getMoonPhase(date).type, entry.value);
      });
    }
  });

  group('getMoonPhaseFraction', () {
    test('é 0,5 na lua cheia e perto de 0 (ou de 1) na lua nova', () {
      expect(getMoonPhaseFraction(DateTime(2000, 1, 21)), closeTo(0.5, 0.05));
      final fresh = getMoonPhaseFraction(DateTime(2024, 4, 8));
      expect(fresh < 0.05 || fresh > 0.95, isTrue);
    });

    test('fica sempre em [0, 1) e concorda com a fase de 8 partes', () {
      for (var day = 0; day < 400; day++) {
        final date = DateTime(2000, 1, 1).add(Duration(days: day * 37));
        final fraction = getMoonPhaseFraction(date);
        expect(fraction, greaterThanOrEqualTo(0), reason: '$date');
        expect(fraction, lessThan(1), reason: '$date');
        expect(MoonPhaseType.values[(fraction * 8).round() % 8], getMoonPhase(date).type, reason: '$date');
      }
    });
  });

  test('ignora o horário da data', () {
    expect(getMoonPhase(DateTime(2000, 1, 21, 23, 59)), getMoonPhase(DateTime(2000, 1, 21)));
  });

  test('a idade da Lua fica entre 0 e o mês sinódico, inclusive antes de 2000', () {
    for (final date in [DateTime(1925, 1, 1), DateTime(1999, 12, 31), DateTime(2000, 1, 6), DateTime(2026, 11, 20)]) {
      expect(getMoonAge(date), inInclusiveRange(0, 29.530588853));
    }
  });

  test('todas as 8 fases aparecem, cada uma em ~1/8 dos dias de 1925 a 2024', () {
    final counts = <MoonPhaseType, int>{};
    var totalDays = 0;
    for (var date = DateTime.utc(1925, 1, 1); date.year < 2025; date = date.add(const Duration(days: 1))) {
      final type = getMoonPhase(date).type;
      counts[type] = (counts[type] ?? 0) + 1;
      totalDays++;
    }

    expect(counts.keys, hasLength(8));
    for (final count in counts.values) {
      expect(count / totalDays, closeTo(1 / 8, 0.01));
    }
  });
}
