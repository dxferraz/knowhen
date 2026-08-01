import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../tokens/app_glass.dart';
import '../tokens/app_gradients.dart';
import '../tokens/app_motion.dart';

/// Cena de fundo do app: gradiente base + orbes de aurora.
///
/// É a camada que dá sentido ao vidro. Um painel translúcido sobre um fundo
/// chapado parece só um card cinza; sobre a aurora, ele refrata cor e ganha
/// profundidade.
///
/// A animação é opcional e desligada por padrão — ver `AppGlassConfig`.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.animated,
    this.orbs,
  });

  final Widget? child;

  /// Sobrescreve `AppGlassConfig.animatedAurora` localmente.
  final bool? animated;

  /// Permite a uma tela pintar a própria cena (ex.: seção da lua mais fria).
  final List<AuroraOrb>? orbs;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final List<AuroraOrb> sceneOrbs = orbs ?? glass.auroraOrbs;
    final bool isAnimated = animated ?? AppGlassConfig.animatedAurora;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: glass.canvasGradient),
            child: _AuroraLayer(orbs: sceneOrbs, animated: isAnimated),
          ),
        ),
        ?child,
      ],
    );
  }
}

class _AuroraLayer extends StatefulWidget {
  const _AuroraLayer({required this.orbs, required this.animated});

  final List<AuroraOrb> orbs;
  final bool animated;

  @override
  State<_AuroraLayer> createState() => _AuroraLayerState();
}

class _AuroraLayerState extends State<_AuroraLayer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(_AuroraLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) _syncController();
  }

  void _syncController() {
    if (widget.animated) {
      _controller ??= AnimationController(
        vsync: this,
        duration: AppMotion.ambient,
      )..repeat();
    } else {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _AuroraOrbs(orbs: widget.orbs, phase: 0);
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) =>
          _AuroraOrbs(orbs: widget.orbs, phase: controller.value),
    );
  }
}

class _AuroraOrbs extends StatelessWidget {
  const _AuroraOrbs({required this.orbs, required this.phase});

  final List<AuroraOrb> orbs;

  /// 0..1 — posição no ciclo de deriva.
  final double phase;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );

        return IgnorePointer(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (int i = 0; i < orbs.length; i++)
                _buildOrb(orbs[i], i, size),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrb(AuroraOrb orb, int index, Size size) {
    final double diameter = size.longestSide * orb.diameterFactor;

    // Cada orbe deriva em uma elipse pequena, defasado dos demais, para que a
    // cena nunca "pulse" em bloco.
    final double angle = (phase + index / orbs.length) * 2 * math.pi;
    final double driftX = phase == 0 ? 0 : math.cos(angle) * 22;
    final double driftY = phase == 0 ? 0 : math.sin(angle) * 16;

    // `Positioned` (e não `Align`) porque o orbe é propositalmente maior que a
    // tela: `Align` clamparia o diâmetro nas constraints do pai.
    final double centerX = (orb.alignment.x + 1) / 2 * size.width;
    final double centerY = (orb.alignment.y + 1) / 2 * size.height;

    return Positioned(
      left: centerX - diameter / 2 + driftX,
      top: centerY - diameter / 2 + driftY,
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              orb.color.withValues(alpha: orb.opacity),
              orb.color.withValues(alpha: orb.opacity * 0.45),
              orb.color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
