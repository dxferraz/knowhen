import 'package:flutter/material.dart';

import 'glass_button.dart';

/// Camada de compatibilidade — prefira [GlassButton] em código novo.
///
/// O mapeamento preserva a intenção das chamadas antigas:
/// `backgroundColor: Colors.transparent` vira ação terciária (`ghost`),
/// qualquer outra cor vira ação primária tingida com essa cor.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    final bool isGhost = backgroundColor?.a == 0;

    return GlassButton(
      label: text,
      onPressed: onPressed,
      variant: isGhost ? AppButtonVariant.ghost : AppButtonVariant.primary,
      foregroundColor: textColor,
      gradient: (isGhost || backgroundColor == null)
          ? null
          : LinearGradient(colors: [backgroundColor!, backgroundColor!]),
    );
  }
}
