import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';

void main() {
  Future<void> pumpSection(WidgetTester tester, BrazilCuriositySection section) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: section)),
      ),
    );
    await tester.pump();
  }

  testWidgets('sem curiosidade mostra mensagem amigável', (WidgetTester tester) async {
    await pumpSection(tester, const BrazilCuriositySection(imageUrl: '', curiosity: null));

    expect(find.text('Fato histórico'), findsOneWidget);
    expect(find.text('Ainda não temos um fato histórico para o mês do seu nascimento. Volte em breve!'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('erro ao carregar mostra mensagem amigável, sem a exceção', (WidgetTester tester) async {
    await pumpSection(tester, const BrazilCuriositySection(imageUrl: '', curiosity: null, loadFailed: true));

    expect(find.text('Não foi possível carregar o fato histórico agora. Verifique sua conexão e tente novamente mais tarde.'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('Bad state'), findsNothing);
  });

  testWidgets('mostra a curiosidade quando existe', (WidgetTester tester) async {
    await pumpSection(tester, const BrazilCuriositySection(imageUrl: '', curiosity: 'Primeira parte. Segunda parte'));

    expect(find.text('Primeira parte.'), findsOneWidget);
    expect(find.text('Segunda parte'), findsOneWidget);
    expect(find.text('Sem imagem para o fato'), findsOneWidget);
  });

  testWidgets('imagem que falha ao carregar mostra o aviso em vez de quebrar', (WidgetTester tester) async {
    // Em testes de widget toda requisição HTTP retorna 400, então o Image.network falha.
    await pumpSection(tester, const BrazilCuriositySection(imageUrl: 'https://example.com/fato.png', curiosity: 'Primeira parte. Segunda parte'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sem imagem para o fato'), findsOneWidget);
  });
}
