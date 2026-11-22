import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/constants/spacing.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final String? tooltip;

  const CustomIconButton({super.key, required this.icon, required this.iconColor, required this.backgroundColor, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: iconColor),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.all(AppSpacing.medium),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
