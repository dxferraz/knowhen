import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';
import 'package:knowhen/features/brazil_curiosity/data/dtos/brazil_curiosity_dto.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';

typedef LoggedEvent = ({String name, Map<String, Object>? parameters});

/// Records the events instead of sending them to Firebase.
class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final List<LoggedEvent> events = [];

  List<String> get names => events.map((e) => e.name).toList();

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add((name: name, parameters: parameters));
  }
}

/// Never touches the Google Mobile Ads plugin.
class FakeAdService extends Fake implements AdService {
  int loadCalls = 0;
  int interstitialCalls = 0;
  final List<NativeTemplateStyle> nativeRequests = [];

  /// The native ad handed to the page; `null` simulates "no fill".
  NativeAd? nativeAd;

  /// When set, the native ad only arrives once it completes (the page may be gone by then).
  Completer<void>? nativeGate;

  @override
  Future<void> loadAd() async => loadCalls++;

  @override
  Future<bool> showInterstitialIfDue() async {
    interstitialCalls++;
    return true;
  }

  @override
  Future<NativeAd?> loadNativeAd(NativeTemplateStyle style) async {
    nativeRequests.add(style);
    await nativeGate?.future;
    return nativeAd;
  }

  @override
  Widget nativeAdView(NativeAd ad) => const SizedBox(key: Key('fake_native_ad_view'));
}

/// Stands in for a native ad the plugin would hand to `onAdLoaded`.
class FakeNativeAd extends Fake implements NativeAd {
  int disposeCalls = 0;

  @override
  Future<void> dispose() async => disposeCalls++;
}

/// Stands in for an ad the plugin would hand to `onAdLoaded`.
class FakeInterstitialAd extends Fake implements InterstitialAd {
  int showCalls = 0;
  int disposeCalls = 0;

  @override
  FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback;

  @override
  Future<void> show() async => showCalls++;

  @override
  Future<void> dispose() async => disposeCalls++;
}

/// Records each ad request; the test decides when (and how) each one finishes.
class FakeAdLoader {
  final List<InterstitialAdLoadCallback> requests = [];

  void call(String adUnitId, InterstitialAdLoadCallback callback) => requests.add(callback);
}

/// Like [FakeAdLoader], for native ads: records the unit and the listener, and hands back a [FakeNativeAd].
class FakeNativeAdLoader {
  final List<({String adUnitId, NativeAdListener listener, FakeNativeAd ad})> requests = [];

  NativeAd call(String adUnitId, NativeAdListener listener, NativeTemplateStyle style) {
    final ad = FakeNativeAd();
    requests.add((adUnitId: adUnitId, listener: listener, ad: ad));
    return ad;
  }
}

class FakeBrazilCuriositiesRepository implements BrazilCuriositiesRepository {
  FakeBrazilCuriositiesRepository({
    this.curiosity,
    this.hasCuriosity = true,
    this.imageUrl = 'https://example.com/image.png',
    this.curiosityError,
    this.imageError,
    this.wait,
    this.imageWait,
    this.failFirstCuriosity = false,
    this.retryGate,
  });

  /// The curiosity returned; defaults to [sampleCuriosity] for the requested month/year.
  final BrazilCuriosityDTO? curiosity;

  /// `false` simulates a month/year without a curiosity (the repository returns `null`).
  final bool hasCuriosity;
  final String imageUrl;
  final Object? curiosityError;
  final Object? imageError;

  /// When set, the curiosity only arrives after it completes (to observe the loading state).
  final Completer<void>? wait;

  /// Like [wait], for the image.
  final Completer<void>? imageWait;

  /// The first curiosity request fails and the following ones succeed (the "try again" flow).
  final bool failFirstCuriosity;

  /// When set, every request after the first only completes once it does.
  final Completer<void>? retryGate;

  final List<DateTime> requestedDates = [];
  int imageRequests = 0;

  @override
  Future<BrazilCuriosityDTO?> getBrazilCuriosity(DateTime birthDate) async {
    requestedDates.add(birthDate);
    await wait?.future;
    if (requestedDates.length > 1) await retryGate?.future;
    if (failFirstCuriosity && requestedDates.length == 1) throw StateError('sem rede');
    if (curiosityError != null) throw curiosityError!;
    if (!hasCuriosity) return null;
    return curiosity ?? sampleCuriosity(year: '${birthDate.year}', month: '${birthDate.month}');
  }

  @override
  Future<String> getCuriosityImage(String year, String month) async {
    imageRequests++;
    await imageWait?.future;
    if (imageError != null) throw imageError!;
    return imageUrl;
  }
}

BrazilCuriosityDTO sampleCuriosity({String year = '1990', String month = '5'}) => BrazilCuriosityDTO(
      fact: 'Um fato curioso de $month/$year',
      imageUrl: '',
      month: month,
      year: year,
    );

class FakeBirthSongRepository implements BirthSongRepository {
  FakeBirthSongRepository({this.song, this.error, this.wait});

  /// When set, the song only arrives after it completes.
  final Completer<void>? wait;

  /// `null` simulates a month/year without a song.
  final BirthSongEntity? song;
  final Object? error;

  final List<DateTime> requestedDates = [];

  @override
  Future<BirthSongEntity?> getBirthSong(DateTime birthDate) async {
    requestedDates.add(birthDate);
    await wait?.future;
    if (error != null) throw error!;
    return song;
  }
}

const sampleBirthSong = BirthSongEntity(artist: 'Tom Jobim', songName: 'Garota de Ipanema', month: '5', year: '1990');
