import 'package:flutter/material.dart';

import 'glass_theme.dart';
import 'tokens/app_colors.dart';

/// Atalhos de acesso ao design system.
///
/// Em vez de `Theme.of(context).colorScheme.onSurfaceVariant`, escreva
/// `context.colors.textSecondary` — o nome diz a função, não a aparência.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Tokens semânticos de cor do brilho atual.
  AppColors get colors => AppColors.of(Theme.of(this).brightness);

  /// `ColorScheme` Material (para widgets nativos).
  ColorScheme get scheme => Theme.of(this).colorScheme;

  /// Parâmetros do material de vidro.
  GlassTheme get glass =>
      Theme.of(this).extension<GlassTheme>() ??
      GlassTheme.of(Theme.of(this).brightness);

  TextTheme get texts => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Largura útil descontando o gutter das telas.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// `true` em telas baixas (ex.: iPhone SE), onde seções de tela cheia
  /// precisam rolar em vez de distribuir espaço.
  bool get isCompactHeight => MediaQuery.sizeOf(this).height < 700;
}
