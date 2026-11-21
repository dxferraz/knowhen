import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  final birthDate = DateTime(1990, 5, 20);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('loads the summary, shows the first section and loads the ad', (tester) async {
    final curiosity = Completer<void>();
    final deps = TestDependencies(repository: FakeBrazilCuriositiesRepository(wait: curiosity));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    curiosity.complete();
    await tester.pumpAndSettle();

    expect(find.text(l10n.summaryPageTitle('20/05/1990')), findsOneWidget);
    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    final adService = deps.adService as FakeAdService;
    expect(adService.loadCalls, 1);
    expect(adService.showCalls, 1);
    expect(deps.firebaseAnalytics.names, ['summary_viewed', 'summary_section_viewed']);
    expect(deps.firebaseAnalytics.events.last.parameters, {'section_name': 'years_of_life', 'section_index': 0});
  });

  testWidgets('keeps the summary when the curiosity fails to load', (tester) async {
    final deps = TestDependencies(repository: FakeBrazilCuriositiesRepository(curiosityError: StateError('No element')));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    expect(find.textContaining('No element'), findsNothing);
  });

  testWidgets('opening the summary twice reuses the app-wide ad instead of loading or leaking another', (tester) async {
    final loader = FakeAdLoader();
    final firebaseAnalytics = FakeFirebaseAnalytics();
    final adService = AdService(AnalyticsService(firebaseAnalytics), loader: loader.call);
    final deps = TestDependencies(adService: adService);
    final ad = FakeInterstitialAd();
    // showAd() toggles the system UI mode; answer it so the call completes under the fake clock.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    // First visit: the load starts and the ad is shown once it arrives.
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(loader.requests, hasLength(1));
    loader.requests.single.onAdLoaded(ad);
    await tester.idle();
    await tester.pumpAndSettle(); // runs the post-frame callback that shows the ad
    await tester.idle();
    expect(ad.showCalls, 1);

    // The user dismisses the ad, which preloads the next one, and leaves the summary.
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    await tester.pump();
    expect(loader.requests, hasLength(2));
    await tester.pumpWidget(const SizedBox());

    // Second visit while that preload is still in flight: no third request, no overwrite.
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(loader.requests, hasLength(2));

    final next = FakeInterstitialAd();
    loader.requests.last.onAdLoaded(next);
    await tester.idle();
    await tester.pumpAndSettle(); // runs the post-frame callback that shows the ad
    await tester.idle();
    expect(next.showCalls, 1);
    expect(next.disposeCalls, 0);
    expect(ad.disposeCalls, 1);
    expect(ad.showCalls, 1);
  });
}
