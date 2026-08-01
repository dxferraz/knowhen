import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_glass.dart';
import 'tokens/app_gradients.dart';
import 'tokens/app_palette.dart';
import 'tokens/app_spacing.dart';

/// Níveis de elevação do vidro.
///
/// Não é elevação Material (sombra crescente), é **profundidade óptica**:
/// quanto mais alto o nível, mais opaco e mais desfocado o painel fica, e
/// portanto mais "à frente" ele parece estar.
enum GlassLevel {
  /// Barras, chips, superfícies rentes ao fundo.
  subtle,

  /// Cards e painéis de conteúdo. Padrão.
  regular,

  /// Modais, sheets, elementos em foco.
  elevated,
}

/// Receita completa de uma superfície de vidro.
@immutable
class GlassSurfaceStyle {
  const GlassSurfaceStyle({
    required this.blurSigma,
    required this.saturation,
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    required this.shadows,
    required this.radius,
    required this.opaqueFallback,
  });

  final double blurSigma;
  final double saturation;

  /// Tint aplicado por cima do backdrop desfocado.
  final Gradient fill;

  /// Gradiente do traço de 1px (a quina de luz).
  final Gradient stroke;

  final double strokeWidth;

  /// Sombras projetadas **fora** do painel.
  final List<BoxShadow> shadows;

  final double radius;

  /// Cor sólida equivalente, usada quando o blur está desligado.
  final Color opaqueFallback;

  GlassSurfaceStyle copyWith({
    double? blurSigma,
    double? saturation,
    Gradient? fill,
    Gradient? stroke,
    double? strokeWidth,
    List<BoxShadow>? shadows,
    double? radius,
    Color? opaqueFallback,
  }) {
    return GlassSurfaceStyle(
      blurSigma: blurSigma ?? this.blurSigma,
      saturation: saturation ?? this.saturation,
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      shadows: shadows ?? this.shadows,
      radius: radius ?? this.radius,
      opaqueFallback: opaqueFallback ?? this.opaqueFallback,
    );
  }

  static GlassSurfaceStyle lerp(
    GlassSurfaceStyle a,
    GlassSurfaceStyle b,
    double t,
  ) {
    return GlassSurfaceStyle(
      blurSigma: a.blurSigma + (b.blurSigma - a.blurSigma) * t,
      saturation: a.saturation + (b.saturation - a.saturation) * t,
      fill: Gradient.lerp(a.fill, b.fill, t) ?? b.fill,
      stroke: Gradient.lerp(a.stroke, b.stroke, t) ?? b.stroke,
      strokeWidth: a.strokeWidth + (b.strokeWidth - a.strokeWidth) * t,
      shadows: BoxShadow.lerpList(a.shadows, b.shadows, t) ?? b.shadows,
      radius: a.radius + (b.radius - a.radius) * t,
      opaqueFallback:
          Color.lerp(a.opaqueFallback, b.opaqueFallback, t) ?? b.opaqueFallback,
    );
  }
}

