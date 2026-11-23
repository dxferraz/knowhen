import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Barra de progresso em segmentos, no padrão "stories" (DXF-9, 2.4). Os segmentos até [current] ficam
/// preenchidos; ao avançar, o novo segmento enche em 250 ms (sem animação com `disableAnimations`).
class KnStoryProgress extends StatelessWidget {
  const KnStoryProgress({super.key, required this.count, required this.current, required this.semanticsLabel})
    : assert(count > 0),
      assert(current >= 0 && current < count);

  final int count;

  /// Índice (a partir de 0) do cartão atual.
  final int current;

  /// O que o leitor de tela anuncia ("Cartão 2 de 5"). Vem do l10n, com o número já aplicado.
  final String semanticsLabel;

  static const double segmentHeight = 4;
  static const Duration fillDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : fillDuration;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: KnSpace.xs + 2),
            Expanded(
              child: _Segment(filled: i <= current, duration: duration),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.filled, required this.duration});

  final bool filled;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    return ClipRRect(
      borderRadius: BorderRadius.circular(KnStoryProgress.segmentHeight / 2),
      child: ColoredBox(
        color: c.outline,
        child: SizedBox(
          height: KnStoryProgress.segmentHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: filled ? 1 : 0),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: ColoredBox(color: c.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
