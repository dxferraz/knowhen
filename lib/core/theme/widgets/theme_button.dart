import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../context_extensions.dart';
import '../theme_provider.dart';
import '../tokens/app_motion.dart';
import 'glass_icon_button.dart';

/// Alternador de tema claro/escuro.
///
/// A troca do ícone é animada (giro + fade) porque a mudança de tema é a
/// transição mais visível do app — vale marcá-la.
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;

    return GlassIconButton(
      size: size,
      iconSize: 18,
      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      tooltip: isDark ? 'Tema claro' : 'Tema escuro',
      iconColor: isDark ? context.colors.tertiary : context.colors.primary,
      onPressed: () {
        context.read<ThemeProvider>().toggleTheme(!isDark);
      },
    );
  }
}

/// Versão animada usada quando o botão fica em destaque (ex.: onboarding).
class AnimatedThemeIcon extends StatelessWidget {
  const AnimatedThemeIcon({super.key, required this.isDark, this.size = 18});

  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.standard,
      transitionBuilder: (child, animation) => RotationTransition(
        turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        key: ValueKey<bool>(isDark),
        size: size,
        color: isDark ? context.colors.tertiary : context.colors.primary,
      ),
    );
  }
}
