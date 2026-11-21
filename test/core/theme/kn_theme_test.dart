import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

void main() {
  final themes = {Brightness.light: lightTheme, Brightness.dark: darkTheme};

  group('ThemeData', () {
    test('claro usa Amanhecer e escuro usa Noite, com as extensões registradas', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.extension<KnColors>(), KnColors.dawn);
      expect(darkTheme.extension<KnColors>(), KnColors.night);
      expect(lightTheme.extension<KnTextStyles>(), isNotNull);
      expect(darkTheme.extension<KnTextStyles>(), isNotNull);
    });

    test('fundo e cores principais vêm da paleta', () {
      for (final t in themes.values) {
        final c = t.extension<KnColors>()!;
        expect(t.scaffoldBackgroundColor, c.bg);
        expect(t.colorScheme.primary, c.primary);
        expect(t.colorScheme.onSurface, c.ink);
      }
    });

    test('texto padrão usa Inter e títulos usam a serifada, ambas empacotadas', () {
      for (final t in themes.values) {
        expect(t.textTheme.bodyMedium!.fontFamily, KnFonts.sans);
        expect(t.textTheme.titleLarge!.fontFamily, KnFonts.sans);
        expect(t.textTheme.headlineMedium!.fontFamily, KnFonts.serif);
        expect(t.textTheme.displayLarge!.fontFamily, KnFonts.serif);
      }
    });

    test('escala tipográfica segue a seção 2.2', () {
      final s = lightTheme.extension<KnTextStyles>()!;
      expect((s.display.fontSize, s.display.height, s.display.fontFamily), (44, 1.1, KnFonts.serif));
      expect((s.title.fontSize, s.title.height, s.title.fontFamily), (30, 1.2, KnFonts.serif));
      expect((s.stat.fontSize, s.stat.height, s.stat.fontFamily), (28, 1.1, KnFonts.serif));
      expect((s.headline.fontSize, s.headline.height, s.headline.fontWeight), (20, 1.3, FontWeight.w600));
      expect((s.body.fontSize, s.body.height, s.body.fontWeight), (16, 1.5, null));
      expect((s.label.fontSize, s.label.height, s.label.fontWeight), (14, 1.4, FontWeight.w600));
      expect((s.caption.fontSize, s.caption.height), (13, 1.4));
      expect((s.eyebrow.fontSize, s.eyebrow.height, s.eyebrow.letterSpacing), (12, 1.3, 1.4));
      expect(s.bodyMuted.color, KnColors.dawn.inkMuted);
      expect(s.eyebrow.color, KnColors.dawn.accentText);
    });

    test('espaçamentos e raios seguem a seção 2.3', () {
      expect(
        [KnSpace.xs, KnSpace.sm, KnSpace.md, KnSpace.lg, KnSpace.xl, KnSpace.xxl, KnSpace.xxxl],
        [4, 8, 12, 16, 24, 32, 48],
      );
      expect([KnRadius.sm, KnRadius.md], [12, 20]);
      expect(KnSize.touchTarget, 48);
      expect(KnSize.button, 56);
    });

    test('botões têm no mínimo 48 dp e os principais 56 dp', () {
      for (final t in themes.values) {
        final filled = t.filledButtonTheme.style!.minimumSize!.resolve({})!;
        expect(filled.height, 56);
        expect(filled.width, greaterThanOrEqualTo(48));
        expect(t.textButtonTheme.style!.minimumSize!.resolve({})!.height, 48);
        expect(t.iconButtonTheme.style!.minimumSize!.resolve({})!, const Size(48, 48));
      }
    });

    test('pickers de data e hora têm tema próprio', () {
      for (final t in themes.values) {
        final c = t.extension<KnColors>()!;
        expect(t.datePickerTheme.backgroundColor, c.surface);
        expect(t.timePickerTheme.backgroundColor, c.surface);
        expect(t.datePickerTheme.dayBackgroundColor!.resolve({WidgetState.selected}), c.primary);
        expect(t.datePickerTheme.dayForegroundColor!.resolve({WidgetState.selected}), c.onPrimary);
        expect(t.timePickerTheme.dialHandColor, c.primary);
      }
    });
  });

  group('KnColors.of / context', () {
    testWidgets('lê a extensão do tema', (tester) async {
      late KnColors colors;
      late KnTextStyles text;
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Builder(
            builder: (context) {
              colors = context.kn;
              text = context.knText;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors, KnColors.dawn);
      expect(text.title.color, KnColors.dawn.ink);
    });

    testWidgets('sem extensão cai na paleta do brilho do tema', (tester) async {
      late KnColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              colors = context.kn;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors, KnColors.night);
    });
  });

  group('widgets Material tematizados', () {
    for (final entry in themes.entries) {
      testWidgets('${entry.key.name}: 360x640 a 200% de fonte, sem overflow', (tester) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: entry.value,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(KnSpace.md),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(labelText: 'Dia', helperText: 'De 1 a 31'),
                    ),
                    const SizedBox(height: KnSpace.md),
                    FilledButton(onPressed: () {}, child: const Text('Descobrir meu céu')),
                    OutlinedButton(onPressed: () {}, child: const Text('Voltar')),
                    TextButton(onPressed: () {}, child: const Text('Pular')),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        final button = tester.getSize(find.byType(FilledButton));
        expect(button.height, greaterThanOrEqualTo(56));
      });
    }
  });

  group('fontes empacotadas', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('pubspec declara cada família e os arquivos existem', () {
      for (final family in [KnFonts.sans, KnFonts.serif, KnFonts.logo, KnFonts.legacyPoppins]) {
        expect(pubspec, contains('- family: $family'));
      }
      final assets = RegExp(r'asset: (lib/core/assets/fonts/\S+\.ttf)').allMatches(pubspec).map((m) => m.group(1)!);
      expect(assets, hasLength(6));
      for (final path in assets) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });

    test('app não baixa fontes em runtime (google_fonts fora do pubspec e do lib)', () {
      expect(pubspec, isNot(contains('google_fonts')));
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && f.readAsStringSync().contains('google_fonts'));
      expect(offenders, isEmpty);
    });
  });
}
