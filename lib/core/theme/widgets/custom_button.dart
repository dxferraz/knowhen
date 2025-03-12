import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final String text;

  const CustomButton({super.key, required this.onPressed, this.backgroundColor, required this.text});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
