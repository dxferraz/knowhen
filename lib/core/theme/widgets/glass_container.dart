import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../glass_theme.dart';
import '../tokens/app_glass.dart';
import '../tokens/app_motion.dart';

/// Primitivo do design system: uma superfície de vidro.
///
/// Todo painel translúcido do app nasce daqui. A composição segue a ordem
/// física de um vidro real:
///
/// 1. **Sombra** — desenhada apenas para fora do painel (`_GlassShadowPainter`).
///    Se ficasse embaixo, o `BackdropFilter` a capturaria e o vidro encardiria.
/// 2. **Backdrop** — desfoque + saturação do que está atrás.
/// 3. **Tint** — gradiente branco diagonal (a "espessura" do vidro).
/// 4. **Traço** — hairline em gradiente, mais forte na quina de luz.
///
/// Quando `AppGlassConfig.enableBlur` é `false`, cai automaticamente para uma
/// superfície opaca equivalente, sem mudar nenhuma medida do layout.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.level = GlassLevel.regular,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.borderRadius,
    this.blurSigma,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.shadows,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget? child;
  final GlassLevel level;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  /// Sobrescreve o raio do nível. Prefira manter o padrão do token.
  final BorderRadius? borderRadius;

  final double? blurSigma;
  final Gradient? fill;
  final Gradient? stroke;
  final double? strokeWidth;
  final List<BoxShadow>? shadows;

  /// Quando informado, o painel ganha feedback de toque (escala sutil).
  final VoidCallback? onTap;

  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final GlassSurfaceStyle style = context.glass.styleFor(level);
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(style.radius);
    final double sigma = blurSigma ?? style.blurSigma;
    final Gradient tint = fill ?? style.fill;
    final Gradient strokeGradient = stroke ?? style.stroke;
    final double strokeSize = strokeWidth ?? style.strokeWidth;
    final List<BoxShadow> boxShadows = shadows ?? style.shadows;

    Widget surface = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: AppGlassConfig.enableBlur ? tint : null,
        color: AppGlassConfig.enableBlur ? null : style.opaqueFallback,
      ),
      child: child,
    );

    if (AppGlassConfig.enableBlur) {
      surface = BackdropFilter(
        filter: buildGlassFilter(
          sigma: sigma,
          saturation: style.saturation,
        ),
        child: surface,
      );
    }

    Widget panel = ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: surface,
    );

    panel = CustomPaint(
      painter: _GlassShadowPainter(radius: radius, shadows: boxShadows),
      foregroundPainter: _GlassStrokePainter(
        radius: radius,
        gradient: strokeGradient,
        strokeWidth: strokeSize,
      ),
      child: panel,
    );

    if (onTap != null) {
      panel = _PressableGlass(onTap: onTap!, child: panel);
    }

    if (margin != null) {
      panel = Padding(padding: margin!, child: panel);
    }

    return panel;
  }
}

/// Feedback de toque para vidro.
///
/// Ripple do Material não funciona bem sobre superfícies translúcidas (a onda
/// some no tint). Uma redução de escala curta comunica melhor o pressionar.
class _PressableGlass extends StatefulWidget {
  const _PressableGlass({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableGlass> createState() => _PressableGlassState();
}

class _PressableGlassState extends State<_PressableGlass> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}

/// Desenha as sombras recortando o interior do painel.
class _GlassShadowPainter extends CustomPainter {
  const _GlassShadowPainter({required this.radius, required this.shadows});

  final BorderRadius radius;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;

    final Rect bounds = Offset.zero & size;
    final RRect rrect = radius.toRRect(bounds);

    // A área pintada precisa ser justa: um retângulo folgado demais aumenta o
    // cull rect da camada e faz o `BackdropFilter` vizinho amostrar (e tingir)
    // a tela inteira em vez de apenas o painel.
    double reach = 0;
    for (final BoxShadow shadow in shadows) {
      final double extent = shadow.blurRadius * 1.5 +
          shadow.spreadRadius.abs() +
          shadow.offset.distance;
      if (extent > reach) reach = extent;
    }

    // Recorta o miolo para que nenhuma sombra fique atrás do vidro —
    // é isso que mantém o painel limpo no tema claro.
    final Path outer = Path()..addRect(bounds.inflate(reach + 1));
    final Path inner = Path()..addRRect(rrect);
    canvas.save();
    canvas.clipPath(Path.combine(ui.PathOperation.difference, outer, inner));

    for (final BoxShadow shadow in shadows) {
      final RRect shifted = rrect
          .shift(shadow.offset)
          .inflate(shadow.spreadRadius);
      canvas.drawRRect(shifted, shadow.toPaint());
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassShadowPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.shadows != shadows;
}

/// Hairline em gradiente — a "quina de luz" que define a borda do vidro.
class _GlassStrokePainter extends CustomPainter {
  const _GlassStrokePainter({
    required this.radius,
    required this.gradient,
    required this.strokeWidth,
  });

  final BorderRadius radius;
  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0) return;

    final Rect bounds = Offset.zero & size;
    // Desloca meia espessura para dentro para o traço não ser cortado
    // pelo ClipRRect do painel.
    final Rect inset = bounds.deflate(strokeWidth / 2);
    final RRect rrect = radius.toRRect(inset);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(bounds)
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassStrokePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.gradient != gradient ||
      oldDelegate.strokeWidth != strokeWidth;
}
