import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

/// The same providers as `main.dart`, backed by fakes.
class TestDependencies {
  TestDependencies({BrazilCuriositiesRepository? repository, AdService? adService})
      : repository = repository ?? FakeBrazilCuriositiesRepository(),
        adService = adService ?? FakeAdService();

  final FakeFirebaseAnalytics firebaseAnalytics = FakeFirebaseAnalytics();
  final AdService adService;
  final BrazilCuriositiesRepository repository;

  late final AnalyticsService analytics = AnalyticsService(firebaseAnalytics);

  Widget wrap(Widget child) => MultiProvider(
        providers: [
          Provider<AnalyticsService>.value(value: analytics),
          Provider<AdService>.value(value: adService),
          Provider<BrazilCuriositiesRepository>.value(value: repository),
          ChangeNotifierProvider(create: (_) => ThemeProvider(analytics)),
        ],
        child: child,
      );
}

/// The app strings, so tests don't depend on how the `.arb` encodes accents.
final l10n = lookupAppLocalizations(const Locale('pt'));

extension PumpApp on WidgetTester {
  /// Pumps [home] on a large phone screen (430x932). The default 800x600 test view is too short, and the
  /// test font draws every glyph as a full square, so the onboarding steps overflow on smaller phones.
  Future<void> pumpApp(Widget home, TestDependencies deps) {
    view.physicalSize = const Size(1290, 2796);
    view.devicePixelRatio = 3;
    addTearDown(view.reset);

    return pumpWidget(
      deps.wrap(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
  }
}
