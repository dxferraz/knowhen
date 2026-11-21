import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/life_milestones.dart';

void main() {
  final birth = DateTime(1990, 5, 15);

  group('fixedMilestones', () {
    test('calcula a data de cada marco em ordem cronológica', () {
      final milestones = fixedMilestones(birth);

      expect(
        milestones.map((m) => (m.kind, m.date)).toList(),
        [
          (MilestoneKind.weeks1000, DateTime(2009, 7, 14)),
          (MilestoneKind.days10000, DateTime(2017, 9, 30)),
          (MilestoneKind.seconds1Billion, DateTime(2022, 1, 21)),
          (MilestoneKind.days15000, DateTime(2031, 6, 9)),
          (MilestoneKind.months500, DateTime(2032, 1, 15)),
          (MilestoneKind.days20000, DateTime(2045, 2, 15)),
        ],
      );
    });

    test('1 bilhão de segundos usa a hora de nascimento quando ela é informada', () {
      // 23:00 + 1e9 s = 00:46 do dia seguinte
      final withTime = fixedMilestones(DateTime(1990, 5, 15), birthTime: (hour: 23, minute: 0));
      final withoutTime = fixedMilestones(DateTime(1990, 5, 15));

      DateTime billion(List<LifeMilestone> list) => list.firstWhere((m) => m.kind == MilestoneKind.seconds1Billion).date;
      expect(billion(withoutTime), DateTime(2022, 1, 21));
      expect(billion(withTime), DateTime(2022, 1, 22));
    });

    test('ignora a hora do DateTime de nascimento', () {
      expect(fixedMilestones(DateTime(1990, 5, 15, 18, 30)), fixedMilestones(DateTime(1990, 5, 15)));
    });

    test('500 meses em mês sem o dia de nascimento cai no dia 1º do mês seguinte', () {
      final months = fixedMilestones(DateTime(2000, 1, 31)).firstWhere((m) => m.kind == MilestoneKind.months500);
      // 500 meses = 41 anos e 8 meses -> setembro de 2041 não tem dia 31
      expect(months.date, DateTime(2041, 10, 1));
    });
  });

  group('birthdayDate', () {
    test('aniversário de 29/02 cai em 01/03 nos anos não bissextos', () {
      final leap = DateTime(2000, 2, 29);
      expect(birthdayDate(leap, 1), DateTime(2001, 3, 1));
      expect(birthdayDate(leap, 4), DateTime(2004, 2, 29));
    });
  });

  group('nextMilestone', () {
    test('é o marco mais próximo no futuro', () {
      final next = nextMilestone(birth, DateTime(2024, 3, 10));
      // 15000 dias (2031) vem antes do próximo aniversário? Não: o aniversário é em 15/05/2024.
      expect(next.kind, MilestoneKind.birthday);
      expect(next.age, 34);
      expect(next.date, DateTime(2024, 5, 15));
    });

    test('marco fixo vem antes do aniversário quando está mais perto', () {
      final next = nextMilestone(birth, DateTime(2017, 9, 1));
      expect(next.kind, MilestoneKind.days10000);
      expect(next.date, DateTime(2017, 9, 30));
      expect(next.daysUntil(DateTime(2017, 9, 1)), 29);
    });

    test('hoje conta como o marco (0 dias)', () {
      final next = nextMilestone(birth, DateTime(2017, 9, 30, 14, 20));
      expect(next.kind, MilestoneKind.days10000);
      expect(next.daysUntil(DateTime(2017, 9, 30, 14, 20)), 0);
    });

    test('no dia seguinte o marco passado some', () {
      final next = nextMilestone(birth, DateTime(2017, 10, 1));
      expect(next.kind, isNot(MilestoneKind.days10000));
      expect(next.date.isAfter(DateTime(2017, 9, 30)), isTrue);
    });

    test('depois de todos os marcos fixos sobra o aniversário', () {
      final next = nextMilestone(birth, DateTime(2050, 1, 1));
      expect(next.kind, MilestoneKind.birthday);
      expect(next.age, 60);
      expect(next.date, DateTime(2050, 5, 15));
    });

    test('quem nasceu hoje tem o primeiro aniversário daqui a um ano', () {
      final today = DateTime(2026, 11, 21);
      final next = nextMilestone(today, today);
      expect(next.kind, MilestoneKind.birthday);
      expect(next.age, 1);
      expect(next.date, DateTime(2027, 11, 21));
    });
  });

  group('upcomingMilestones', () {
    test('lista só os que ainda não passaram, mais os próximos aniversários', () {
      final upcoming = upcomingMilestones(birth, DateTime(2030, 1, 1), birthdays: 2);

      expect(upcoming.map((m) => m.kind), [
        MilestoneKind.birthday,
        MilestoneKind.birthday,
        MilestoneKind.days15000,
        MilestoneKind.months500,
        MilestoneKind.days20000,
      ]);
      expect(upcoming.map((m) => m.age).whereType<int>(), [40, 41]);
    });
  });

  group('notificationId', () {
    test('é estável e único por marco', () {
      final ids = upcomingMilestones(DateTime(1950, 1, 1), DateTime(1951, 1, 1), birthdays: 3).map((m) => m.notificationId).toList();
      expect(ids.toSet().length, ids.length);
      expect(
        upcomingMilestones(DateTime(1950, 1, 1), DateTime(1951, 1, 1), birthdays: 3).map((m) => m.notificationId).toList(),
        ids,
      );
    });
  });
}
