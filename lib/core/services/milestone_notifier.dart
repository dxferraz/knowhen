import 'package:knowhen/core/functions/life_milestones.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

/// Hora local em que o lembrete do marco dispara.
const reminderHour = 9;

class ReminderRequest {
  const ReminderRequest({required this.id, required this.at, required this.title, required this.body, required this.payload});

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final String payload;

  @override
  bool operator ==(Object other) =>
      other is ReminderRequest && other.id == id && other.at == at && other.title == title && other.body == body && other.payload == payload;

  @override
  int get hashCode => Object.hash(id, at, title, body, payload);

  @override
  String toString() => 'ReminderRequest(id: $id, at: $at, payload: $payload)';
}

/// Agenda e cancela as notificações locais dos marcos. A implementação real usa
/// `flutter_local_notifications`; os testes usam um fake.
abstract interface class MilestoneNotifier {
  /// Prepara o plugin. [onSelected] recebe o payload da notificação tocada com o app aberto.
  Future<void> initialize({required void Function(String? payload) onSelected});

  /// Payload da notificação que abriu o app (app fechado), ou `null`.
  Future<String?> launchPayload();

  Future<bool> hasPermission();

  /// Mostra o pedido de permissão do sistema. Só deve ser chamado depois do usuário tocar em "Me avise".
  Future<bool> requestPermission();

  Future<void> openSettings();

  /// Cancela todos os lembretes e agenda [reminders] no lugar deles.
  Future<void> replaceAll(List<ReminderRequest> reminders);

  Future<void> cancelAll();
}

String milestonePayload(LifeMilestone milestone) => 'milestone:${milestone.kind.name}';

MilestoneKind? parseMilestonePayload(String? payload) {
  if (payload == null || !payload.startsWith('milestone:')) return null;
  final name = payload.substring('milestone:'.length);
  for (final kind in MilestoneKind.values) {
    if (kind.name == name) return kind;
  }
  return null;
}

/// Nome do marco no texto do app, ex.: "10.000 dias de vida".
String milestoneName(AppLocalizations l10n, LifeMilestone milestone) => switch (milestone.kind) {
      MilestoneKind.weeks1000 => l10n.milestoneWeeks1000,
      MilestoneKind.days10000 => l10n.milestoneDays10000,
      MilestoneKind.seconds1Billion => l10n.milestoneSeconds1Billion,
      MilestoneKind.months500 => l10n.milestoneMonths500,
      MilestoneKind.days15000 => l10n.milestoneDays15000,
      MilestoneKind.days20000 => l10n.milestoneDays20000,
      MilestoneKind.birthday => l10n.milestoneBirthday(milestone.age!),
    };

/// Lembretes das 9h dos próximos marcos que ainda estão no futuro em [now].
List<ReminderRequest> buildReminders(
  AppLocalizations l10n,
  DateTime birthDate,
  DateTime now, {
  ({int hour, int minute})? birthTime,
}) {
  final reminders = <ReminderRequest>[];
  for (final milestone in upcomingMilestones(birthDate, now, birthTime: birthTime, birthdays: 2)) {
    final at = DateTime(milestone.date.year, milestone.date.month, milestone.date.day, reminderHour);
    if (!at.isAfter(now)) continue;
    reminders.add(
      ReminderRequest(
        id: milestone.notificationId,
        at: at,
        title: l10n.milestoneNotificationTitle,
        body: l10n.milestoneNotificationBody(milestoneName(l10n, milestone)),
        payload: milestonePayload(milestone),
      ),
    );
  }
  return reminders;
}
