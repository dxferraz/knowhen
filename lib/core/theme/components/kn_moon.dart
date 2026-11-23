import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Lua desenhada em `CustomPainter` para qualquer fração de fase; substitui as imagens do Storage.
///
/// [phase] em [0, 1): 0 = nova, 0.25 = quarto crescente, 0.5 = cheia, 0.75 = quarto minguante. Valores fora do
/// intervalo dão a volta (1.0 = 0.0). É decorativa: sem [semanticsLabel], o leitor de tela a ignora.
class KnMoon extends StatelessWidget {
  const KnMoon({super.key, required this.phase, this.size = 160, this.glow = true, this.semanticsLabel});

  final double phase;
  final double size;

  /// Halo suave atrás da lua.
  final bool glow;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    final moon = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: KnMoonPainter(
          phase: phase,
          moon: c.moon,
          shadow: c.moonShadow,
          glowAlpha: glow ? (c.isDark ? 0.18 : 0.25) : 0,
        ),
      ),
    );
    if (semanticsLabel == null) return ExcludeSemantics(child: moon);
    return Semantics(label: semanticsLabel, image: true, excludeSemantics: true, child: moon);
  }
}

class KnMoonPainter extends CustomPainter {
  const KnMoonPainter({required this.phase, required this.moon, required this.shadow, required this.glowAlpha});

  final double phase;
  final Color moon;
  final Color shadow;

  /// Opacidade do halo; 0 desliga.
  final double glowAlpha;

  /// O disco ocupa 82% do raio para sobrar espaço ao halo.
  static const double discRatio = 0.82;

  /// Fase normalizada para [0, 1).
  static double normalize(double phase) => phase - phase.floorToDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    if (glowAlpha > 0) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = moon.withValues(alpha: glowAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25),
      );
    }

    final disc = r * discRatio;
    canvas.drawCircle(center, disc, Paint()..color = shadow);
    canvas.drawCircle(
      center,
      disc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = moon.withValues(alpha: 0.35),
    );

    final p = normalize(phase);
    final k = math.cos(2 * math.pi * p); // 1 = nova, -1 = cheia
    if (k > 0.999) return;

    canvas.save();
    // Até a cheia o lado iluminado é o direito; depois da cheia, o esquerdo.
    if (p >= 0.5) {
      canvas.translate(center.dx * 2, 0);
      canvas.scale(-1, 1);
    }
    final top = Offset(center.dx, center.dy - disc);
    final bottom = Offset(center.dx, center.dy + disc);
    final lit = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(bottom, radius: Radius.circular(disc), clockwise: true)
      ..arcToPoint(top, radius: Radius.elliptical(math.max(disc * k.abs(), 0.01), disc), clockwise: k < 0);
    canvas.drawPath(lit, Paint()..color = moon);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant KnMoonPainter old) =>
      old.phase != phase || old.moon != moon || old.shadow != shadow || old.glowAlpha != glowAlpha;
}
