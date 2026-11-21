import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/summary/presentation/summary_section_name.dart';

void main() {
  test('nomes das seções logadas em summary_section_viewed', () {
    expect(summarySectionName(0, isOver18: true), 'years_of_life');
    expect(summarySectionName(1, isOver18: true), 'conception');
    expect(summarySectionName(1, isOver18: false), 'conception_hidden');
    expect(summarySectionName(2, isOver18: true), 'moon_phase');
    expect(summarySectionName(3, isOver18: true), 'brazil_curiosity');
    expect(summarySectionName(4, isOver18: true), 'birth_song');
    expect(summarySectionName(5, isOver18: true), 'unknown');
  });
}
