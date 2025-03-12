import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final Color? color;
  const AppLogo({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Knowhen',
      style: TextStyle(
        fontFamily: GoogleFonts.rampartOne().fontFamily,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontSize: size ?? 28,
      ),
    );
  }
}
