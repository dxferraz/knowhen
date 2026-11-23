/// Dias entre a concepção e o nascimento: 38 semanas. A gestação de 40 semanas (280 dias) conta desde a última
/// menstruação, cerca de duas semanas antes da concepção.
const int conceptionDaysBeforeBirth = 266;

/// Estimated conception window: [conceptionDaysBeforeBirth] days before birth, give or take a week.
///
/// Uses calendar days (not `Duration`) so a DST change between the two dates cannot
/// shift the result to the previous day.
({DateTime start, DateTime end}) conceptionWindow(DateTime birthDate) {
  DateTime daysBeforeBirth(int days) => DateTime(birthDate.year, birthDate.month, birthDate.day - days);

  return (start: daysBeforeBirth(conceptionDaysBeforeBirth + 7), end: daysBeforeBirth(conceptionDaysBeforeBirth - 7));
}
