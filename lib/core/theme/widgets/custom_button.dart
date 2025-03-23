import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String text;

  const CustomButton({super.key, required this.onPressed, this.backgroundColor, required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        elevation: 0,
        overlayColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
