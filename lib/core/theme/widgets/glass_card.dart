import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../glass_theme.dart';
import '../tokens/app_spacing.dart';
import 'app_text.dart';
import 'glass_container.dart';

/// Card de conteúdo — a unidade de composição das telas.
///
/// Estrutura opcional: `eyebrow` (rótulo em caixa alta) → `title` → conteúdo.
/// Ter os três slots padronizados é o que faz telas diferentes parecerem do
/// mesmo app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
    this.leading,
    this.trailing,
    this.level = GlassLevel.regular,
    this.padding = const EdgeInsets.all(AppSpacing.large),
    this.margin,
    this.onTap,
    this.accent,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final Widget child;
  final String? eyebrow;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final GlassLevel level;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  /// Cor de destaque do `eyebrow` — sinaliza o assunto do card
  /// (tempo, céu, história) sem precisar de ícone.
  final Color? accent;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final bool hasHeader =
        eyebrow != null || title != null || leading != null || trailing != null;

    return GlassContainer(
      level: level,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.sMedium),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null)
                        AppText.overline(
                          eyebrow!,
                          color: accent ?? context.colors.primary,
                        ),
                      if (eyebrow != null && title != null)
                        const SizedBox(height: AppSpacing.xSmall),
                      if (title != null) AppText.title(title!),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sMedium),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          child,
        ],
      ),
    );
  }
}

/// Métrica destacada: número grande + rótulo.
///
/// Números usam algarismos tabulares e podem receber gradiente — é o
/// elemento que carrega a informação principal do app.
class GlassStatTile extends StatelessWidget {
  const GlassStatTile({
    super.key,
    required this.value,
    required this.label,
    this.gradient,
    this.valueColor,
    this.compact = false,
    this.align = CrossAxisAlignment.center,
  });

  final String value;
  final String label;
  final Gradient? gradient;
  final Color? valueColor;

  /// Reduz o número para uso em linhas com três ou mais métricas.
  final bool compact;

  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final TextAlign textAlign = switch (align) {
      CrossAxisAlignment.start => TextAlign.start,
      CrossAxisAlignment.end => TextAlign.end,
      _ => TextAlign.center,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        if (compact)
          AppText.numeric(
            value,
            gradient: gradient,
            color: valueColor,
            align: textAlign,
            maxLines: 1,
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AppText.numericHero(
              value,
              gradient: gradient,
              color: valueColor,
              align: textAlign,
              maxLines: 1,
            ),
          ),
        const SizedBox(height: AppSpacing.xSmall),
        AppText.overline(label, align: textAlign),
      ],
    );
  }
}

/// Selo curto (ex.: "IA", "Lua cheia").
class GlassBadge extends StatelessWidget {
  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tone = color ?? context.colors.primary;

    return GlassContainer(
      level: GlassLevel.subtle,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sMedium,
        vertical: AppSpacing.xSmall + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tone),
            const SizedBox(width: AppSpacing.xSmall + 2),
          ],
          AppText.overline(label, color: tone),
        ],
      ),
    );
  }
}
