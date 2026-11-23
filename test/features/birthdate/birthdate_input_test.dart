import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birthdate/domain/birthdate_input.dart';

void main() {
  final now = DateTime(2026, 11, 23, 15, 30);

  BirthdateInput parse(String d, String m, String y) =>
      BirthdateInput.parse(d, m, y, now: now);

  group('data válida', () {
    test('lê dia, mês e ano', () {
      expect(parse('14', '03', '1991').date, DateTime(1991, 3, 14));
      expect(parse('14', '03', '1991').error, isNull);
    });

    test('aceita dia e mês com um dígito', () {
      expect(parse('5', '3', '1991').date, DateTime(1991, 3, 5));
    });

    test('29/02 vale só em ano bissexto', () {
      expect(parse('29', '02', '2000').date, DateTime(2000, 2, 29));
      expect(parse('29', '02', '2001').error, BirthdateError.invalid);
      expect(parse('29', '02', '1900').error, BirthdateError.invalid);
    });

    test('hoje vale, mesmo com hora no relógio', () {
      expect(parse('23', '11', '2026').date, DateTime(2026, 11, 23));
    });

    test('primeiro dia aceito é 01/01/1900', () {
      expect(parse('01', '01', '1900').date, DateTime(1900, 1, 1));
    });

    test('quem nasceu depois de 2025 não é barrado por um limite fixo', () {
      expect(parse('01', '01', '2026').date, DateTime(2026, 1, 1));
      expect(
        BirthdateInput.parse(
          '01',
          '06',
          '2040',
          now: DateTime(2041, 1, 1),
        ).date,
        DateTime(2040, 6, 1),
      );
    });
  });

  group('erros', () {
    test('mês ou dia que não existem', () {
      expect(parse('31', '02', '1991').error, BirthdateError.invalid);
      expect(parse('31', '04', '1991').error, BirthdateError.invalid);
      expect(parse('14', '13', '1991').error, BirthdateError.invalid);
      expect(parse('14', '00', '1991').error, BirthdateError.invalid);
      expect(parse('00', '03', '1991').error, BirthdateError.invalid);
      expect(parse('32', '03', '1991').error, BirthdateError.invalid);
    });

    test('data no futuro, a partir de amanhã', () {
      expect(parse('24', '11', '2026').error, BirthdateError.future);
      expect(parse('01', '01', '2027').error, BirthdateError.future);
    });

    test('ano antes de 1900', () {
      expect(parse('31', '12', '1899').error, BirthdateError.tooOld);
      expect(parse('01', '01', '0001').error, BirthdateError.tooOld);
    });

    test('um erro não traz data', () {
      expect(parse('31', '02', '1991').date, isNull);
    });
  });

  group('incompleto', () {
    test('campos vazios não são erro nem data', () {
      for (final input in [
        parse('', '', ''),
        parse('14', '', ''),
        parse('', '03', '1991'),
        parse('14', '03', ''),
      ]) {
        expect(input.date, isNull);
        expect(input.error, isNull);
      }
    });

    test('ano só conta com 4 dígitos: "19" não vira o ano 19', () {
      for (final year in ['1', '19', '199']) {
        final input = parse('14', '03', year);
        expect(input.date, isNull);
        expect(input.error, isNull);
      }
    });
  });
}
