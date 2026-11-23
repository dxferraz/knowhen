import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Número em serifa e legenda. Com fonte grande o número encolhe em vez de quebrar ou encostar no vizinho.
/// O leitor de tela lê os dois juntos ("35 anos").
class KnStat extends StatelessWidget {
  const KnStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = context.knText;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: KnSpace.md),
              child: Text(value, style: text.stat),
            ),
          ),
          const SizedBox(height: KnSpace.xs),
          Text(label, style: text.caption),
        ],
      ),
    );
  }
}

/// Categoria do cartão em caixa alta, com o estilo `eyebrow` (que não traz a caixa alta sozinho).
class KnEyebrow extends StatelessWidget {
  const KnEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: context.knText.eyebrow);
}
