/// Estimated conception window: an average pregnancy lasts 280 days, give or take a week.
///
/// Uses calendar days (not `Duration`) so a DST change between the two dates cannot
/// shift the result to the previous day.
({DateTime start, DateTime end}) conceptionWindow(DateTime birthDate) {
  DateTime daysBeforeBirth(int days) => DateTime(birthDate.year, birthDate.month, birthDate.day - days);

  return (start: daysBeforeBirth(280 + 7), end: daysBeforeBirth(280 - 7));
}
