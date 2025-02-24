import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget {
  
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode),
      onPressed: () {
        isDark = !isDark;
        themeProvider.toggleTheme(isDark);
      },
    );
  }
}
