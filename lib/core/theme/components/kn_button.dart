import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

enum KnButtonKind { primary, secondary, ghost }

/// Botão em pílula de 56 dp (DXF-9, 2.4). [onPressed] nulo deixa o botão desabilitado.
///
/// O rótulo quebra em várias linhas com fonte grande e a altura cresce junto, nunca abaixo de 56 dp.
class KnButton extends StatelessWidget {
  const KnButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = KnButtonKind.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final KnButtonKind kind;

  /// Ícone opcional à direita do rótulo.
  final IconData? icon;

  /// Ocupa toda a largura disponível; senão, só a do conteúdo.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final enabled = onPressed != null;

    final Color bg;
    final Color fg;
    BorderSide? side;
    switch (kind) {
      case KnButtonKind.primary:
        bg = enabled ? c.primary : c.surfaceHi;
        fg = enabled ? c.onPrimary : c.inkMuted;
      case KnButtonKind.secondary:
        bg = c.surfaceHi;
        fg = enabled ? c.ink : c.inkMuted;
        side = BorderSide(color: c.outline);
      case KnButtonKind.ghost:
        bg = Colors.transparent;
        fg = enabled ? c.ink : c.inkMuted;
    }

    final shape = StadiumBorder(side: side ?? BorderSide.none);
    final textStyle = context.knText.label.copyWith(fontSize: 16, color: fg);

    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: bg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: KnSize.button,
              minWidth: expand ? double.infinity : KnSize.touchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl, vertical: KnSpace.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(label, textAlign: TextAlign.center, style: textStyle),
                  ),
                  if (icon != null) ...[const SizedBox(width: KnSpace.sm), Icon(icon, size: 20, color: fg)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
