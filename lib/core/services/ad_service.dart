import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  final String interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-3761849151183894/4490537633'
      : 'ca-app-pub-3940256099942544/1033173712';

  Future<void> loadAd() async {
    Completer<void> completer = Completer();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Erro ao carregar anúncio: $error');
          _isAdLoaded = false;
          completer.complete();
        },
      ),
    );

    return completer.future;
  }

  void showAd() async {
    if (_isAdLoaded && _interstitialAd != null) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) async {
          ad.dispose();
          _isAdLoaded = false;
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) async {
          ad.dispose();
          _isAdLoaded = false;
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          loadAd();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      debugPrint("Anúncio não está pronto");
    }
  }
}
