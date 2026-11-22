import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';

import '../../helpers/contrast.dart';

void main() {
  group('contrastRatio', () {
    test('preto sobre branco é 21:1 e a razão é simétrica', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.001));
      expect(contrastRatio(Colors.white, Colors.black), closeTo(21, 0.001));
    });

    test('mesma cor é 1:1', () {
      expect(contrastRatio(const Color(0xFF123456), const Color(0xFF123456)), closeTo(1, 0.001));
    });
  });

  group('tabela de contraste do documento de design (seção 2.1)', () {
    const night = KnColors.night;
    const dawn = KnColors.dawn;

    void expectRatio(Color a, Color b, double documented) {
      expect(contrastRatio(a, b), closeTo(documented, 0.06));
    }

    test('Noite', () {
      expectRatio(night.ink, night.bg, 16.7);
      expectRatio(night.inkMuted, night.surface, 8.6);
      expectRatio(night.onPrimary, night.primary, 11.2);
      expectRatio(night.accentText, night.bgTop, 9.2);
    });

    test('Amanhecer', () {
      expectRatio(dawn.ink, dawn.bg, 16.6);
      expectRatio(dawn.inkMuted, dawn.bgTop, 5.9);
      expectRatio(dawn.onPrimary, dawn.primary, 11.8);
      expectRatio(dawn.accentText, dawn.bgTop, 5.1);
    });
  });

  group('AA em todas as combinações usadas como texto', () {
    for (final c in [KnColors.night, KnColors.dawn]) {
      final name = c.isDark ? 'Noite' : 'Amanhecer';
      final backgrounds = {'bg': c.bg, 'bgTop': c.bgTop, 'surface': c.surface, 'surfaceHi': c.surfaceHi};

      for (final bg in backgrounds.entries) {
        test('$name: ink, inkMuted, accentText e lavender sobre ${bg.key}', () {
          expect(contrastRatio(c.ink, bg.value), greaterThanOrEqualTo(aaText), reason: 'ink');
          expect(contrastRatio(c.inkMuted, bg.value), greaterThanOrEqualTo(aaText), reason: 'inkMuted');
          expect(contrastRatio(c.accentText, bg.value), greaterThanOrEqualTo(aaText), reason: 'accentText');
          expect(contrastRatio(c.lavender, bg.value), greaterThanOrEqualTo(aaText), reason: 'lavender');
        });
      }

      test('$name: danger sobre bg e surface', () {
        expect(contrastRatio(c.danger, c.bg), greaterThanOrEqualTo(aaText));
        expect(contrastRatio(c.danger, c.surface), greaterThanOrEqualTo(aaText));
      });

      test('$name: texto do botão primário sobre primary', () {
        expect(contrastRatio(c.onPrimary, c.primary), greaterThanOrEqualTo(aaText));
      });

      test('$name: a parte sombreada da lua se distingue da iluminada', () {
        expect(contrastRatio(c.moon, c.moonShadow), greaterThanOrEqualTo(1.2));
      });
    }

    test('Noite: a lua (decorativa) se destaca do céu em 3:1', () {
      expect(contrastRatio(KnColors.night.moon, KnColors.night.bg), greaterThanOrEqualTo(aaUi));
    });
  });

  group('pares do ColorScheme que usam as cores da paleta', () {
    for (final c in [KnColors.night, KnColors.dawn]) {
      final name = c.isDark ? 'Noite' : 'Amanhecer';
      final scheme = (c.isDark ? darkTheme : lightTheme).colorScheme;

      test('$name: onPrimary sobre secondary e sobre inkMuted', () {
        expect(
          contrastRatio(c.onPrimary, scheme.secondary),
          greaterThanOrEqualTo(aaText),
          reason: 'onPrimary/secondary',
        );
        expect(contrastRatio(c.onPrimary, c.inkMuted), greaterThanOrEqualTo(aaText), reason: 'onPrimary/inkMuted');
      });

      test('$name: ícone secondary sobre surface passa em 3:1', () {
        expect(contrastRatio(scheme.secondary, c.surface), greaterThanOrEqualTo(aaUi));
      });
    }
  });

  group('SnackBar', () {
    for (final entry in {'Noite': darkTheme, 'Amanhecer': lightTheme}.entries) {
      final theme = entry.value.snackBarTheme;

      test('${entry.key}: texto do conteúdo sobre o fundo passa no AA', () {
        expect(contrastRatio(theme.contentTextStyle!.color!, theme.backgroundColor!), greaterThanOrEqualTo(aaText));
      });

      test('${entry.key}: texto da ação sobre o fundo passa no AA', () {
        expect(contrastRatio(theme.actionTextColor!, theme.backgroundColor!), greaterThanOrEqualTo(aaText));
      });
    }
  });

  group('ColorScheme do ThemeData', () {
    for (final entry in {'claro': lightTheme, 'escuro': darkTheme}.entries) {
      final s = entry.value.colorScheme;
      final pairs = <String, (Color, Color)>{
        'primary': (s.onPrimary, s.primary),
        'primaryContainer': (s.onPrimaryContainer, s.primaryContainer),
        'secondary': (s.onSecondary, s.secondary),
        'secondaryContainer': (s.onSecondaryContainer, s.secondaryContainer),
        'tertiary': (s.onTertiary, s.tertiary),
        'tertiaryContainer': (s.onTertiaryContainer, s.tertiaryContainer),
        'error': (s.onError, s.error),
        'surface': (s.onSurface, s.surface),
        'surfaceVariant em surface': (s.onSurfaceVariant, s.surface),
        'inverseSurface': (s.onInverseSurface, s.inverseSurface),
      };
      for (final p in pairs.entries) {
        test('tema ${entry.key}: ${p.key} passa no AA', () {
          expect(contrastRatio(p.value.$1, p.value.$2), greaterThanOrEqualTo(aaText));
        });
      }

      test('tema ${entry.key}: borda de campo (outline) passa em 3:1 sobre o fundo', () {
        expect(contrastRatio(s.outline, s.surface), greaterThanOrEqualTo(aaUi));
      });
    }
  });

  group('ThemeExtension', () {
    test('copyWith troca só o campo pedido', () {
      final changed = KnColors.night.copyWith(primary: Colors.red);
      expect(changed.primary, Colors.red);
      expect(changed.bg, KnColors.night.bg);
      expect(changed.brightness, Brightness.dark);
    });

    test('lerp nas pontas devolve os extremos e no meio mistura', () {
      expect(KnColors.night.lerp(KnColors.dawn, 0).bg, KnColors.night.bg);
      expect(KnColors.night.lerp(KnColors.dawn, 1).bg, KnColors.dawn.bg);
      expect(KnColors.night.lerp(KnColors.dawn, 0.5).bg, Color.lerp(KnColors.night.bg, KnColors.dawn.bg, 0.5));
      expect(KnColors.night.lerp(null, 0.5), KnColors.night);
    });

    test('roles lista todos os papéis de cor', () {
      expect(KnColors.night.roles.keys, containsAll(['bg', 'bgTop', 'surface', 'ink', 'primary', 'moon']));
      expect(KnColors.night.roles.length, 14);
    });
  });
}
