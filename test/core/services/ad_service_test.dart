import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseAnalytics firebaseAnalytics;
  late FakeAdLoader loader;
  late AdService service;

  setUp(() {
    firebaseAnalytics = FakeFirebaseAnalytics();
    loader = FakeAdLoader();
    service = AdService(AnalyticsService(firebaseAnalytics), loader: loader.call);
  });

  test('loads the ad and logs it', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    expect(service.isAdLoaded, isTrue);
    expect(firebaseAnalytics.names, ['ad_loaded']);
  });

  test('a load already in progress is shared, not repeated', () async {
    final first = service.loadAd();
    final second = service.loadAd();

    expect(loader.requests, hasLength(1));

    final ad = FakeInterstitialAd();
    loader.requests.single.onAdLoaded(ad);
    await Future.wait([first, second]);

    expect(service.isAdLoaded, isTrue);
    expect(ad.disposeCalls, 0);
    expect(firebaseAnalytics.names, ['ad_loaded']);
  });

  test('loading again while an ad is ready keeps it and does not request another', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    // The user leaves and reopens the summary: the app-wide service is asked to load again.
    await service.loadAd();

    expect(loader.requests, hasLength(1));
    expect(ad.disposeCalls, 0);

    await service.showAd();
    expect(ad.showCalls, 1);
  });

  test('a failed load completes and the next call tries again', () async {
    final failed = service.loadAd();
    loader.requests.single.onAdFailedToLoad(LoadAdError(3, 'domain', 'no fill', null));
    await failed;

    expect(service.isAdLoaded, isFalse);

    final retry = service.loadAd();
    expect(loader.requests, hasLength(2));
    loader.requests.last.onAdLoaded(FakeInterstitialAd());
    await retry;
    expect(service.isAdLoaded, isTrue);
  });

  test('a loader that throws does not hang the caller or block later loads', () async {
    final throwing = AdService(
      AnalyticsService(firebaseAnalytics),
      loader: (_, _) => throw StateError('plugin missing'),
    );

    await throwing.loadAd();
    expect(throwing.isAdLoaded, isFalse);
    await throwing.loadAd();
  });

  test('an ad can only be shown once, even when showAd is called twice in a row', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    await Future.wait([service.showAd(), service.showAd()]);

    expect(ad.showCalls, 1);
    expect(service.isAdLoaded, isFalse);
    expect(firebaseAnalytics.names, ['ad_loaded', 'ad_shown']);
  });

  test('dismissing the ad disposes it and preloads the next one', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    await service.showAd();
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    await pumpEventQueue();

    expect(ad.disposeCalls, 1);
    expect(loader.requests, hasLength(2));
    expect(firebaseAnalytics.names, containsAllInOrder(['ad_shown', 'ad_dismissed']));
  });

  test('reopening the summary right after a dismiss shares the preload instead of starting a second one', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    await service.showAd();
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    await pumpEventQueue();

    final reopened = service.loadAd();
    expect(loader.requests, hasLength(2));

    final next = FakeInterstitialAd();
    loader.requests.last.onAdLoaded(next);
    await reopened;

    expect(service.isAdLoaded, isTrue);
    expect(next.disposeCalls, 0);
  });

  test('showAd without a loaded ad does nothing', () async {
    await service.showAd();

    expect(firebaseAnalytics.events, isEmpty);
  });
}
