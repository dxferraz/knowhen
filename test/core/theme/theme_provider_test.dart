import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseAnalytics firebase;

  setUp(() => firebase = FakeFirebaseAnalytics());

  test('loads the saved theme', () async {
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final provider = ThemeProvider(AnalyticsService(firebase));

    await pumpEventQueue();

    expect(provider.themeMode, ThemeMode.dark);
  });

  test('toggleTheme saves the choice and logs theme_changed', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider(AnalyticsService(firebase));
    await pumpEventQueue();

    provider.toggleTheme(false);
    await pumpEventQueue();

    expect(provider.themeMode, ThemeMode.light);
    expect((await SharedPreferences.getInstance()).getBool('isDarkMode'), isFalse);
    expect(firebase.events.single.name, 'theme_changed');
    expect(firebase.events.single.parameters, {'theme_mode': 'light'});
  });
}
