import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Superfície com borda de 1 px, sem blur (DXF-9, 2.3). No escuro a elevação é só a borda; no claro, uma
/// sombra índigo suave (6%, blur 24).
class KnCard extends StatelessWidget {
  const KnCard({super.key, required this.child, this.padding = const EdgeInsets.all(KnSpace.xl)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.isDark ? c.surface.withValues(alpha: 0.85) : c.surface,
        borderRadius: BorderRadius.circular(KnRadius.md),
        border: Border.all(color: c.outline),
        boxShadow: c.isDark
            ? null
            : [BoxShadow(color: c.primary.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}
