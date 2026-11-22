import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/int_formatter.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formats integers with the pt-BR thousands separator', () {
    expect(IntFormatter.format(0), '0');
    expect(IntFormatter.format(999), '999');
    expect(IntFormatter.format(1000), '1.000');
    expect(IntFormatter.format(1234567), '1.234.567');
  });
}
