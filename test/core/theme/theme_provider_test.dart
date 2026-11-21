import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemeProvider> load(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final provider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
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
}
