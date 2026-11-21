import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';

class FakeMilestoneNotifier implements MilestoneNotifier {
  FakeMilestoneNotifier({this.permission = false, this.grantsOnRequest = true, this.scheduleError});

  bool permission;
  bool grantsOnRequest;
  Object? scheduleError;

  int permissionRequests = 0;
  int settingsOpened = 0;
  int cancelAllCalls = 0;
  List<ReminderRequest> scheduled = [];
  void Function(String? payload)? onSelected;
  String? launch;

  @override
  Future<void> initialize({required void Function(String? payload) onSelected}) async => this.onSelected = onSelected;

  @override
  Future<String?> launchPayload() async => launch;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    permission = grantsOnRequest;
    return permission;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<void> replaceAll(List<ReminderRequest> reminders) async {
    if (scheduleError != null) throw scheduleError!;
    scheduled = List.of(reminders);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled = [];
  }
}

class FakeMilestoneAnalytics implements MilestoneAnalytics {
  final List<String> events = [];

  @override
  Future<void> logBirthdateSaved({required String source}) async => events.add('birthdate_saved:$source');

  @override
  Future<void> logMilestoneReminderEnabled({required String milestone, required int scheduled}) async =>
      events.add('milestone_reminder_enabled:$milestone:$scheduled');

  @override
  Future<void> logNotificationPermissionResult({required bool granted}) async => events.add('notification_permission_result:$granted');

  @override
  Future<void> logMilestoneNotificationOpened(String milestone) async => events.add('milestone_notification_opened:$milestone');
}
