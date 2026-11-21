import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/milestone_fakes.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('pt'));
  final birth = DateTime(1990, 5, 15);
  final now = DateTime(2026, 11, 21, 8);

  late FakeMilestoneNotifier notifier;
  late FakeMilestoneAnalytics analytics;
  late BirthdateStorage storage;

  LifeProfileService buildService() => LifeProfileService(
    storage: storage,
    notifier: notifier,
    analytics: analytics,
    l10n: l10n,
    clock: () => now,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifier = FakeMilestoneNotifier();
    analytics = FakeMilestoneAnalytics();
    storage = BirthdateStorage();
  });

  group('salvar e apagar a data', () {
    test(
      'save guarda só a data (sem hora do dia) e registra birthdate_saved',
      () async {
        final service = buildService();
        await service.save(
          DateTime(1990, 5, 15, 13, 45),
          const TimeOfDay(hour: 23, minute: 10),
        );

        expect(
          service.saved,
          SavedBirthdate(birth, time: const TimeOfDay(hour: 23, minute: 10)),
        );
        expect(await storage.read(), service.saved);
        expect(analytics.events, ['birthdate_saved:manual']);
      },
    );

    test('a data salva volta na próxima abertura do app', () async {
      await buildService().save(birth, null);

      final reopened = buildService();
      await reopened.load();
      expect(reopened.saved?.date, birth);
    });

    test('clear apaga a data e cancela os lembretes agendados', () async {
      notifier.permission = true;
      final service = buildService();
      await service.enableReminders(birth, null);
      expect(notifier.scheduled, isNotEmpty);

      await service.clear();

      expect(service.saved, isNull);
      expect(service.remindersEnabled, isFalse);
      expect(notifier.scheduled, isEmpty);
      expect(await storage.read(), isNull);
      expect(await storage.readRemindersEnabled(), isFalse);
    });
  });

  group('Me avise', () {
    test(
      'só pede permissão ao ativar os lembretes, nunca ao salvar ou carregar',
      () async {
        final service = buildService();
        await service.save(birth, null);
        await service.load();

        expect(notifier.permissionRequests, 0);
      },
    );

    test(
      'permissão concedida agenda os lembretes às 9h, salva a data e registra os eventos',
      () async {
        final service = buildService();
        final outcome = await service.enableReminders(birth, null);

        expect(outcome, RemindersOutcome.enabled);
        expect(notifier.permissionRequests, 1);
        expect(service.remindersEnabled, isTrue);
        expect(service.saved?.date, birth);
        expect(notifier.scheduled, isNotEmpty);
        expect(
          notifier.scheduled.every((r) => r.at.hour == 9 && r.at.isAfter(now)),
          isTrue,
        );
        expect(analytics.events, [
          'notification_permission_result:true',
          'birthdate_saved:reminder',
          'milestone_reminder_enabled:birthday:${notifier.scheduled.length}',
        ]);
      },
    );

    test(
      'recusar a permissão não agenda nada, não salva e o fluxo segue normal',
      () async {
        notifier.grantsOnRequest = false;
        final service = buildService();
        final outcome = await service.enableReminders(birth, null);

        expect(outcome, RemindersOutcome.permissionDenied);
        expect(service.remindersEnabled, isFalse);
        expect(service.saved, isNull);
        expect(notifier.scheduled, isEmpty);
        expect(analytics.events, ['notification_permission_result:false']);

        // O usuário ainda consegue salvar a data normalmente.
        await service.save(birth, null);
        expect(service.saved?.date, birth);
      },
    );

    test('permissão já concedida não pede de novo', () async {
      notifier.permission = true;
      final outcome = await buildService().enableReminders(birth, null);

      expect(outcome, RemindersOutcome.enabled);
      expect(notifier.permissionRequests, 0);
    });

    test(
      'plugin que lança ao pedir permissão vira "negada", sem exceção',
      () async {
        final service = LifeProfileService(
          storage: storage,
          notifier: _ThrowingNotifier(),
          analytics: analytics,
          l10n: l10n,
          clock: () => now,
        );

        expect(
          await service.enableReminders(birth, null),
          RemindersOutcome.permissionDenied,
        );
      },
    );

    test(
      'falha ao agendar devolve failed e não marca os lembretes como ativos',
      () async {
        notifier.permission = true;
        notifier.scheduleError = StateError('sem alarme');
        final service = buildService();

        expect(
          await service.enableReminders(birth, null),
          RemindersOutcome.failed,
        );
        expect(service.remindersEnabled, isFalse);
        expect(await storage.readRemindersEnabled(), isFalse);
      },
    );

    test('desativar cancela os lembretes mas mantém a data salva', () async {
      notifier.permission = true;
      final service = buildService();
      await service.enableReminders(birth, null);

      await service.disableReminders();

      expect(service.remindersEnabled, isFalse);
      expect(notifier.scheduled, isEmpty);
      expect(service.saved?.date, birth);
    });
  });

  group('reabrir o app (inclui reiniciar o aparelho)', () {
    test(
      'com lembretes ativos e permissão, reagenda os marcos a partir de hoje',
      () async {
        notifier.permission = true;
        await buildService().enableReminders(birth, null);
        notifier.scheduled = []; // o sistema perdeu os agendamentos

        final reopened = buildService();
        await reopened.load();

        expect(reopened.remindersEnabled, isTrue);
        expect(notifier.scheduled, isNotEmpty);
      },
    );

    test(
      'permissão revogada nas configurações desliga os lembretes sem quebrar',
      () async {
        notifier.permission = true;
        await buildService().enableReminders(birth, null);
        notifier.permission = false;

        final reopened = buildService();
        await reopened.load();

        expect(reopened.remindersEnabled, isFalse);
        expect(reopened.saved?.date, birth);
        expect(await storage.readRemindersEnabled(), isFalse);
      },
    );

    test(
      'trocar a data salva com lembretes ativos reagenda para a nova data',
      () async {
        notifier.permission = true;
        final service = buildService();
        await service.enableReminders(birth, null);
        final before = notifier.scheduled.map((r) => r.at).toList();

        await service.save(DateTime(2000, 1, 1), null);

        expect(notifier.scheduled.map((r) => r.at).toList(), isNot(before));
      },
    );
  });
}

class _ThrowingNotifier extends FakeMilestoneNotifier {
  @override
  Future<bool> hasPermission() async => throw StateError('plugin indisponível');

  @override
  Future<bool> requestPermission() async =>
      throw StateError('plugin indisponível');
}
