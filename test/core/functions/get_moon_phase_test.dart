import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';

void main() {
  group('getMoonPhase em datas de fases conhecidas', () {
    final knownPhases = <DateTime, String>{
      // Luas cheias (várias com eclipse lunar).
      DateTime(2000, 1, 21): 'Lua cheia',
      DateTime(1990, 2, 9): 'Lua cheia',
      DateTime(1985, 6, 3): 'Lua cheia',
      DateTime(2022, 11, 8): 'Lua cheia',
      DateTime(2025, 3, 14): 'Lua cheia',
      DateTime(2025, 9, 7): 'Lua cheia',
      // Luas novas (dias de eclipse solar).
      DateTime(1925, 1, 24): 'Lua nova',
      DateTime(2017, 8, 21): 'Lua nova',
      DateTime(2019, 7, 2): 'Lua nova',
      DateTime(2023, 10, 14): 'Lua nova',
      DateTime(2024, 4, 8): 'Lua nova',
      // Ciclo de janeiro/2000: nova em 06/01, quarto crescente em 14/01, cheia em 21/01, quarto minguante em 28/01.
      DateTime(2000, 1, 10): 'Lua crescente',
      DateTime(2000, 1, 14): 'Lua quarto crescente',
      DateTime(2000, 1, 18): 'Lua gibosa crescente',
      DateTime(2000, 1, 24): 'Lua gibosa minguante',
      DateTime(2000, 1, 28): 'Lua quarto minguante',
      DateTime(2000, 2, 2): 'Lua minguante',
    };

    for (final entry in knownPhases.entries) {
      final date = entry.key;
      test('${date.day}/${date.month}/${date.year} é ${entry.value}', () {
        expect(getMoonPhase(date).phaseName, entry.value);
      });
    }
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
    final counts = <String, int>{};
    var totalDays = 0;
    for (var date = DateTime.utc(1925, 1, 1); date.year < 2025; date = date.add(const Duration(days: 1))) {
      final phaseName = getMoonPhase(date).phaseName;
      counts[phaseName] = (counts[phaseName] ?? 0) + 1;
      totalDays++;
    }

    expect(counts.keys, hasLength(8));
    for (final count in counts.values) {
      expect(count / totalDays, closeTo(1 / 8, 0.01));
    }
  });
}
