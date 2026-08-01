import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens de tipografia.
///
/// Pareamento: **Sora** (display) + **Inter** (texto) + **Yatra One** (marca).
///
/// - `Sora` é geométrica com terminais retos e contraforma ampla: escala muito
///   bem em tamanhos grandes com tracking negativo, que é o visual "moderno"
///   pedido, e ganha nitidez sobre vidro translúcido.
/// - `Inter` tem altura-x alta e formas abertas, o que sustenta legibilidade
///   em corpo de texto sobre superfícies de baixo contraste (vidro).
/// - `Yatra One` fica reservada exclusivamente à logotipia.
///
/// As três fontes são **empacotadas no app** (`lib/core/assets/fonts`), não
/// baixadas em tempo de execução. Isso elimina o "flash" de fonte na primeira
/// abertura, garante que o texto apareça sem rede e tira uma chamada a um
/// servidor de terceiros do caminho crítico.
///
/// Todo acesso a fontes passa por aqui: para trocar uma família, mexa nos
/// três métodos privados abaixo e no bloco `fonts:` do `pubspec.yaml`.
abstract final class AppTypography {
  static const String displayFamily = 'Sora';
  static const String bodyFamily = 'Inter';
  static const String brandFamily = 'YatraOne';

  static TextStyle _display(TextStyle style) =>
      style.copyWith(fontFamily: displayFamily);
  static TextStyle _body(TextStyle style) =>
      style.copyWith(fontFamily: bodyFamily);
  static TextStyle _brand(TextStyle style) =>
      style.copyWith(fontFamily: brandFamily);

  /// Algarismos de largura fixa — obrigatório em contadores que atualizam
  /// (relógio da vida), senão o texto "dança" a cada segundo.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  // -------------------------------------------------------------------
  // Escala tipográfica — base 16, razão ~1.2 com ajustes ópticos.
  // Tracking fica negativo no display e positivo nos labels.
  // -------------------------------------------------------------------
  static TextStyle get displayLarge => _display(const TextStyle(
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ));

  static TextStyle get displayMedium => _display(const TextStyle(
        fontSize: 36,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
      ));

  static TextStyle get displaySmall => _display(const TextStyle(
        fontSize: 30,
        height: 1.16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ));

  static TextStyle get headlineLarge => _display(const TextStyle(
        fontSize: 26,
        height: 1.24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ));

  static TextStyle get headlineMedium => _display(const TextStyle(
        fontSize: 22,
        height: 1.28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ));

  static TextStyle get headlineSmall => _display(const TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ));

  static TextStyle get titleLarge => _display(const TextStyle(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ));

  static TextStyle get titleMedium => _body(const TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ));

  static TextStyle get titleSmall => _body(const TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ));

  static TextStyle get bodyLarge => _body(const TextStyle(
        fontSize: 17,
        height: 1.55,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ));

  static TextStyle get bodyMedium => _body(const TextStyle(
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ));

  static TextStyle get bodySmall => _body(const TextStyle(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ));

  static TextStyle get labelLarge => _body(const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ));

  static TextStyle get labelMedium => _body(const TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ));

  /// Overline — sempre em caixa alta, usada em rótulos de seção.
  static TextStyle get labelSmall => _body(const TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ));

  /// Números-herói (contadores, idade). Tracking apertado + tabular.
  static TextStyle get numericHero => _display(const TextStyle(
        fontSize: 40,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        fontFeatures: tabular,
      ));

  static TextStyle get numericMedium => _display(const TextStyle(
        fontSize: 24,
        height: 1.1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFeatures: tabular,
      ));

  static TextStyle brand({double size = 28, Color? color}) => _brand(TextStyle(
        fontSize: size,
        height: 1.1,
        color: color,
      ));

  /// `TextTheme` completo já colorido com os tokens semânticos.
  static TextTheme textTheme(AppColors colors) {
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      displaySmall: displaySmall.copyWith(color: primary),
      headlineLarge: headlineLarge.copyWith(color: primary),
      headlineMedium: headlineMedium.copyWith(color: primary),
      headlineSmall: headlineSmall.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: secondary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: secondary),
      labelSmall: labelSmall.copyWith(color: colors.textTertiary),
    );
  }
}
