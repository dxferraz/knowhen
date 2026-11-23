import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/analytics_service.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeFirebaseAnalytics firebase;
  late AnalyticsService analytics;

  setUp(() {
    firebase = FakeFirebaseAnalytics();
    analytics = AnalyticsService(firebase);
  });

  void expectSingleEvent(String name, [Map<String, Object>? parameters]) {
    expect(firebase.events, hasLength(1));
    expect(firebase.events.single.name, name);
    expect(firebase.events.single.parameters, parameters);
  }

  test('onboarding events', () async {
    await analytics.logOnboardingStarted();
    await analytics.logOnboardingStepViewed(1);
    await analytics.logOnboardingSkipped(1);
    await analytics.logOnboardingCompleted();

    expect(firebase.names, ['onboarding_started', 'onboarding_step_viewed', 'onboarding_skipped', 'onboarding_completed']);
    expect(firebase.events[1].parameters, {'step_index': 1});
    expect(firebase.events[2].parameters, {'step_index': 1});
  });

  test('birthdate_submitted sends has_birth_time as 0/1', () async {
    await analytics.logBirthdateSubmitted(age: 30, hasBirthTime: true);
    expectSingleEvent('birthdate_submitted', {'age': 30, 'has_birth_time': 1});

    firebase.events.clear();
    await analytics.logBirthdateSubmitted(age: 30, hasBirthTime: false);
    expectSingleEvent('birthdate_submitted', {'age': 30, 'has_birth_time': 0});
  });

  test('summary events', () async {
    await analytics.logSummaryViewed(42);
    expectSingleEvent('summary_viewed', {'age': 42});

    firebase.events.clear();
    await analytics.logSummarySectionViewed('moon_phase', 2);
    expectSingleEvent('summary_section_viewed', {'section_name': 'moon_phase', 'section_index': 2});
  });

  test('theme_changed', () async {
    await analytics.logThemeChanged('dark');
    expectSingleEvent('theme_changed', {'theme_mode': 'dark'});
  });

  test('ad events', () async {
    await analytics.logAdLoaded(format: AdFormat.interstitial);
    await analytics.logAdShown(format: AdFormat.native);
    await analytics.logAdDismissed();

    expect(firebase.names, ['ad_loaded', 'ad_shown', 'ad_dismissed']);
    expect(firebase.events[0].parameters, {'ad_format': 'interstitial'});
    expect(firebase.events[1].parameters, {'ad_format': 'native'});
    expect(firebase.events[2].parameters, isNull);
  });
}
