import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations_pt.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt'));

  final l10n = AppLocalizationsPt();
  const moon = MoonPhase(
    phaseName: 'Lua cheia',
    imageUrl: 'https://example.com/lua.png',
    description: 'A Lua está totalmente visível.',
    influence: '...',
  );

  ShareCardData data({DateTime? birth, String? curiosity = 'Primeira parte. Segunda parte', String image = ''}) => ShareCardData(
    birthDate: birth ?? DateTime(1990, 3, 15),
    now: DateTime(2026, 11, 21),
    moonPhase: moon,
    curiosity: curiosity,
    curiosityImageUrl: image,
  );

  ShareCardContent build(ShareSection section, {bool hide = false, ShareCardData? d}) =>
      ShareCardContent.build(l10n, section, d ?? data(), hideFullDate: hide);

  test('analyticsName usa os mesmos nomes de summary_section_viewed', () {
    expect(ShareSection.values.map((s) => s.analyticsName), ['years_of_life', 'conception', 'moon_phase', 'brazil_curiosity', 'summary']);
  });

  group('anos de vida', () {
    test('mostra anos, meses e dias e a data completa', () {
      final content = build(ShareSection.yearsOfLife);

      expect(content.highlight, '36 anos');
      expect(
        content.details.single,
        '440 meses e 13400 dias de vida'.replaceAll('13400', '${DateTime(2026, 11, 21).difference(DateTime(1990, 3, 15)).inDays}'),
      );
      expect(content.birthLabel, 'Nascimento: 15/03/1990');
    });

    test('com data escondida omite os dias e mostra só mês e ano', () {
      final content = build(ShareSection.yearsOfLife, hide: true);

      expect(content.details.single, '440 meses de vida');
      expect(content.birthLabel, 'Nascimento: março de 1990');
      expect(content.details.join(), isNot(contains('dias')));
    });

    test('singular para 1 ano', () {
      final content = build(ShareSection.yearsOfLife, d: data(birth: DateTime(2025, 11, 1)));

      expect(content.highlight, '1 ano');
    });
  });

  group('concepção', () {
    test('mostra a janela de 15 dias em torno de 280 dias antes do nascimento', () {
      final content = build(ShareSection.conception);

      // 15/03/1990 - 280 dias = 08/06/1989; ±7 dias.
      expect(content.highlight, '01/06/1989 a 15/06/1989');
    });

    test('com data escondida mostra só mês e ano', () {
      final content = build(ShareSection.conception, hide: true);

      expect(content.highlight, 'junho de 1989');
      expect(content.highlight, isNot(contains('/')));
    });
  });

  test('lua mostra a fase, a descrição e a imagem', () {
    final content = build(ShareSection.moonPhase);

    expect(content.highlight, 'Lua cheia');
    expect(content.details, ['A Lua está totalmente visível.']);
    expect(content.imageUrl, 'https://example.com/lua.png');
  });

  group('curiosidade', () {
    test('primeira frase em destaque e o resto como detalhe', () {
      final content = build(ShareSection.brazilCuriosity, d: data(image: 'https://example.com/fato.png'));

      expect(content.highlight, 'Primeira parte.');
      expect(content.details, ['Segunda parte']);
      expect(content.imageUrl, 'https://example.com/fato.png');
    });

    test('sem imagem não define imageUrl', () {
      expect(build(ShareSection.brazilCuriosity).imageUrl, isNull);
    });
  });

  group('card-resumo "Meu Knowhen"', () {
    test('adulto inclui a concepção', () {
      final content = build(ShareSection.summary);

      expect(content.title, 'Meu Knowhen');
      expect(content.details, hasLength(3));
      expect(content.details[1], 'Nasci na Lua cheia');
      expect(content.details[2], 'Concebido(a) por volta de 01/06/1989 a 15/06/1989');
    });

    test('menor de 18 anos não inclui a concepção', () {
      final content = build(ShareSection.summary, d: data(birth: DateTime(2015, 5, 10)));

      expect(content.details, hasLength(2));
      expect(content.details.join(), isNot(contains('Concebido')));
    });

    test('com data escondida nenhuma linha traz dia/mês numérico do nascimento', () {
      final content = build(ShareSection.summary, hide: true);
      final text = [content.title, content.highlight, ...content.details, content.birthLabel].join('\n');

      expect(text, isNot(contains('/')));
      expect(text, isNot(contains('dias')));
      expect(content.birthLabel, 'Nascimento: março de 1990');
      expect(content.details[2], 'Concebido(a) por volta de junho de 1989');
    });
  });
}
