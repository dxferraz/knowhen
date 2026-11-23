import 'package:intl/intl.dart';

/// Dates as written in the app, always in Brazilian Portuguese whatever the device locale.
///
/// `initializeDateFormatting('pt')` must have run first (`main` does it; tests do it in `setUpAll`).
abstract final class DateText {
  static const _locale = 'pt';

  /// `14/03/1991`.
  static String numeric(DateTime date) => DateFormat('dd/MM/yyyy', _locale).format(date);

  /// `Quinta-feira, 14 de março de 1991`.
  static String long(DateTime date) {
    final text = DateFormat("EEEE, d 'de' MMMM 'de' y", _locale).format(date);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// `14 de março de 1991`.
  static String dayMonthYear(DateTime date) => DateFormat("d 'de' MMMM 'de' y", _locale).format(date);

  /// `14 mar 1991`, without the period `intl` puts after the abbreviated month.
  static String compact(DateTime date) => DateFormat('d MMM y', _locale).format(date).replaceAll('.', '');
}
