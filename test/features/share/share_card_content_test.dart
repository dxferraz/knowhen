import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations_pt.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt'));

  final l10n = AppLocalizationsPt();
  const moon = MoonPhase(type: MoonPhaseType.fullMoon, imageUrl: 'https://example.com/lua.png');

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
    test('mostra a janela de 15 dias em torno de 266 dias antes do nascimento', () {
      final content = build(ShareSection.conception);

      // 15/03/1990 - 266 dias = 22/06/1989; ±7 dias.
      expect(content.highlight, '15/06/1989 a 29/06/1989');
    });

    test('com data escondida mostra só mês e ano', () {
      final content = build(ShareSection.conception, hide: true);

      expect(content.highlight, 'junho de 1989');
      expect(content.highlight, isNot(contains('/')));
    });
  });

  test('lua mostra a fase e a descrição, e é desenhada pelo app na fase exata, sem imagem remota', () {
    final content = build(ShareSection.moonPhase);

    expect(content.highlight, 'Lua cheia');
    expect(content.details, [l10n.moonPhaseFullMoonDescription]);
    expect(content.imageUrl, isNull);
    expect(content.moonFraction, getMoonPhaseFraction(DateTime(1990, 3, 15)));
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
    test('traz idade, tempo de vida, a lua do nascimento e o gancho do fato', () {
      final content = build(ShareSection.summary, d: data(curiosity: 'Nasce o Mercosul. O bloco une quatro países'));

      expect(content.title, 'Meu Knowhen');
      expect(content.highlight, '36 anos');
      expect(content.moonFraction, isNotNull);
      expect(content.details, hasLength(3));
      expect(content.details[1], 'Nasci na Lua cheia');
      expect(content.details[2], 'No mês em que nasci: Nasce o Mercosul');
    });

    test('não traz a concepção, nem para adultos', () {
      final content = build(ShareSection.summary);

      expect(content.details.join(), isNot(contains('Concebido')));
    });

    test('sem fato, ou com primeira frase longa demais para um gancho, a linha do fato some', () {
      final long = 'Uma primeira frase bem longa que não cabe como título do cartão do fato do mês. Resto';

      expect(build(ShareSection.summary, d: data(curiosity: null)).details, hasLength(2));
      expect(build(ShareSection.summary, d: data(curiosity: long)).details, hasLength(2));
    });

    test('bebê no primeiro ano mostra meses em vez de "0 anos"', () {
      final content = build(ShareSection.summary, d: data(birth: DateTime(2026, 8, 10)));

      expect(content.highlight, '3 meses');
    });

    test('com data escondida nenhuma linha traz dia/mês numérico do nascimento', () {
      final content = build(ShareSection.summary, hide: true, d: data(curiosity: 'Nasce o Mercosul. O bloco une quatro países'));
      final text = [content.title, content.highlight, ...content.details, content.birthLabel].join('\n');

      expect(text, isNot(contains('/')));
      expect(text, isNot(contains('dias')));
      expect(content.birthLabel, 'Nascimento: março de 1990');
    });
  });
}
