import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/life_milestones.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('pt'));
  final birth = DateTime(1990, 5, 15);

  group('buildReminders', () {
    test(
      'agenda às 9h do dia de cada marco futuro, com id e payload estáveis',
      () {
        final reminders = buildReminders(l10n, birth, DateTime(2030, 1, 1, 12));

        expect(reminders.map((r) => (r.at, r.payload)).toList(), [
          (DateTime(2030, 5, 15, 9), 'milestone:birthday'),
          (DateTime(2031, 5, 15, 9), 'milestone:birthday'),
          (DateTime(2031, 6, 9, 9), 'milestone:days15000'),
          (DateTime(2032, 1, 15, 9), 'milestone:months500'),
          (DateTime(2045, 2, 15, 9), 'milestone:days20000'),
        ]);
        expect(reminders.map((r) => r.id).toSet().length, reminders.length);
        expect(reminders.first.title, 'Hoje é um dia de marco!');
        expect(
          reminders.first.body,
          'Hoje você completa 40 anos de vida. Toque para ver.',
        );
      },
    );

    test(
      'o mesmo marco recebe sempre o mesmo id (reagendar substitui, não duplica)',
      () {
        final a = buildReminders(l10n, birth, DateTime(2030, 1, 1));
        final b = buildReminders(l10n, birth, DateTime(2030, 2, 1));
        expect(a.map((r) => r.id), b.map((r) => r.id));
      },
    );

    test(
      'marco de hoje depois das 9h não gera lembrete (já passou); antes das 9h gera',
      () {
        final milestoneDay = fixedMilestones(
          birth,
        ).firstWhere((m) => m.kind == MilestoneKind.days20000).date;

        final late = buildReminders(
          l10n,
          birth,
          DateTime(milestoneDay.year, milestoneDay.month, milestoneDay.day, 10),
        );
        final early = buildReminders(
          l10n,
          birth,
          DateTime(milestoneDay.year, milestoneDay.month, milestoneDay.day, 8),
        );

        expect(late.any((r) => r.payload == 'milestone:days20000'), isFalse);
        expect(early.any((r) => r.payload == 'milestone:days20000'), isTrue);
      },
    );

    test('1 bilhão de segundos respeita a hora de nascimento', () {
      final reminders = buildReminders(
        l10n,
        DateTime(1990, 5, 15),
        DateTime(2022, 1, 1),
        birthTime: (hour: 23, minute: 0),
      );
      final billion = reminders.firstWhere(
        (r) => r.payload == 'milestone:seconds1Billion',
      );
      expect(billion.at, DateTime(2022, 1, 22, 9));
    });
  });

  group('payload', () {
    test('ida e volta para todos os marcos', () {
      for (final kind in MilestoneKind.values) {
        final milestone = LifeMilestone(
          kind: kind,
          date: DateTime(2030),
          age: 30,
        );
        expect(parseMilestonePayload(milestonePayload(milestone)), kind);
      }
    });

    test('payload ausente, de outro app ou desconhecido vira null', () {
      expect(parseMilestonePayload(null), isNull);
      expect(parseMilestonePayload(''), isNull);
      expect(parseMilestonePayload('outra:coisa'), isNull);
      expect(parseMilestonePayload('milestone:inexistente'), isNull);
    });
  });
}
