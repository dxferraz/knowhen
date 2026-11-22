import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/calculate_age.dart';

void main() {
  group('calculateAge', () {
    final birthDate = DateTime(1986, 3, 15);

    test('não completa o ano antes do aniversário', () {
      expect(calculateAge(birthDate, DateTime(2026, 3, 14)), 39);
    });

    test('completa o ano no dia do aniversário', () {
      expect(calculateAge(birthDate, DateTime(2026, 3, 15)), 40);
    });

    test('não adianta o aniversário por causa dos anos bissextos', () {
      // Com inDays ~/ 365 essa pessoa já apareceria com 40 anos uns 10 dias antes.
      expect(calculateAge(birthDate, DateTime(2026, 3, 5)), 39);
    });

    test('ignora o horário das datas', () {
      expect(calculateAge(birthDate, DateTime(2026, 3, 15, 0, 0, 1)), 40);
      expect(calculateAge(DateTime(1986, 3, 15, 23, 59), DateTime(2026, 3, 15)), 40);
    });

    test('nascido em 29/02 completa o ano em 01/03 nos anos não bissextos', () {
      final leapBirth = DateTime(2000, 2, 29);
      expect(calculateAge(leapBirth, DateTime(2026, 2, 28)), 25);
      expect(calculateAge(leapBirth, DateTime(2026, 3, 1)), 26);
      expect(calculateAge(leapBirth, DateTime(2028, 2, 29)), 28);
    });

    test('nunca é negativa', () {
      expect(calculateAge(DateTime(2026, 11, 21), DateTime(2026, 11, 20)), 0);
    });
  });

  group('calculateMonthsOfLife', () {
    test('40 anos completos são 480 meses (e não ~487)', () {
      expect(calculateMonthsOfLife(DateTime(1986, 3, 15), DateTime(2026, 3, 15)), 480);
    });

    test('o mês só se completa no dia de mesmo número', () {
      final birthDate = DateTime(2026, 1, 15);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 2, 14)), 0);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 2, 15)), 1);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 12, 31)), 11);
    });

    test('nascido no dia 31 completa o mês no dia 1º quando o mês é mais curto', () {
      final birthDate = DateTime(2026, 1, 31);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 2, 28)), 0);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 3, 1)), 1);
      expect(calculateMonthsOfLife(birthDate, DateTime(2026, 3, 31)), 2);
    });

    test('nunca é negativo', () {
      expect(calculateMonthsOfLife(DateTime(2026, 11, 21), DateTime(2026, 11, 20)), 0);
    });
  });

  group('calculateDaysOfLife', () {
    test('conta os dias por calendário, incluindo os bissextos', () {
      expect(calculateDaysOfLife(DateTime(2000, 1, 1), DateTime(2001, 1, 1)), 366);
      expect(calculateDaysOfLife(DateTime(2001, 1, 1), DateTime(2002, 1, 1)), 365);
    });

    test('não perde um dia na virada do horário de verão nem pelo horário', () {
      // 15/10/2017 foi início do horário de verão no Brasil (dia de 23 horas).
      expect(calculateDaysOfLife(DateTime(2017, 10, 14), DateTime(2017, 10, 16)), 2);
      expect(calculateDaysOfLife(DateTime(2017, 10, 14, 23, 30), DateTime(2017, 10, 15, 0, 10)), 1);
    });

    test('nunca é negativo', () {
      expect(calculateDaysOfLife(DateTime(2026, 11, 21), DateTime(2026, 11, 20)), 0);
    });
  });

  group('shouldShowConception', () {
    final birthDate = DateTime(2000, 6, 10);

    test('esconde aos 18 anos completos e antes', () {
      expect(shouldShowConception(birthDate, DateTime(2018, 6, 9)), isFalse);
      expect(shouldShowConception(birthDate, DateTime(2018, 6, 10)), isFalse);
      expect(shouldShowConception(birthDate, DateTime(2019, 6, 9)), isFalse);
    });

    test('mostra a partir dos 19 anos completos', () {
      expect(shouldShowConception(birthDate, DateTime(2019, 6, 10)), isTrue);
    });
  });
}
