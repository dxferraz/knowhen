import 'package:flutter/material.dart';

/// Entrada de um elemento do cartão (DXF-9, 2.5): fade e deslocamento de 16 dp em 400 ms, `easeOutCubic`, com cada
/// elemento começando [stagger] depois do anterior. Com `disableAnimations` o elemento já aparece no lugar.
class KnEntrance extends StatefulWidget {
  const KnEntrance({super.key, required this.child, this.order = 0});

  final Widget child;

  /// Posição do elemento na sequência de entrada do cartão (0 = primeiro).
  final int order;

  static const Duration duration = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 60);
  static const double offset = 16;

  @override
  State<KnEntrance> createState() => _KnEntranceState();
}

class _KnEntranceState extends State<KnEntrance> with SingleTickerProviderStateMixin {
  late final Duration _delay = KnEntrance.stagger * widget.order;
  late final AnimationController _controller = AnimationController(vsync: this, duration: KnEntrance.duration + _delay);
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delay.inMilliseconds / _controller.duration!.inMilliseconds, 1, curve: Curves.easeOutCubic),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(offset: Offset(0, KnEntrance.offset * (1 - _progress.value)), child: child),
      ),
    );
  }
}
