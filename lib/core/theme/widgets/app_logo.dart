import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  const AppLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Kno',
            style: TextStyle(
              fontFamily: GoogleFonts.yatraOne().fontFamily,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: size ?? 28,
            ),
          ),
          TextSpan(
            text: 'w',
            style: TextStyle(
              fontFamily: GoogleFonts.yatraOne().fontFamily,
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: size ?? 28,
            ),
          ),
          TextSpan(
            text: 'hen',
            style: TextStyle(
              fontFamily: GoogleFonts.yatraOne().fontFamily,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: size ?? 28,
            ),
          ),
        ],
      ),
    );
  }
}
