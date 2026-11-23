import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Botão de ícone com área de toque de 48 dp (círculo visível de 40) e rótulo obrigatório, usado pelo leitor
/// de tela e como dica ao segurar (DXF-9, 2.4). [onPressed] nulo deixa o botão desabilitado.
class KnIconButton extends StatelessWidget {
  const KnIconButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;

  /// O que o botão faz ("Mudar para tema claro", "Fechar resumo").
  final String label;
  final VoidCallback? onPressed;

  static const double _visual = 40;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            radius: KnSize.touchTarget / 2,
            child: SizedBox.square(
              dimension: KnSize.touchTarget,
              child: Center(
                child: Container(
                  width: _visual,
                  height: _visual,
                  decoration: BoxDecoration(
                    color: c.surfaceHi,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.outline),
                  ),
                  child: Icon(icon, size: 20, color: enabled ? c.ink : c.inkMuted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
