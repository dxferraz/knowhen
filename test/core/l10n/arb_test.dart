import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final arb = jsonDecode(File('lib/core/l10n/arb/app_pt.arb').readAsStringSync()) as Map<String, dynamic>;
  final messages = {
    for (final entry in arb.entries)
      if (!entry.key.startsWith('@') && entry.value is String) entry.key: entry.value as String,
  };

  // "ó" can be written as one code point or as "o" + a combining accent. Both render the same,
  // but only the first one matches the strings in the code and the tests.
  test('accents use precomposed characters', () {
    final combiningAccent = RegExp('[̀-ͯ]');
    final decomposed = messages.entries.where((e) => combiningAccent.hasMatch(e.value)).map((e) => e.key);

    expect(decomposed, isEmpty);
  });

  test('every message has its metadata entry', () {
    final missing = messages.keys.where((key) => !arb.containsKey('@$key'));

    expect(missing, isEmpty);
  });

  // Typos and copy we already replaced; they must not come back.
  test('retired copy stays out', () {
    const retired = ['provavavelmente', 'cegonha'];
    final offenders = messages.entries.where((e) => retired.any(e.value.toLowerCase().contains)).map((e) => e.key);

    expect(offenders, isEmpty);
  });

  test('copy has no double spaces or stray edge whitespace', () {
    final offenders = messages.entries.where((e) => e.value.contains('  ') || e.value != e.value.trim()).map((e) => e.key);

    expect(offenders, isEmpty);
  });
}
