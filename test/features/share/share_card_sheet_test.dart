import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';
import 'package:knowhen/features/share/presentation/widgets/share_card_sheet.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  const moon = MoonPhase(phaseName: 'Lua cheia', imageUrl: '', description: 'A Lua está totalmente visível.', influence: '...');
  final data = ShareCardData(birthDate: DateTime(1990, 3, 15), now: DateTime(2026, 11, 21), moonPhase: moon);

  Future<void> pumpSheet(
    WidgetTester tester, {
    required ShareImage shareImage,
    ValueChanged<ShareSection>? onShared,
    ThemeData? theme,
    ShareSection section = ShareSection.summary,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShareCardSheet(section: section, data: data, shareImage: shareImage, onShared: onShared),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<ui.Image> decode(WidgetTester tester, Uint8List png) async {
    final codec = await tester.runAsync(() => ui.instantiateImageCodec(png));
    final frame = await tester.runAsync(() => codec!.getNextFrame());
    return frame!.image;
  }

  testWidgets('mostra o card com título, destaque e marca d\'água', (tester) async {
    await pumpSheet(tester, shareImage: (_, _, _) async => ShareResultStatus.success);

    expect(find.text('Meu Knowhen'), findsOneWidget);
    expect(find.text('36 anos'), findsOneWidget);
    expect(find.text('Descubra o seu no Knowhen'), findsOneWidget);
    expect(find.textContaining('play.google.com'), findsOneWidget);
    expect(find.text('Nascimento: 15/03/1990'), findsOneWidget);
  });

  testWidgets('gera PNG 1080x1920 e compartilha com o link da loja', (tester) async {
    Uint8List? sharedPng;
    String? sharedText;
    final shared = <ShareSection>[];
    await pumpSheet(
      tester,
      onShared: shared.add,
      shareImage: (png, text, _) async {
        sharedPng = png;
        sharedText = text;
        return ShareResultStatus.success;
      },
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Compartilhar card'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(sharedPng, isNotNull);
    final image = await decode(tester, sharedPng!);
    expect((image.width, image.height), (1080, 1920));
    expect(sharedText, contains('Descubra o seu no Knowhen'));
    expect(sharedText, contains('https://play.google.com/store/apps/details?id=com.dxferraz.knowhen'));
    expect(shared, [ShareSection.summary]);
  });

  testWidgets('cancelar a folha nativa não conta como compartilhamento concluído', (tester) async {
    final shared = <ShareSection>[];
    var calls = 0;
    await pumpSheet(
      tester,
      onShared: shared.add,
      shareImage: (_, _, _) async {
        calls++;
        return ShareResultStatus.dismissed;
      },
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Compartilhar card'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(shared, isEmpty);
  });

  testWidgets('plataforma que não informa o resultado (unavailable) conta como concluído', (tester) async {
    final shared = <ShareSection>[];
    await pumpSheet(
      tester,
      section: ShareSection.moonPhase,
      onShared: shared.add,
      shareImage: (_, _, _) async => ShareResultStatus.unavailable,
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Compartilhar card'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(shared, [ShareSection.moonPhase]);
  });

  testWidgets('esconder data completa troca a data do card por mês e ano', (tester) async {
    await pumpSheet(tester, shareImage: (_, _, _) async => ShareResultStatus.success);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Nascimento: março de 1990'), findsOneWidget);
    expect(find.text('Nascimento: 15/03/1990'), findsNothing);
  });

  testWidgets('falha ao compartilhar mostra mensagem amigável e permite tentar de novo', (tester) async {
    await pumpSheet(tester, shareImage: (_, _, _) async => throw Exception('boom'));

    await tester.runAsync(() async {
      await tester.tap(find.text('Compartilhar card'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível gerar o card agora. Tente novamente.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    expect(tester.widget<FilledButton>(find.byWidgetPredicate((w) => w is FilledButton)).onPressed, isNotNull);
  });

  for (final entry in {'claro': lightTheme, 'escuro': darkTheme}.entries) {
    testWidgets('card tem as mesmas cores nos temas ${entry.key} (fundo #14142B)', (tester) async {
      await pumpSheet(tester, theme: entry.value, shareImage: (_, _, _) async => ShareResultStatus.success);

      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(of: find.byType(RepaintBoundary), matching: find.byType(DecoratedBox)),
      );
      final gradient = decorated
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.gradient)
          .whereType<LinearGradient>()
          .first;
      expect(gradient.colors.first, const Color(0xFF14142B));
    });
  }
}
