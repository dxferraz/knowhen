import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/pump_card.dart';

final _birth = DateTime(1991, 3, 14);

/// Um PNG de 1x1 pixel, para a imagem "carregar" sem rede.
final _pixel = MemoryImage(
  base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='),
);

const _shortLeadFact =
    'Nasce o Mercosul. Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção. Até hoje o bloco reúne os quatro países.';

const _fact = 'Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção. Criaram o Mercado Comum do Sul. Até hoje o bloco reúne os quatro países.';

BrazilCuriositySection _section({
  String? curiosity = _fact,
  String imageUrl = 'https://example.com/fato.png',
  bool loadFailed = false,
  VoidCallback? onRetry,
  VoidCallback? onSeeReady,
  bool retrying = false,
  ImageProviderFor? imageProviderFor,
}) => BrazilCuriositySection(
  birthDate: _birth,
  imageUrl: imageUrl,
  curiosity: curiosity,
  loadFailed: loadFailed,
  onRetry: onRetry,
  onSeeReady: onSeeReady,
  retrying: retrying,
  imageProviderFor: imageProviderFor ?? (_) => _pixel,
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  group('o fato', () {
    testWidgets('uma primeira frase curta abre o cartão como título, sem o ponto, e o resto vira um bloco só', (tester) async {
      await pumpCard(tester, _section(curiosity: _shortLeadFact));

      expect(find.text('Nasce o Mercosul'), findsOneWidget);
      expect(find.text('Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção. Até hoje o bloco reúne os quatro países.'), findsOneWidget);
    });

    testWidgets('uma primeira frase longa não vira título: o fato inteiro é o texto', (tester) async {
      await pumpCard(tester, _section());

      expect(find.text(_fact), findsOneWidget);
      expect(find.text('FATO HISTÓRICO · MARÇO DE 1991'), findsOneWidget);
    });

    testWidgets('o eyebrow traz o mês e o ano do fato', (tester) async {
      await pumpCard(tester, _section());

      expect(find.text('FATO HISTÓRICO · MARÇO DE 1991'), findsOneWidget);
    });

    testWidgets('um fato de uma frase só não deixa um bloco de texto vazio', (tester) async {
      await pumpCard(tester, _section(curiosity: 'Nasce o Mercosul.', imageUrl: ''));

      expect(find.text('Nasce o Mercosul'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(3), reason: 'o eyebrow, o título e a ponte com a pessoa');
    });

    testWidgets('o título é um cabeçalho para o leitor de tela', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _section(curiosity: _shortLeadFact));

      final title = find.text('Nasce o Mercosul');
      expect(tester.getSemantics(title).flagsCollection.isHeader, isTrue);
      handle.dispose();
    });
  });

  group('a ponte com a pessoa (spec 4.8)', () {
    final bridge = find.text(l10n.factBirthMonthBridge);

    const withLead = (
      label: 'com título derivado',
      fact: _shortLeadFact,
      body: 'Brasil, Argentina, Paraguai e Uruguai assinaram o Tratado de Assunção. Até hoje o bloco reúne os quatro países.',
    );
    const withoutLead = (label: 'sem título derivado', fact: _fact, body: _fact);

    for (final withImage in [true, false]) {
      for (final c in [withLead, withoutLead]) {
        testWidgets('aparece depois do texto, em bodyMuted, ${c.label} e ${withImage ? 'com' : 'sem'} imagem', (tester) async {
          await pumpCard(tester, _section(curiosity: c.fact, imageUrl: withImage ? 'https://example.com/fato.png' : ''));

          expect(l10n.factBirthMonthBridge, 'No mês em que você nasceu.');
          expect(bridge, findsOneWidget);
          expect(tester.getTopLeft(bridge).dy, greaterThanOrEqualTo(tester.getBottomLeft(find.text(c.body)).dy), reason: 'depois do texto');
          expect(tester.widget<Text>(bridge).style, tester.element(bridge).knText.bodyMuted);
        });
      }
    }

    testWidgets('um fato de uma frase só também traz a ponte', (tester) async {
      await pumpCard(tester, _section(curiosity: 'Nasce o Mercosul.', imageUrl: ''));

      expect(bridge, findsOneWidget);
    });

    testWidgets('não aparece no estado vazio', (tester) async {
      await pumpCard(tester, _section(curiosity: null, imageUrl: ''));

      expect(bridge, findsNothing);
    });

    testWidgets('não aparece no estado de erro', (tester) async {
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () {}, onSeeReady: () {}));

      expect(bridge, findsNothing);
    });
  });

  group('a imagem', () {
    testWidgets('aparece em 16:10 com o selo "Ilustração gerada por IA" sobre ela', (tester) async {
      await pumpCard(tester, _section());

      final image = find.byType(Image);
      expect(image, findsOneWidget);
      final aspect = tester.widget<AspectRatio>(find.ancestor(of: image, matching: find.byType(AspectRatio)));
      expect(aspect.aspectRatio, 16 / 10);
      final badge = find.text(l10n.factAiBadge);
      expect(badge, findsOneWidget);
      expect(tester.getRect(image).overlaps(tester.getRect(badge)), isTrue);
    });

    testWidgets('sem imagem o bloco inteiro some, junto com o selo', (tester) async {
      await pumpCard(tester, _section(imageUrl: ''));

      expect(find.byType(Image), findsNothing);
      expect(find.byType(AspectRatio), findsNothing);
      expect(find.text(l10n.factAiBadge), findsNothing);
    });

    testWidgets('imagem que falha ao carregar some com o selo, sem quebrar nem deixar lacuna', (tester) async {
      // Em testes de widget toda requisição HTTP retorna 400, então a imagem de rede falha.
      await pumpCard(tester, _section(imageProviderFor: NetworkImage.new));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsNothing);
      expect(find.text(l10n.factAiBadge), findsNothing);
      expect(find.text(_fact), findsOneWidget);
    });

    testWidgets('o leitor de tela não lê a imagem decorativa', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _section());

      expect(find.bySemanticsLabel(RegExp('Ilustração')), findsOneWidget, reason: 'só o selo');
      handle.dispose();
    });
  });

  group('sem fato', () {
    testWidgets('para o mês sem fato mostra uma mensagem amigável, sem botão de tentar de novo', (tester) async {
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', onRetry: () {}, onSeeReady: () {}));

      expect(find.text(l10n.factEmptyTitle), findsOneWidget);
      expect(find.text(l10n.factEmptyBody), findsOneWidget);
      expect(find.text(l10n.factRetry), findsNothing);
      expect(find.byType(Image), findsNothing);
    });
  });

  group('falha parcial (4.10)', () {
    testWidgets('explica em pt-BR, sem a exceção, e oferece as duas saídas', (tester) async {
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () {}, onSeeReady: () {}));

      expect(find.text('Não conseguimos buscar o fato histórico'), findsOneWidget);
      expect(find.text(l10n.factErrorBody), findsOneWidget);
      expect(find.text(l10n.factRetry), findsOneWidget);
      expect(find.text(l10n.factSeeWhatIsReady), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('Bad state'), findsNothing);
    });

    testWidgets('"Tentar de novo" chama a nova busca', (tester) async {
      var retries = 0;
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () => retries++, onSeeReady: () {}));

      await tester.tap(find.text(l10n.factRetry));

      expect(retries, 1);
    });

    testWidgets('"Ver o que já está pronto" chama a volta ao resumo', (tester) async {
      var back = 0;
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () {}, onSeeReady: () => back++));

      await tester.tap(find.text(l10n.factSeeWhatIsReady));

      expect(back, 1);
    });

    testWidgets('enquanto busca de novo "Tentar de novo" fica desabilitado, e "Ver o que já está pronto" não', (tester) async {
      var retries = 0, back = 0;
      await pumpCard(
        tester,
        _section(curiosity: null, imageUrl: '', loadFailed: true, retrying: true, onRetry: () => retries++, onSeeReady: () => back++),
      );

      await tester.tap(find.text(l10n.factRetry), warnIfMissed: false);
      await tester.tap(find.text(l10n.factSeeWhatIsReady));

      expect((retries, back), (0, 1));
    });

    testWidgets('sem os callbacks o erro fica só com a mensagem', (tester) async {
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true));

      expect(find.text(l10n.factRetry), findsNothing);
      expect(find.text(l10n.factSeeWhatIsReady), findsNothing);
    });

    testWidgets('os dois botões têm pelo menos 48 dp de altura e rótulo', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () {}, onSeeReady: () {}));

      for (final label in [l10n.factRetry, l10n.factSeeWhatIsReady]) {
        final button = find.bySemanticsLabel(label);
        expect(button, findsOneWidget);
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      }
      handle.dispose();
    });
  });

  group('layout', () {
    final states = <String, BrazilCuriositySection Function()>{
      'fato com imagem': _section,
      'sem fato': () => _section(curiosity: null, imageUrl: ''),
      'falha parcial': () => _section(curiosity: null, imageUrl: '', loadFailed: true, onRetry: () {}, onSeeReady: () {}),
    };

    for (final MapEntry(key: name, value: build) in states.entries) {
      for (final scale in [1.0, 2.0]) {
        for (final brightness in Brightness.values) {
          testWidgets('$name, ${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow', (tester) async {
            await pumpCard(tester, build(), brightness: brightness, scale: scale);

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