/// Extensão de tema que carrega todos os parâmetros do estilo Glassmorphism.
///
/// Acesse via `Theme.of(context).extension<GlassTheme>()!` ou, preferível,
/// pelo atalho `context.glass` (ver `context_extensions.dart`).
@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.subtle,
    required this.regular,
    required this.elevated,
    required this.canvasGradient,
    required this.auroraOrbs,
    required this.brandGradient,
    required this.coolGradient,
    required this.warmGradient,
    required this.onGradient,
    required this.dividerColor,
  });

  final GlassSurfaceStyle subtle;
  final GlassSurfaceStyle regular;
  final GlassSurfaceStyle elevated;

  /// Gradiente base da cena (camada 0).
  final Gradient canvasGradient;

  /// Manchas de cor que dão o que refratar (camada 1).
  final List<AuroraOrb> auroraOrbs;

  final LinearGradient brandGradient;
  final LinearGradient coolGradient;
  final LinearGradient warmGradient;

  /// Cor de texto/ícone legível sobre os gradientes acima.
  final Color onGradient;

  final Color dividerColor;

  GlassSurfaceStyle styleFor(GlassLevel level) => switch (level) {
        GlassLevel.subtle => subtle,
        GlassLevel.regular => regular,
        GlassLevel.elevated => elevated,
      };

  // -------------------------------------------------------------------
  // Construção a partir dos tokens
  // -------------------------------------------------------------------
  static GlassTheme of(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final AppColors colors = AppColors.of(brightness);

    LinearGradient fill(double factor) {
      final double top = (isDark
              ? AppGlassTokens.fillDarkTop
              : AppGlassTokens.fillLightTop) *
          factor;
      final double bottom = (isDark
              ? AppGlassTokens.fillDarkBottom
              : AppGlassTokens.fillLightBottom) *
          factor;
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppPalette.white.withValues(alpha: top.clamp(0.0, 1.0)),
          AppPalette.white.withValues(alpha: bottom.clamp(0.0, 1.0)),
        ],
      );
    }

    LinearGradient stroke() {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                AppPalette.white
                    .withValues(alpha: AppGlassTokens.strokeDarkTop),
                AppPalette.white
                    .withValues(alpha: AppGlassTokens.strokeDarkBottom),
              ]
            : [
                AppPalette.white
                    .withValues(alpha: AppGlassTokens.strokeLightTop),
                AppPalette.iris200
                    .withValues(alpha: AppGlassTokens.strokeLightBottom),
              ],
        stops: const [0.0, 0.75],
      );
    }

    List<BoxShadow> shadows(double scale) {
      return [
        BoxShadow(
          color: colors.shadow.withValues(
            alpha: (isDark
                    ? AppGlassTokens.shadowOpacityDark
                    : AppGlassTokens.shadowOpacityLight) *
                scale,
          ),
          blurRadius: (isDark
                  ? AppGlassTokens.shadowBlurDark
                  : AppGlassTokens.shadowBlurLight) *
              scale,
          offset: Offset(0, 14 * scale),
          spreadRadius: -12,
        ),
        BoxShadow(
          color: colors.primary.withValues(
            alpha: (isDark
                    ? AppGlassTokens.glowOpacityDark
                    : AppGlassTokens.glowOpacityLight) *
                scale,
          ),
          blurRadius: 56 * scale,
          offset: Offset(0, 18 * scale),
          spreadRadius: -24,
        ),
      ];
    }

    Color fallback(double alpha) => Color.alphaBlend(
          AppPalette.white.withValues(alpha: isDark ? 0.08 : 0.86),
          colors.canvas,
        ).withValues(alpha: alpha);

    return GlassTheme(
      subtle: GlassSurfaceStyle(
        blurSigma: AppGlassTokens.blurSubtle,
        saturation: isDark
            ? AppGlassTokens.saturationDark
            : AppGlassTokens.saturationLight,
        fill: fill(AppGlassTokens.levelSubtleFactor),
        stroke: stroke(),
        strokeWidth: AppGlassTokens.strokeWidth,
        shadows: shadows(0.5),
        radius: AppRadius.large,
        opaqueFallback: fallback(1),
      ),
      regular: GlassSurfaceStyle(
        blurSigma: AppGlassTokens.blurRegular,
        saturation: isDark
            ? AppGlassTokens.saturationDark
            : AppGlassTokens.saturationLight,
        fill: fill(AppGlassTokens.levelRegularFactor),
        stroke: stroke(),
        strokeWidth: AppGlassTokens.strokeWidth,
        shadows: shadows(1),
        radius: AppRadius.xLarge,
        opaqueFallback: fallback(1),
      ),
      elevated: GlassSurfaceStyle(
        blurSigma: AppGlassTokens.blurStrong,
        saturation: isDark
            ? AppGlassTokens.saturationDark
            : AppGlassTokens.saturationLight,
        fill: fill(AppGlassTokens.levelElevatedFactor),
        stroke: stroke(),
        strokeWidth: AppGlassTokens.strokeWidth,
        shadows: shadows(1.35),
        radius: AppRadius.xxLarge,
        opaqueFallback: fallback(1),
      ),
      canvasGradient:
          isDark ? AppGradients.canvasDark : AppGradients.canvasLight,
      auroraOrbs: isDark ? AppGradients.auroraDark : AppGradients.auroraLight,
      brandGradient:
          isDark ? AppGradients.brandDark : AppGradients.brandLight,
      coolGradient: isDark ? AppGradients.coolDark : AppGradients.coolLight,
      warmGradient: isDark ? AppGradients.warmDark : AppGradients.warmLight,
      onGradient: isDark ? AppPalette.ink950 : AppPalette.white,
      dividerColor: colors.outline.withValues(alpha: isDark ? 0.35 : 0.5),
    );
  }

  @override
  GlassTheme copyWith({
    GlassSurfaceStyle? subtle,
    GlassSurfaceStyle? regular,
    GlassSurfaceStyle? elevated,
    Gradient? canvasGradient,
    List<AuroraOrb>? auroraOrbs,
    LinearGradient? brandGradient,
    LinearGradient? coolGradient,
    LinearGradient? warmGradient,
    Color? onGradient,
    Color? dividerColor,
  }) {
    return GlassTheme(
      subtle: subtle ?? this.subtle,
      regular: regular ?? this.regular,
      elevated: elevated ?? this.elevated,
      canvasGradient: canvasGradient ?? this.canvasGradient,
      auroraOrbs: auroraOrbs ?? this.auroraOrbs,
      brandGradient: brandGradient ?? this.brandGradient,
      coolGradient: coolGradient ?? this.coolGradient,
      warmGradient: warmGradient ?? this.warmGradient,
      onGradient: onGradient ?? this.onGradient,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  GlassTheme lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      subtle: GlassSurfaceStyle.lerp(subtle, other.subtle, t),
      regular: GlassSurfaceStyle.lerp(regular, other.regular, t),
      elevated: GlassSurfaceStyle.lerp(elevated, other.elevated, t),
      canvasGradient:
          Gradient.lerp(canvasGradient, other.canvasGradient, t) ??
              other.canvasGradient,
      auroraOrbs: AuroraOrb.lerpList(auroraOrbs, other.auroraOrbs, t),
      brandGradient:
          LinearGradient.lerp(brandGradient, other.brandGradient, t) ??
              other.brandGradient,
      coolGradient: LinearGradient.lerp(coolGradient, other.coolGradient, t) ??
          other.coolGradient,
      warmGradient: LinearGradient.lerp(warmGradient, other.warmGradient, t) ??
          other.warmGradient,
      onGradient: Color.lerp(onGradient, other.onGradient, t) ?? other.onGradient,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? other.dividerColor,
    );
  }
}
