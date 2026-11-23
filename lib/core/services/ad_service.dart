import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/services/analytics_service.dart';

/// Requests an interstitial from AdMob. Replaceable so tests don't need the Google Mobile Ads plugin.
typedef InterstitialLoader = void Function(String adUnitId, InterstitialAdLoadCallback callback);

void _loadInterstitial(String adUnitId, InterstitialAdLoadCallback callback) {
  InterstitialAd.load(adUnitId: adUnitId, request: const AdRequest(), adLoadCallback: callback);
}

/// One instance serves the whole app (see `main.dart`), so [loadAd] can be called again while an ad is
/// already loaded or loading (e.g. reopening the summary): it never starts a second request or replaces
/// an ad that has not been shown yet.
class AdService {
  AdService(this._analytics, {InterstitialLoader loader = _loadInterstitial}) : _loader = loader;

  final AnalyticsService _analytics;
  final InterstitialLoader _loader;
  InterstitialAd? _interstitialAd;
  Future<void>? _loading;
  final String interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-3761849151183894/4490537633'
      : 'ca-app-pub-3940256099942544/1033173712';

  bool get isAdLoaded => _interstitialAd != null;

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
            _analytics.logAdLoaded();
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

  Future<void> showAd() async {
    final ad = _interstitialAd;
    if (ad == null) {
      debugPrint("Anúncio não está pronto");
      return;
    }
    // An ad can only be shown once: hand it over before any await so a concurrent showAd() finds nothing.
    _interstitialAd = null;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) async {
        ad.dispose();
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _analytics.logAdDismissed();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) async {
        ad.dispose();
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        loadAd();
      },
    );

    _analytics.logAdShown();
    ad.show();
  }
}
