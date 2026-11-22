import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Eventos do fluxo "data salva + marcos de vida". Uma interface à parte para os testes não
/// precisarem do Firebase.
abstract interface class MilestoneAnalytics {
  /// [source]: `manual` (o usuário escolheu salvar) ou `reminder` (salva ao ativar o lembrete).
  Future<void> logBirthdateSaved({required String source});

  /// [milestone] é o próximo marco; [scheduled] quantos lembretes foram agendados.
  Future<void> logMilestoneReminderEnabled({required String milestone, required int scheduled});

  Future<void> logNotificationPermissionResult({required bool granted});

  Future<void> logMilestoneNotificationOpened(String milestone);
}

class AnalyticsService implements MilestoneAnalytics {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  /// Helper to print debug information to console
  void _printDebug(String eventName, [Map<String, dynamic>? parameters]) {
    if (parameters != null && parameters.isNotEmpty) {
      debugPrint('📊 [AnalyticsService] Logged event: "$eventName" with parameters: $parameters');
    } else {
      debugPrint('📊 [AnalyticsService] Logged event: "$eventName"');
    }
  }

  /// Logs when the user starts the onboarding flow
  Future<void> logOnboardingStarted() async {
    _printDebug('onboarding_started');
    await _analytics.logEvent(name: 'onboarding_started');
  }

  /// Logs when the user views a specific onboarding step
  Future<void> logOnboardingStepViewed(int stepIndex) async {
    _printDebug('onboarding_step_viewed', {'step_index': stepIndex});
    await _analytics.logEvent(
      name: 'onboarding_step_viewed',
      parameters: {'step_index': stepIndex},
    );
  }

  /// Logs when the user skips onboarding
  Future<void> logOnboardingSkipped(int stepIndex) async {
    _printDebug('onboarding_skipped', {'step_index': stepIndex});
    await _analytics.logEvent(
      name: 'onboarding_skipped',
      parameters: {'step_index': stepIndex},
    );
  }

  /// Logs when the user completes onboarding
  Future<void> logOnboardingCompleted() async {
    _printDebug('onboarding_completed');
    await _analytics.logEvent(name: 'onboarding_completed');
  }

  /// Logs when the user submits their birthdate
  Future<void> logBirthdateSubmitted({required int age, required bool hasBirthTime}) async {
    _printDebug('birthdate_submitted', {
      'age': age,
      'has_birth_time': hasBirthTime ? 1 : 0,
    });
    await _analytics.logEvent(
      name: 'birthdate_submitted',
      parameters: {
        'age': age,
        'has_birth_time': hasBirthTime ? 1 : 0,
      },
    );
  }

  /// Logs when the user views the summary page
  Future<void> logSummaryViewed(int age) async {
    _printDebug('summary_viewed', {'age': age});
    await _analytics.logEvent(
      name: 'summary_viewed',
      parameters: {'age': age},
    );
  }

  /// Logs when the user scrolls/views a specific section in the summary page
  Future<void> logSummarySectionViewed(String sectionName, int sectionIndex) async {
    _printDebug('summary_section_viewed', {
      'section_name': sectionName,
      'section_index': sectionIndex,
    });
    await _analytics.logEvent(
      name: 'summary_section_viewed',
      parameters: {
        'section_name': sectionName,
        'section_index': sectionIndex,
      },
    );
  }

  /// Logs when the user taps a share button (opens the card preview)
  Future<void> logShareTapped(String sectionName) async {
    _printDebug('share_tapped', {'section_name': sectionName});
    await _analytics.logEvent(
      name: 'share_tapped',
      parameters: {'section_name': sectionName},
    );
  }

  /// Logs when the user finishes sharing a card (the native share sheet was not dismissed)
  Future<void> logShareCompleted(String sectionName) async {
    _printDebug('share_completed', {'section_name': sectionName});
    await _analytics.logEvent(
      name: 'share_completed',
      parameters: {'section_name': sectionName},
    );
  }

  /// Logs when the user changes the application theme
  Future<void> logThemeChanged(String themeMode) async {
    _printDebug('theme_changed', {'theme_mode': themeMode});
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {'theme_mode': themeMode},
    );
  }

  /// Logs when an interstitial ad loads successfully
  Future<void> logAdLoaded() async {
    _printDebug('ad_loaded');
    await _analytics.logEvent(name: 'ad_loaded');
  }

  /// Logs when an interstitial ad is shown to the user
  Future<void> logAdShown() async {
    _printDebug('ad_shown');
    await _analytics.logEvent(name: 'ad_shown');
  }

  /// Logs when an interstitial ad is dismissed
  Future<void> logAdDismissed() async {
    _printDebug('ad_dismissed');
    await _analytics.logEvent(name: 'ad_dismissed');
  }

  @override
  Future<void> logBirthdateSaved({required String source}) async {
    _printDebug('birthdate_saved', {'source': source});
    await _analytics.logEvent(name: 'birthdate_saved', parameters: {'source': source});
  }

  @override
  Future<void> logMilestoneReminderEnabled({required String milestone, required int scheduled}) async {
    _printDebug('milestone_reminder_enabled', {'milestone': milestone, 'scheduled': scheduled});
    await _analytics.logEvent(
      name: 'milestone_reminder_enabled',
      parameters: {'milestone': milestone, 'scheduled': scheduled},
    );
  }

  @override
  Future<void> logNotificationPermissionResult({required bool granted}) async {
    _printDebug('notification_permission_result', {'granted': granted ? 1 : 0});
    await _analytics.logEvent(
      name: 'notification_permission_result',
      parameters: {'granted': granted ? 1 : 0},
    );
  }

  @override
  Future<void> logMilestoneNotificationOpened(String milestone) async {
    _printDebug('milestone_notification_opened', {'milestone': milestone});
    await _analytics.logEvent(
      name: 'milestone_notification_opened',
      parameters: {'milestone': milestone},
    );
  }
}
