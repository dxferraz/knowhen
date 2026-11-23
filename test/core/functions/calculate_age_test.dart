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

  group('calculateAgeParts', () {
    test('separa anos, meses e dias por calendário', () {
      final parts = calculateAgeParts(DateTime(1991, 3, 14), DateTime(2026, 11, 20));

      expect(parts, (years: 35, months: 8, days: 6));
    });

    test('no aniversário os meses e os dias zeram', () {
      expect(calculateAgeParts(DateTime(1991, 3, 14), DateTime(2026, 3, 14)), (years: 35, months: 0, days: 0));
    });

    test('um dia antes do aniversário são 11 meses e o resto do mês', () {
      expect(calculateAgeParts(DateTime(1991, 3, 14), DateTime(2026, 3, 13)), (years: 34, months: 11, days: 27));
    });

    test('bebê com menos de um mês só tem dias', () {
      expect(calculateAgeParts(DateTime(2026, 11, 1), DateTime(2026, 11, 20)), (years: 0, months: 0, days: 19));
    });

    test('nascido no dia 31 completa o mês no dia 1º quando o mês é mais curto', () {
      expect(calculateAgeParts(DateTime(2026, 1, 31), DateTime(2026, 2, 28)), (years: 0, months: 0, days: 28));
      expect(calculateAgeParts(DateTime(2026, 1, 31), DateTime(2026, 3, 1)), (years: 0, months: 1, days: 0));
    });

    test('nascido em 29/02 completa o ano em 01/03 nos anos não bissextos', () {
      expect(calculateAgeParts(DateTime(2000, 2, 29), DateTime(2026, 2, 28)), (years: 25, months: 11, days: 30));
      expect(calculateAgeParts(DateTime(2000, 2, 29), DateTime(2026, 3, 1)), (years: 26, months: 0, days: 0));
    });

    test('ignora o horário e nunca é negativa', () {
      expect(calculateAgeParts(DateTime(1991, 3, 14, 23, 59), DateTime(2026, 11, 20, 0, 1)), (years: 35, months: 8, days: 6));
      expect(calculateAgeParts(DateTime(2030, 1, 1), DateTime(2026, 1, 1)), (years: 0, months: 0, days: 0));
    });

    test('concorda com calculateAge e calculateMonthsOfLife em todos os dias de 3 anos', () {
      final birth = DateTime(1996, 2, 29);
      for (var d = DateTime(2020, 1, 1); d.isBefore(DateTime(2023, 1, 1)); d = DateTime(d.year, d.month, d.day + 1)) {
        final parts = calculateAgeParts(birth, d);
        expect(parts.years, calculateAge(birth, d), reason: '$d');
        expect(parts.years * 12 + parts.months, calculateMonthsOfLife(birth, d), reason: '$d');
        expect(parts.days, inInclusiveRange(0, 30), reason: '$d');
      }
    });
  });

  group('daysUntilNextBirthday', () {
    test('conta os dias até o próximo aniversário', () {
      // 14/03/1991, hoje 20/11/2026: faltam 114 dias para 14/03/2027.
      expect(daysUntilNextBirthday(DateTime(1991, 3, 14), DateTime(2026, 11, 20)), 114);
    });

    test('é 0 no dia do aniversário e 364 no dia seguinte', () {
      expect(daysUntilNextBirthday(DateTime(1991, 3, 14), DateTime(2026, 3, 14)), 0);
      expect(daysUntilNextBirthday(DateTime(1991, 3, 14), DateTime(2026, 3, 15)), 364);
    });

    test('nascido em 29/02 comemora em 01/03 nos anos não bissextos', () {
      expect(daysUntilNextBirthday(DateTime(2000, 2, 29), DateTime(2026, 2, 28)), 1);
      expect(daysUntilNextBirthday(DateTime(2000, 2, 29), DateTime(2027, 12, 31)), 60);
    });

    test('bebê: o primeiro aniversário ainda está longe', () {
      expect(daysUntilNextBirthday(DateTime(2026, 11, 1), DateTime(2026, 11, 20)), 346);
    });

    test('ignora o horário', () {
      expect(daysUntilNextBirthday(DateTime(1991, 3, 14, 23), DateTime(2026, 3, 13, 23, 59)), 1);
    });
  });
}
