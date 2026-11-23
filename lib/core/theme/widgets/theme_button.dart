import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Alterna entre o tema claro e o escuro. O rótulo diz para qual tema o botão leva.
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return KnIconButton(
      icon: isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      label: isLight ? l10n.themeSwitchToDark : l10n.themeSwitchToLight,
      onPressed: () => Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).toggleTheme(isLight),
    );
  }
}
