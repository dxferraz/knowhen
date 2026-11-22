import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Fundo das telas: gradiente vertical de `bgTop` a `bg` e, no tema escuro, um campo de estrelas estático
/// (DXF-9, 2.4). As estrelas são decorativas e não aparecem para leitores de tela.
class KnBackground extends StatelessWidget {
  const KnBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.bgTop, c.bg],
          stops: const [0, 0.55],
        ),
      ),
      child: CustomPaint(painter: c.isDark ? const _StarsPainter() : null, child: child),
    );
  }
}

class _Star {
  const _Star(this.dx, this.dy, this.radius, this.alpha);

  /// Posição como fração da largura e da altura do fundo.
  final double dx;
  final double dy;
  final double radius;
  final double alpha;
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  /// Estrelas só no alto da tela (60%), com semente fixa para a imagem ser a mesma em todo build e golden.
  static final List<_Star> _stars = () {
    final rnd = math.Random(7);
    return List.generate(70, (_) {
      return _Star(
        rnd.nextDouble(),
        rnd.nextDouble() * 0.6,
        0.5 + rnd.nextDouble() * 1.1,
        0.15 + rnd.nextDouble() * 0.45,
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in _stars) {
      paint.color = Colors.white.withValues(alpha: s.alpha);
      canvas.drawCircle(Offset(s.dx * size.width, s.dy * size.height), s.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
