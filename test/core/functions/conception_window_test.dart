import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/conception_window.dart';

void main() {
  group('conceptionWindow', () {
    test('is 280 days before birth, plus or minus 7 days', () {
      final window = conceptionWindow(DateTime(2000, 10, 10));

      // 2000-10-10 minus 280 days = 2000-01-04.
      expect(window.start, DateTime(1999, 12, 28));
      expect(window.end, DateTime(2000, 1, 11));
    });

    test('spans 14 calendar days', () {
      final window = conceptionWindow(DateTime(1990, 5, 20));

      expect(DateTime.utc(window.end.year, window.end.month, window.end.day).difference(DateTime.utc(window.start.year, window.start.month, window.start.day)).inDays, 14);
    });

    test('handles leap years', () {
      // 2024-12-05 minus 280 days = 2024-02-29.
      final window = conceptionWindow(DateTime(2024, 12, 5));

      expect(window.start, DateTime(2024, 2, 22));
      expect(window.end, DateTime(2024, 3, 7));
    });

    test('ignores the time of birth and returns midnight dates', () {
      final window = conceptionWindow(DateTime(2000, 10, 10, 23, 59));

      expect(window.start, DateTime(1999, 12, 28));
      expect(window.end, DateTime(2000, 1, 11));
    });
  });
}
