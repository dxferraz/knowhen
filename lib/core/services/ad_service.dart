import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/services/analytics_service.dart';

/// Requests an interstitial from AdMob. Replaceable so tests don't need the Google Mobile Ads plugin.
typedef InterstitialLoader =
    void Function(String adUnitId, InterstitialAdLoadCallback callback);

/// Creates a native ad and starts loading it; the result comes through the listener. Replaceable like [InterstitialLoader].
typedef NativeAdLoader =
    NativeAd Function(
      String adUnitId,
      NativeAdListener listener,
      NativeTemplateStyle style,
    );

void _loadInterstitial(String adUnitId, InterstitialAdLoadCallback callback) {
  InterstitialAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    adLoadCallback: callback,
  );
}

NativeAd _loadNative(
  String adUnitId,
  NativeAdListener listener,
  NativeTemplateStyle style,
) {
  return NativeAd(
    adUnitId: adUnitId,
    request: const AdRequest(),
    listener: listener,
    nativeTemplateStyle: style,
  )..load();
}

/// The native ad unit of the release build. AdMob has no native unit for Knowhen yet, so it comes from the build
/// (`--dart-define=NATIVE_AD_UNIT_ID=ca-app-pub-…`); without it the release build shows no native ad.
const _buildNativeAdUnitId = String.fromEnvironment('NATIVE_AD_UNIT_ID');

/// Ads policy (DXF-9, 4.11). The summary never shows an ad before its first card:
///
/// * a **native** ad sits under the actions of the last card, always;
/// * an **interstitial** only at a natural pause (leaving the summary after reaching the last card), at most once
///   per visit to the summary and never closer than [interstitialInterval] to the previous one.
///
/// One instance serves the whole app (see `main.dart`), so [loadAd] can be called again while an ad is already
/// loaded or loading (e.g. reopening the summary): it never starts a second request or replaces an ad that has not
/// been shown yet.
class AdService {
  AdService(
    this._analytics, {
    InterstitialLoader loader = _loadInterstitial,
    NativeAdLoader nativeLoader = _loadNative,
    DateTime Function() now = DateTime.now,
    bool release = kReleaseMode,
    String releaseNativeAdUnitId = _buildNativeAdUnitId,
  }) : _loader = loader,
       _nativeLoader = nativeLoader,
       _now = now,
       interstitialAdUnitId = release
           ? 'ca-app-pub-3761849151183894/4490537633'
           : 'ca-app-pub-3940256099942544/1033173712',
       // Google's test units outside a release build.
       nativeAdUnitId = release
           ? (releaseNativeAdUnitId.isEmpty ? null : releaseNativeAdUnitId)
           : 'ca-app-pub-3940256099942544/2247696110';

  /// Minimum time between two interstitials.
  static const Duration interstitialInterval = Duration(minutes: 3);

  /// The test devices are the developer's own: only a debug build declares them, so a release (or profile) build
  /// never marks its real traffic as test traffic.
  static RequestConfiguration requestConfiguration({bool debug = kDebugMode}) =>
      RequestConfiguration(
        testDeviceIds: debug
            ? const ['9C1FE904906DF4C7D5C7E2287B821399']
            : const [],
      );

  final AnalyticsService _analytics;
  final InterstitialLoader _loader;
  final NativeAdLoader _nativeLoader;
  final DateTime Function() _now;
  InterstitialAd? _interstitialAd;
  Future<void>? _loading;
  DateTime? _lastInterstitialAt;
  final String interstitialAdUnitId;

  /// `null` when there is no native unit to request (release build without `NATIVE_AD_UNIT_ID`).
  final String? nativeAdUnitId;

  bool get isAdLoaded => _interstitialAd != null;

  /// Whether [showInterstitialIfDue] would show the ad right now.
  bool get isInterstitialDue {
    final last = _lastInterstitialAt;
    return isAdLoaded &&
        (last == null || _now().difference(last) >= interstitialInterval);
  }

  Future<void> loadAd() {
    if (_interstitialAd != null) return Future.value();
    return _loading ??= _requestAd().whenComplete(() => _loading = null);
  }

  Future<void> _requestAd() {
    final completer = Completer<void>();

    try {
      _loader(
        interstitialAdUnitId,
        InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Never leak an ad we are about to forget about.
            _interstitialAd?.dispose();
            _interstitialAd = ad;
            _analytics.logAdLoaded(format: AdFormat.interstitial);
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Erro ao carregar anúncio: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      debugPrint('Erro ao carregar anúncio: $e');
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future;
  }

  /// Asks the SDK to show the interstitial if one is loaded and the interval since the last one has passed. Returns
  /// whether the request was made; `ad_shown` and the start of the interval wait for the SDK to confirm the display
  /// (`onAdShowedFullScreenContent`), so a display that fails counts for neither. Call it only at a natural pause:
  /// the policy for *when* lives with the caller, the one for *how often* lives here.
  Future<bool> showInterstitialIfDue() async {
    final ad = _interstitialAd;
    if (ad == null) {
      debugPrint('Anúncio não está pronto');
      return false;
    }
    if (!isInterstitialDue) return false;
    // An ad can only be shown once: hand it over before any await so a concurrent call finds nothing.
    _interstitialAd = null;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _lastInterstitialAt = _now();
        _analytics.logAdShown(format: AdFormat.interstitial);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) async {
        ad.dispose();
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _analytics.logAdDismissed();
        loadAd();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError error) async {
            ad.dispose();
            await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            loadAd();
          },
    );

    ad.show();
    return true;
  }

  /// Loads a native ad styled by [style]; completes with `null` when there is no unit or the request fails. The
  /// caller owns the returned ad and must `dispose` it (the service keeps no reference).
  Future<NativeAd?> loadNativeAd(NativeTemplateStyle style) {
    final unitId = nativeAdUnitId;
    if (unitId == null) return Future.value();

    final completer = Completer<NativeAd?>();
    try {
      _nativeLoader(
        unitId,
        NativeAdListener(
          onAdLoaded: (Ad ad) {
            _analytics.logAdLoaded(format: AdFormat.native);
            if (!completer.isCompleted) completer.complete(ad as NativeAd);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Erro ao carregar anúncio nativo: $error');
            ad.dispose();
            if (!completer.isCompleted) completer.complete();
          },
          // Counts only what reached the screen, not what merely loaded.
          onAdImpression: (Ad ad) =>
              _analytics.logAdShown(format: AdFormat.native),
        ),
        style,
      );
    } catch (e) {
      debugPrint('Erro ao carregar anúncio nativo: $e');
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  /// The view of a loaded native ad. Here so that tests can stand in for the platform view.
  Widget nativeAdView(NativeAd ad) => AdWidget(ad: ad);
}
