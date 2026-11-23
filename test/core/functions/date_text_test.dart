import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/date_text.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt'));

  final date = DateTime(1991, 3, 14);

  test('numeric is dd/MM/yyyy', () {
    expect(DateText.numeric(date), '14/03/1991');
    expect(DateText.numeric(DateTime(2005, 1, 2)), '02/01/2005');
  });

  test('long spells the weekday and month in Portuguese, capitalized', () {
    expect(DateText.long(date), 'Quinta-feira, 14 de março de 1991');
    expect(DateText.long(DateTime(2024, 2, 29)), 'Quinta-feira, 29 de fevereiro de 2024');
  });

  test('dayMonthYear drops the weekday', () {
    expect(DateText.dayMonthYear(date), '14 de março de 1991');
    expect(DateText.dayMonthYear(DateTime(2025, 9, 1)), '1 de setembro de 2025');
  });

  test('compact abbreviates the month without a period', () {
    expect(DateText.compact(date), '14 mar 1991');
    expect(DateText.compact(DateTime(1990, 9, 3)), '3 set 1990');
  });
}
