import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

/// The app strings, so tests don't depend on how the `.arb` encodes accents.
final l10n = lookupAppLocalizations(const Locale('pt'));

extension PumpApp on WidgetTester {
  /// Pumps [home] on a large phone screen (430x932). The default 800x600 test view is too short, and the
  /// test font draws every glyph as a full square, so text-heavy sections overflow on smaller phones.
  Future<void> pumpApp(Widget home) {
    view.physicalSize = const Size(1290, 2796);
    view.devicePixelRatio = 3;
    addTearDown(view.reset);

    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: home),
      ),
    );
  }
}
