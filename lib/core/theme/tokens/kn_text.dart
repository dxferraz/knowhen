import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';

/// Famílias empacotadas em `lib/core/assets/fonts`; nenhuma é baixada em runtime.
class KnFonts {
  const KnFonts._();

  static const String sans = 'Inter';
  static const String serif = 'DM Serif Display';

  /// Só o logo.
  static const String logo = 'Yatra One';

  /// Legado: títulos do resumo antigo. Sai com o PR `summary-cards`.
  static const String legacyPoppins = 'Poppins';
}

/// Escala tipográfica (DXF-9, seção 2.2), já com as cores do tema.
///
/// Os tamanhos são em `sp`: respeitam a fonte do sistema e não são limitados.
@immutable
class KnTextStyles extends ThemeExtension<KnTextStyles> {
  const KnTextStyles({
    required this.display,
    required this.title,
    required this.stat,
    required this.headline,
    required this.body,
    required this.bodyMuted,
    required this.label,
    required this.caption,
    required this.eyebrow,
  });

  /// Número-herói ("35 anos").
  final TextStyle display;

  /// Título de cada tela ou cartão.
  final TextStyle title;

  /// Números em grade.
  final TextStyle stat;

  /// Subtítulos.
  final TextStyle headline;

  /// Texto corrido.
  final TextStyle body;
  final TextStyle bodyMuted;

  /// Botões e rótulos.
  final TextStyle label;

  /// Legendas e ajuda.
  final TextStyle caption;

  /// Categoria do cartão (a caixa alta fica a cargo de quem escreve o texto).
  final TextStyle eyebrow;

  factory KnTextStyles.from(KnColors c) {
    return KnTextStyles(
      display: TextStyle(fontFamily: KnFonts.serif, fontSize: 44, height: 1.1, letterSpacing: -0.5, color: c.ink),
      title: TextStyle(fontFamily: KnFonts.serif, fontSize: 30, height: 1.2, letterSpacing: 0, color: c.ink),
      stat: TextStyle(fontFamily: KnFonts.serif, fontSize: 28, height: 1.1, letterSpacing: 0, color: c.ink),
      headline: TextStyle(
        fontFamily: KnFonts.sans,
        fontSize: 20,
        height: 1.3,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      body: TextStyle(fontFamily: KnFonts.sans, fontSize: 16, height: 1.5, letterSpacing: 0, color: c.ink),
      bodyMuted: TextStyle(fontFamily: KnFonts.sans, fontSize: 16, height: 1.5, letterSpacing: 0, color: c.inkMuted),
      label: TextStyle(
        fontFamily: KnFonts.sans,
        fontSize: 14,
        height: 1.4,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      caption: TextStyle(fontFamily: KnFonts.sans, fontSize: 13, height: 1.4, letterSpacing: 0, color: c.inkMuted),
      eyebrow: TextStyle(
        fontFamily: KnFonts.sans,
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: c.accentText,
      ),
    );
  }

  static KnTextStyles of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<KnTextStyles>() ?? KnTextStyles.from(KnColors.of(context));
  }

  /// Mapeia a escala para o [TextTheme] do Material, para que widgets padrão
  /// (pickers, diálogos, campos) herdem as fontes e tamanhos do app.
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: title,
      headlineLarge: title,
      headlineMedium: title,
      headlineSmall: stat,
      titleLarge: headline,
      titleMedium: label.copyWith(fontSize: 16),
      titleSmall: label,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: label,
      labelMedium: label,
      labelSmall: caption.copyWith(fontWeight: FontWeight.w600),
    );
  }

  @override
  KnTextStyles copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? stat,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? bodyMuted,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? eyebrow,
  }) {
    return KnTextStyles(
      display: display ?? this.display,
      title: title ?? this.title,
      stat: stat ?? this.stat,
      headline: headline ?? this.headline,
      body: body ?? this.body,
      bodyMuted: bodyMuted ?? this.bodyMuted,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      eyebrow: eyebrow ?? this.eyebrow,
    );
  }

  @override
  KnTextStyles lerp(ThemeExtension<KnTextStyles>? other, double t) {
    if (other is! KnTextStyles) return this;
    return KnTextStyles(
      display: TextStyle.lerp(display, other.display, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      stat: TextStyle.lerp(stat, other.stat, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyMuted: TextStyle.lerp(bodyMuted, other.bodyMuted, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      eyebrow: TextStyle.lerp(eyebrow, other.eyebrow, t)!,
    );
  }
}

/// Atalhos: `context.kn.primary`, `context.knText.title`.
extension KnThemeContext on BuildContext {
  KnColors get kn => KnColors.of(this);
  KnTextStyles get knText => KnTextStyles.of(this);
}
