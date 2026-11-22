import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

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
              fontFamily: KnFonts.logo,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: size ?? 28,
            ),
          ),
          TextSpan(
            text: 'w',
            style: TextStyle(
              fontFamily: KnFonts.logo,
              color: context.kn.isDark ? context.kn.primary : context.kn.accentText,
              fontSize: size ?? 28,
            ),
          ),
          TextSpan(
            text: 'hen',
            style: TextStyle(
              fontFamily: KnFonts.logo,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: size ?? 28,
            ),
          ),
        ],
      ),
    );
  }
}
