import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../glass_theme.dart';
import '../tokens/app_spacing.dart';
import 'glass_container.dart';

/// Botão circular de vidro.
///
/// Usado em ações flutuantes sobre conteúdo (avançar seção, alternar tema),
/// onde um botão sólido roubaria atenção do conteúdo.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconSize = 22,
    this.level = GlassLevel.regular,
    this.iconColor,
    this.gradient,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final GlassLevel level;
  final Color? iconColor;

  /// Preenchimento sólido opcional (para a ação principal flutuante).
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Color foreground = iconColor ??
        (gradient != null ? context.glass.onGradient : context.colors.textPrimary);

    final Widget glyph = Icon(icon, size: iconSize, color: foreground);

    final Widget button = gradient != null
        ? Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary
                      .withValues(alpha: context.isDark ? 0.45 : 0.3),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: glyph,
          )
        : GlassContainer(
            level: level,
            width: size,
            height: size,
            alignment: Alignment.center,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: glyph,
          );

    final Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: button,
    );

    if (tooltip == null) {
      return Semantics(button: true, child: tappable);
    }
    return Tooltip(message: tooltip!, child: tappable);
  }
}
