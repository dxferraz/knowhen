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

  Future<ThemeProvider> load(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final provider = ThemeProvider(AnalyticsService(firebase));
    await pumpEventQueue();
    return provider;
  }

  test('primeira abertura segue o tema do sistema', () async {
    final provider = await load({});
    expect(provider.themeMode, ThemeMode.system);
  });

  test('escolha salva como escuro é respeitada', () async {
    final provider = await load({'isDarkMode': true});
    expect(provider.themeMode, ThemeMode.dark);
  });

  test('escolha salva como claro é respeitada', () async {
    final provider = await load({'isDarkMode': false});
    expect(provider.themeMode, ThemeMode.light);
  });

  test('toggleTheme saves the choice and logs theme_changed', () async {
    final provider = await load({});

    provider.toggleTheme(false);
    await pumpEventQueue();

    expect(provider.themeMode, ThemeMode.light);
    expect((await SharedPreferences.getInstance()).getBool('isDarkMode'), isFalse);
    expect(firebase.events.single.name, 'theme_changed');
    expect(firebase.events.single.parameters, {'theme_mode': 'light'});
  });
}
