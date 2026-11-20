import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/ad_service.dart';
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
  int showCalls = 0;

  @override
  Future<void> loadAd() async => loadCalls++;

  @override
  void showAd() => showCalls++;
}

class FakeBrazilCuriositiesRepository implements BrazilCuriositiesRepository {
  FakeBrazilCuriositiesRepository({this.curiosity, this.imageUrl = 'https://example.com/image.png', this.error, this.wait});

  final BrazilCuriosityDTO? curiosity;
  final String imageUrl;
  final Object? error;

  /// When set, the curiosity only arrives after it completes (to observe the loading state).
  final Completer<void>? wait;

  final List<DateTime> requestedDates = [];

  @override
  Future<BrazilCuriosityDTO> getBrazilCuriosity(DateTime birthDate) async {
    requestedDates.add(birthDate);
    await wait?.future;
    if (error != null) throw error!;
    return curiosity ?? sampleCuriosity(year: '${birthDate.year}', month: '${birthDate.month}');
  }

  @override
  Future<String> getCuriosityImage(String year, String month) async {
    if (error != null) throw error!;
    return imageUrl;
  }
}

BrazilCuriosityDTO sampleCuriosity({String year = '1990', String month = '5'}) => BrazilCuriosityDTO(
      fact: 'Um fato curioso de $month/$year',
      imageUrl: '',
      month: month,
      year: year,
    );
