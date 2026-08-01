import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../tokens/app_typography.dart';

/// Papel semântico de um texto.
///
/// Escolha pelo *papel* que o texto cumpre na hierarquia, nunca pelo tamanho
/// que você quer que ele tenha — é isso que mantém as telas consistentes.
enum AppTextRole {
  /// Número/frase-herói de uma seção inteira.
  displayLarge,
  display,

  /// Título de tela ou de seção.
  headline,
  headlineSmall,

  /// Título de card.
  title,

  /// Subtítulo / rótulo forte.
  subtitle,

  /// Texto corrido destacado.
  bodyLarge,

  /// Texto corrido padrão.
  body,

  /// Legenda, metadado.
  caption,

  /// Rótulo de botão/chip.
  label,

  /// Overline em caixa alta.
  overline,

  /// Contador grande com algarismos tabulares.
  numericHero,

  /// Contador médio com algarismos tabulares.
  numeric,
}

/// Texto padronizado do app.
///
/// Substitui os widgets `PrimaryH1`/`SecondaryH2`/... por um único ponto de
/// entrada ligado à escala tipográfica dos tokens.
///
/// ```dart
/// AppText.headline('Fase da lua')
/// AppText.body('Descrição…', align: TextAlign.center)
/// AppText.numericHero('12.480', gradient: context.glass.coolGradient)
/// ```
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.role = AppTextRole.body,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
    this.weight,
    this.gradient,
    this.opacity,
    this.style,
  });

  const AppText.displayLarge(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.displayLarge;

  const AppText.display(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.display;

  const AppText.headline(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.headline;

  const AppText.headlineSmall(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.headlineSmall;

  const AppText.title(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.title;

  const AppText.subtitle(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.subtitle;

  const AppText.bodyLarge(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.bodyLarge;

  const AppText.body(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.body;

  const AppText.caption(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.caption;

  const AppText.label(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.label;

  const AppText.overline(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.overline;

  const AppText.numericHero(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.numericHero;

  const AppText.numeric(this.data,
      {super.key,
      this.color,
      this.align,
      this.maxLines,
      this.overflow,
      this.weight,
      this.gradient,
      this.opacity,
      this.style})
      : role = AppTextRole.numeric;

  final String data;
  final AppTextRole role;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? weight;

  /// Aplica o texto como máscara de um gradiente (números-herói, logo).
  final Gradient? gradient;

  /// Opacidade aplicada sobre a cor resolvida — útil para hierarquia fina
  /// sem inventar novos tokens de cor.
  final double? opacity;

  /// Ajustes pontuais. Use com parcimônia: se precisar sempre, vire token.
  final TextStyle? style;

  TextStyle _baseStyle(BuildContext context) {
    final colors = context.colors;
    return switch (role) {
      AppTextRole.displayLarge =>
        AppTypography.displayLarge.copyWith(color: colors.textPrimary),
      AppTextRole.display =>
        AppTypography.displayMedium.copyWith(color: colors.textPrimary),
      AppTextRole.headline =>
        AppTypography.headlineLarge.copyWith(color: colors.textPrimary),
      AppTextRole.headlineSmall =>
        AppTypography.headlineSmall.copyWith(color: colors.textPrimary),
      AppTextRole.title =>
        AppTypography.titleLarge.copyWith(color: colors.textPrimary),
      AppTextRole.subtitle =>
        AppTypography.titleMedium.copyWith(color: colors.textPrimary),
      AppTextRole.bodyLarge =>
        AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
      AppTextRole.body =>
        AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
      AppTextRole.caption =>
        AppTypography.bodySmall.copyWith(color: colors.textTertiary),
      AppTextRole.label =>
        AppTypography.labelLarge.copyWith(color: colors.textPrimary),
      AppTextRole.overline =>
        AppTypography.labelSmall.copyWith(color: colors.textTertiary),
      AppTextRole.numericHero =>
        AppTypography.numericHero.copyWith(color: colors.textPrimary),
      AppTextRole.numeric =>
        AppTypography.numericMedium.copyWith(color: colors.textPrimary),
    };
  }

  @override
  Widget build(BuildContext context) {
    TextStyle resolved = _baseStyle(context);

    if (color != null) resolved = resolved.copyWith(color: color);
    if (weight != null) resolved = resolved.copyWith(fontWeight: weight);
    if (opacity != null) {
      final Color base = resolved.color ?? context.colors.textPrimary;
      resolved = resolved.copyWith(color: base.withValues(alpha: opacity!));
    }
    if (style != null) resolved = resolved.merge(style);

    final String text =
        role == AppTextRole.overline ? data.toUpperCase() : data;

    final Widget label = Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: resolved,
    );

    if (gradient == null) return label;

    return GradientMask(
      gradient: gradient!,
      child: Text(
        text,
        textAlign: align,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        // O ShaderMask pinta por cima; a cor só precisa ser opaca.
        style: resolved.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Aplica um gradiente como máscara sobre qualquer conteúdo (texto ou ícone).
class GradientMask extends StatelessWidget {
  const GradientMask({super.key, required this.gradient, required this.child});

  final Gradient gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
}
