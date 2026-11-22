import 'package:flutter/material.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';

typedef SummaryBuilder = Widget Function(SavedBirthdate saved, {required bool openMilestone});

Widget buildSummaryPage(SavedBirthdate saved, {required bool openMilestone}) =>
    SummaryPage(birthDate: saved.date, birthTime: saved.time, openMilestone: openMilestone);

/// Leva o toque na notificação de um marco até o card "Próximo marco" do resumo.
class NotificationRouter {
  NotificationRouter({
    required this.navigatorKey,
    required this.profile,
    required this.analytics,
    this.summaryBuilder = buildSummaryPage,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final LifeProfileService profile;
  final MilestoneAnalytics analytics;
  final SummaryBuilder summaryBuilder;

  /// App fechado: [payload] é o da notificação que abriu o app. Registra o evento e diz se o app deve
  /// abrir direto no card do marco (a navegação em si é feita pelo `MyApp`).
  bool handleLaunch(String? payload) {
    final kind = parseMilestonePayload(payload);
    if (kind == null) return false;
    analytics.logMilestoneNotificationOpened(kind.name);
    return profile.saved != null;
  }

  /// App aberto ou em segundo plano: registra o evento e abre o card do marco.
  void open(String? payload) {
    if (!handleLaunch(payload)) return;
    final saved = profile.saved!;
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => summaryBuilder(saved, openMilestone: true)),
      (route) => false,
    );
  }
}
