import 'package:flutter/material.dart';

/// Por que o texto digitado nos campos Dia, Mês e Ano ainda não vira uma data.
enum BirthdateError {
  /// O dia ou o mês não existe (31/02, mês 13, dia 0).
  invalid,

  /// A data é depois de hoje.
  future,

  /// O ano é anterior a [BirthdateInput.firstYear].
  tooOld,
}

/// Resultado de ler os campos Dia, Mês e Ano. Tem [date] quando a data é válida e [error] quando os três
/// campos estão completos mas a data não é aceita. Com campos incompletos não tem nenhum dos dois.
class BirthdateInput {
  const BirthdateInput._({this.date, this.error});

  final DateTime? date;
  final BirthdateError? error;

  /// Primeiro ano aceito (DXF-9, 4.2).
  static const int firstYear = 1900;

  static const BirthdateInput incomplete = BirthdateInput._();

  /// Lê o que foi digitado. O ano só conta com 4 dígitos, então "19" não é tratado como o ano 19. A data
  /// de hoje é aceita; não há limite superior fixo, para quem nasceu depois de qualquer data de lançamento.
  factory BirthdateInput.parse(
    String day,
    String month,
    String year, {
    required DateTime now,
  }) {
    if (day.isEmpty || month.isEmpty || year.length != 4) return incomplete;

    final d = int.tryParse(day);
    final m = int.tryParse(month);
    final y = int.tryParse(year);
    if (d == null || m == null || y == null) return incomplete;

    if (y < firstYear) {
      return const BirthdateInput._(error: BirthdateError.tooOld);
    }
    if (m < 1 || m > 12 || d < 1 || d > DateUtils.getDaysInMonth(y, m)) {
      return const BirthdateInput._(error: BirthdateError.invalid);
    }

    final date = DateTime(y, m, d);
    if (date.isAfter(DateUtils.dateOnly(now))) {
      return const BirthdateInput._(error: BirthdateError.future);
    }
    return BirthdateInput._(date: date);
  }
}
