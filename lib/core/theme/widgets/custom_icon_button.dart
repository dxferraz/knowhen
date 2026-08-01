import 'package:flutter/material.dart';

import 'glass_icon_button.dart';

/// Camada de compatibilidade — prefira [GlassIconButton] em código novo.
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
      gradient: LinearGradient(colors: [backgroundColor, backgroundColor]),
    );
  }
}
