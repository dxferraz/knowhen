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

    await service.showInterstitialIfDue();
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

  test('an ad can only be shown once, even when showInterstitialIfDue is called twice in a row', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    await Future.wait([service.showInterstitialIfDue(), service.showInterstitialIfDue()]);

    expect(ad.showCalls, 1);
    expect(service.isAdLoaded, isFalse);
    expect(firebaseAnalytics.names, ['ad_loaded', 'ad_shown']);
  });

  test('dismissing the ad disposes it and preloads the next one', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;

    await service.showInterstitialIfDue();
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

    await service.showInterstitialIfDue();
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

  test('without a loaded ad showInterstitialIfDue does nothing', () async {
    await service.showInterstitialIfDue();

    expect(firebaseAnalytics.events, isEmpty);
  });

  group('interstitial interval', () {
    late DateTime now;
    late AdService timed;

    setUp(() {
      now = DateTime(2026, 11, 23, 10);
      timed = AdService(AnalyticsService(firebaseAnalytics), loader: loader.call, now: () => now);
    });

    Future<FakeInterstitialAd> loadOne() async {
      final ad = FakeInterstitialAd();
      final loading = timed.loadAd();
      loader.requests.last.onAdLoaded(ad);
      await loading;
      return ad;
    }

    test('a second interstitial inside the interval is held back, not lost or disposed', () async {
      final first = await loadOne();
      expect(await timed.showInterstitialIfDue(), isTrue);
      first.fullScreenContentCallback!.onAdDismissedFullScreenContent!(first);
      await pumpEventQueue();
      final second = await loadOne();

      now = now.add(const Duration(minutes: 2, seconds: 59));
      expect(timed.isInterstitialDue, isFalse);
      expect(await timed.showInterstitialIfDue(), isFalse);
      expect(second.showCalls, 0);
      expect(second.disposeCalls, 0);
      expect(timed.isAdLoaded, isTrue);

      now = now.add(const Duration(seconds: 1));
      expect(timed.isInterstitialDue, isTrue);
      expect(await timed.showInterstitialIfDue(), isTrue);
      expect(second.showCalls, 1);
    });

    test('the first interstitial is not held back', () async {
      final ad = await loadOne();

      expect(timed.isInterstitialDue, isTrue);
      expect(await timed.showInterstitialIfDue(), isTrue);
      expect(ad.showCalls, 1);
    });

    test('nothing is due without a loaded ad', () {
      expect(timed.isInterstitialDue, isFalse);
    });
  });

  test('the ad events carry the format', () async {
    final ad = FakeInterstitialAd();
    final loading = service.loadAd();
    loader.requests.single.onAdLoaded(ad);
    await loading;
    await service.showInterstitialIfDue();

    expect(firebaseAnalytics.names, ['ad_loaded', 'ad_shown']);
    expect(firebaseAnalytics.events.map((e) => e.parameters), [
      {'ad_format': 'interstitial'},
      {'ad_format': 'interstitial'},
    ]);
  });

  group('test devices', () {
    test('a debug build declares the developer device', () {
      expect(AdService.requestConfiguration(debug: true).testDeviceIds, ['9C1FE904906DF4C7D5C7E2287B821399']);
    });

    test('a release build declares none', () {
      expect(AdService.requestConfiguration(debug: false).testDeviceIds, isEmpty);
    });
  });

  group('native ad', () {
    late FakeNativeAdLoader nativeLoader;
    late AdService withNative;
    final style = NativeTemplateStyle(templateType: TemplateType.small);

    setUp(() {
      nativeLoader = FakeNativeAdLoader();
      withNative = AdService(
        AnalyticsService(firebaseAnalytics),
        nativeLoader: nativeLoader.call,
        release: true,
        releaseNativeAdUnitId: 'unit-1',
      );
    });

    test('hands the loaded ad to the caller and logs it with the native format', () async {
      final loading = withNative.loadNativeAd(style);
      final request = nativeLoader.requests.single;
      expect(request.adUnitId, 'unit-1');
      request.listener.onAdLoaded!(request.ad);

      expect(await loading, same(request.ad));
      expect(request.ad.disposeCalls, 0);
      expect(firebaseAnalytics.events.single.name, 'ad_loaded');
      expect(firebaseAnalytics.events.single.parameters, {'ad_format': 'native'});
    });

    test('logs ad_shown on the impression, not on the load', () async {
      final loading = withNative.loadNativeAd(style);
      final request = nativeLoader.requests.single;
      request.listener.onAdLoaded!(request.ad);
      await loading;
      expect(firebaseAnalytics.names, ['ad_loaded']);

      request.listener.onAdImpression!(request.ad);
      expect(firebaseAnalytics.names, ['ad_loaded', 'ad_shown']);
      expect(firebaseAnalytics.events.last.parameters, {'ad_format': 'native'});
    });

    test('a failed request completes with null and disposes the ad', () async {
      final loading = withNative.loadNativeAd(style);
      final request = nativeLoader.requests.single;
      request.listener.onAdFailedToLoad!(request.ad, LoadAdError(3, 'domain', 'no fill', null));

      expect(await loading, isNull);
      expect(request.ad.disposeCalls, 1);
      expect(firebaseAnalytics.events, isEmpty);
    });

    test('a loader that throws completes with null', () async {
      final throwing = AdService(
        AnalyticsService(firebaseAnalytics),
        nativeLoader: (_, _, _) => throw StateError('plugin missing'),
        release: true,
        releaseNativeAdUnitId: 'unit-1',
      );

      expect(await throwing.loadNativeAd(style), isNull);
    });

    test('a release build without a native unit requests nothing', () async {
      final unitless = AdService(AnalyticsService(firebaseAnalytics), nativeLoader: nativeLoader.call, release: true);

      expect(unitless.nativeAdUnitId, isNull);
      expect(await unitless.loadNativeAd(style), isNull);
      expect(nativeLoader.requests, isEmpty);
    });

    test('a build that is not a release uses the Google test units, never the real one', () {
      final debug = AdService(AnalyticsService(firebaseAnalytics), releaseNativeAdUnitId: 'real-native');
      final release = AdService(AnalyticsService(firebaseAnalytics), release: true, releaseNativeAdUnitId: 'real-native');

      expect(debug.nativeAdUnitId, startsWith('ca-app-pub-3940256099942544/'));
      expect(debug.interstitialAdUnitId, startsWith('ca-app-pub-3940256099942544/'));
      expect(release.nativeAdUnitId, 'real-native');
      expect(release.interstitialAdUnitId, startsWith('ca-app-pub-3761849151183894/'));
    });
  });
}
