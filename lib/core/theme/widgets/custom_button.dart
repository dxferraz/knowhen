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
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor ?? Theme.of(context).primaryColor),
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
