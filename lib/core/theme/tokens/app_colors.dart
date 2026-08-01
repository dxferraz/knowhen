import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Tokens semânticos de cor.
///
/// [AppColors] descreve *função* ("texto secundário", "traço do vidro"),
/// nunca aparência ("cinza claro"). Trocar a paleta em [AppPalette] ou
/// remapear aqui muda o app inteiro sem tocar em nenhuma tela.
class AppColors {
  const AppColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.secondarySoft,
    required this.onSecondarySoft,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiarySoft,
    required this.onTertiarySoft,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.danger,
    required this.onDanger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.canvas,
    required this.canvasElevated,
    required this.outline,
    required this.outlineSoft,
    required this.scrim,
    required this.shadow,
  });

  final Brightness brightness;

  /// Ação principal (CTA, seleção, foco).
  final Color primary;
  final Color onPrimary;

  /// Versão "container" — fundo suave para chips/badges da cor principal.
  final Color primarySoft;
  final Color onPrimarySoft;

  final Color secondary;
  final Color onSecondary;
  final Color secondarySoft;
  final Color onSecondarySoft;

  final Color tertiary;
  final Color onTertiary;
  final Color tertiarySoft;
  final Color onTertiarySoft;

  /// Acento decorativo (rosa/nebula). Nunca usado sozinho para texto pequeno.
  final Color accent;
  final Color onAccent;

  final Color success;
  final Color danger;
  final Color onDanger;

  /// Texto de leitura principal. Contraste >= 12:1 sobre [canvas].
  final Color textPrimary;

  /// Texto de apoio, legendas longas. Contraste >= 4.5:1.
  final Color textSecondary;

  /// Texto decorativo / metadados. Somente >= 18px ou 14px bold.
  final Color textTertiary;

  /// Texto sobre superfícies invertidas (ex.: snackbar).
  final Color textInverse;

  /// Cor sólida de fallback da cena (usada em status bar e telas sem aurora).
  final Color canvas;

  /// Superfície opaca para quando o blur precisa ser desligado.
  final Color canvasElevated;

  final Color outline;
  final Color outlineSoft;
  final Color scrim;
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  // -------------------------------------------------------------------
  // Light
  // -------------------------------------------------------------------
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    primary: AppPalette.iris500,
    onPrimary: AppPalette.white,
    primarySoft: AppPalette.iris100,
    onPrimarySoft: AppPalette.iris800,
    secondary: AppPalette.aqua600,
    onSecondary: AppPalette.white,
    secondarySoft: AppPalette.aqua100,
    onSecondarySoft: AppPalette.aqua800,
    tertiary: AppPalette.solar600,
    onTertiary: AppPalette.white,
    tertiarySoft: AppPalette.solar100,
    onTertiarySoft: AppPalette.solar800,
    accent: AppPalette.nebula600,
    onAccent: AppPalette.white,
    success: AppPalette.success700,
    danger: AppPalette.danger500,
    onDanger: AppPalette.white,
    textPrimary: AppPalette.ink900,
    textSecondary: AppPalette.ink600,
    textTertiary: AppPalette.ink500,
    textInverse: AppPalette.ink50,
    canvas: AppPalette.dawnAlt,
    canvasElevated: AppPalette.white,
    outline: AppPalette.ink300,
    outlineSoft: AppPalette.ink200,
    scrim: AppPalette.ink900,
    shadow: AppPalette.ink900,
  );

  // -------------------------------------------------------------------
  // Dark
  // -------------------------------------------------------------------
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    primary: AppPalette.iris300,
    onPrimary: AppPalette.ink950,
    primarySoft: AppPalette.iris900,
    onPrimarySoft: AppPalette.iris100,
    secondary: AppPalette.aqua300,
    onSecondary: AppPalette.aqua900,
    secondarySoft: AppPalette.aqua900,
    onSecondarySoft: AppPalette.aqua100,
    tertiary: AppPalette.solar300,
    onTertiary: AppPalette.solar900,
    tertiarySoft: AppPalette.solar900,
    onTertiarySoft: AppPalette.solar100,
    accent: AppPalette.nebula300,
    onAccent: AppPalette.nebula900,
    success: AppPalette.success300,
    danger: AppPalette.danger400,
    onDanger: AppPalette.ink950,
    textPrimary: Color(0xFFF4F3FF),
    textSecondary: Color(0xFFA9A5C9),
    textTertiary: Color(0xFF7E7AA3),
    textInverse: AppPalette.ink900,
    canvas: AppPalette.night,
    canvasElevated: AppPalette.nightAlt,
    outline: Color(0xFF3A3760),
    outlineSoft: Color(0xFF272446),
    scrim: AppPalette.black,
    shadow: AppPalette.black,
  );

  static AppColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Converte os tokens semânticos em um `ColorScheme` Material 3 completo,
  /// para que widgets nativos (date picker, snackbar, dialogs) herdem o tema.
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primarySoft,
      onPrimaryContainer: onPrimarySoft,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondarySoft,
      onSecondaryContainer: onSecondarySoft,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiarySoft,
      onTertiaryContainer: onTertiarySoft,
      error: danger,
      onError: onDanger,
      errorContainer: isDark ? AppPalette.danger700 : AppPalette.danger300,
      onErrorContainer: isDark ? AppPalette.danger300 : AppPalette.danger700,
      surface: canvas,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: isDark ? AppPalette.night : AppPalette.white,
      surfaceContainerLow: isDark ? AppPalette.nightAlt : AppPalette.dawn,
      surfaceContainer: isDark ? const Color(0xFF181633) : AppPalette.dawnAlt,
      surfaceContainerHigh: isDark ? const Color(0xFF1F1C3D) : AppPalette.ink100,
      surfaceContainerHighest:
          isDark ? const Color(0xFF272348) : AppPalette.ink200,
      surfaceTint: primary,
      outline: outline,
      outlineVariant: outlineSoft,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: isDark ? AppPalette.ink100 : AppPalette.ink900,
      onInverseSurface: textInverse,
      inversePrimary: isDark ? AppPalette.iris600 : AppPalette.iris300,
    );
  }
}
