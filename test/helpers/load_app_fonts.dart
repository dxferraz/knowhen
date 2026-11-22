import 'dart:convert';

import 'package:flutter/services.dart';

/// Carrega as fontes declaradas em `pubspec.yaml` (via `FontManifest.json`), que o `flutter test` não
/// carrega sozinho: sem isto todo texto sai na fonte de teste (Ahem). Devolve `família -> arquivos`.
Future<Map<String, List<String>>> loadAppFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  final families = <String, List<String>>{};

  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      final asset = font['asset'] as String;
      loader.addFont(rootBundle.load(asset));
      families.putIfAbsent(family, () => []).add(asset);
    }
    await loader.load();
  }
  return families;
}
