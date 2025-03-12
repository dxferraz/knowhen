import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget {
  
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme(Theme.of(context).brightness == Brightness.light);
      },
    );
  }
}
