/// Name logged in `summary_section_viewed` for the page at [index] of the summary.
/// `birth_song` (index 4) only exists when there is a valid song for the birth month.
String summarySectionName(int index, {required bool isOver18}) {
  switch (index) {
    case 0:
      return 'years_of_life';
    case 1:
      return isOver18 ? 'conception' : 'conception_hidden';
    case 2:
      return 'moon_phase';
    case 3:
      return 'brazil_curiosity';
    case 4:
      return 'birth_song';
    default:
      return 'unknown';
  }
}
