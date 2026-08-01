import 'package:flutter/material.dart';

import '../tokens/app_motion.dart';

/// Entrada em cascata: fade + leve deslocamento vertical.
///
/// O movimento fica em cima do vidro (nunca atrás), então não força o
/// `BackdropFilter` a recalcular o desfoque da cena inteira.
///
/// `order` define o degrau do stagger — 0 entra primeiro.
class GlassReveal extends StatefulWidget {
  const GlassReveal({
    super.key,
    required this.child,
    this.order = 0,
    this.offset = AppMotion.revealOffset,
    this.duration = AppMotion.slow,
    this.enabled = true,
  });

  final Widget child;
  final int order;
  final double offset;
  final Duration duration;
  final bool enabled;

  @override
  State<GlassReveal> createState() => _GlassRevealState();
}

class _GlassRevealState extends State<GlassReveal>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = AppMotion.stagger * widget.order;
  late final Duration _total = _delay + widget.duration;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );

  /// O atraso do stagger vive dentro da própria curva (`Interval`), não em um
  /// `Timer`: assim não há callback pendente para disparar depois do dispose
  /// nem timer solto para travar testes de widget.
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _total.inMicroseconds == 0 ? 0 : _delay.inMicroseconds / _total.inMicroseconds,
      1,
      curve: AppMotion.emphasized,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respeita "reduzir movimento" do sistema: sem deslocamento, só opacidade.
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: reduceMotion
              ? child
              : Transform.translate(
                  offset: Offset(0, (1 - t) * widget.offset),
                  child: child,
                ),
        );
      },
      child: widget.child,
    );
  }
}
