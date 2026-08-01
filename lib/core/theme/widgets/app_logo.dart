import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_typography.dart';
import 'app_text.dart';

/// Logotipo do app.
///
/// A marca segue com a tipografia original (`Yatra One`), mas o "w" agora
/// recebe o gradiente da marca em vez de um âmbar chapado — é o ponto onde a
/// identidade encosta no novo sistema de cor.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size, this.color});

  final double? size;

  /// Cor das letras neutras. Padrão: texto primário do tema.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double fontSize = size ?? 28;
    final Color base = color ?? context.colors.textPrimary;
    final TextStyle style = AppTypography.brand(size: fontSize, color: base);

    return Semantics(
      label: 'Knowhen',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('Kno', style: style),
          GradientMask(
            gradient: context.glass.warmGradient,
            child: Text('w', style: style.copyWith(color: AppPalette.white)),
          ),
          Text('hen', style: style),
        ],
      ),
    );
  }
}
