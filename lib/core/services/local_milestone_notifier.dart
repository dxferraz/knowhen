import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:knowhen/core/services/milestone_notifier.dart';

/// Notificações locais via `flutter_local_notifications`. Não precisa de backend nem de push.
///
/// No Android, o plugin guarda os agendamentos e o `ScheduledNotificationBootReceiver` (AndroidManifest)
/// os reagenda quando o aparelho reinicia. No iOS, o sistema mantém as notificações locais agendadas.
class LocalMilestoneNotifier implements MilestoneNotifier {
  LocalMilestoneNotifier({required this.channelName, required this.channelDescription, FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final String channelName;
  final String channelDescription;
  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize({required void Function(String? payload) onSelected}) async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // A permissão só é pedida quando o usuário toca em "Me avise".
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => onSelected(response.payload),
    );
  }

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  @override
  Future<bool> hasPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
      case TargetPlatform.iOS:
        return (await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions())?.isEnabled ?? false;
      default:
        return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? await hasPermission();
      case TargetPlatform.iOS:
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? await hasPermission();
      default:
        return false;
    }
  }

  @override
  Future<void> openSettings() async {
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<void> replaceAll(List<ReminderRequest> reminders) async {
    await _plugin.cancelAllPendingNotifications();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        // Instante absoluto: calculado a partir da hora local do aparelho no momento do agendamento.
        scheduledDate: tz.TZDateTime.from(reminder.at, tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'milestones',
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // Inexato: evita a permissão de alarme exato (restrita no Google Play). O dia é o certo; a hora
        // pode atrasar alguns minutos com o aparelho em economia de bateria.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.payload,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
