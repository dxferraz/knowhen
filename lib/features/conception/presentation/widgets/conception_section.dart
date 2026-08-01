import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/theme.dart';

class ConceptionSection extends StatelessWidget {
  const ConceptionSection({super.key, required this.birthDate});

  final DateTime birthDate;

  ({String start, String end}) _conceptionRange() {
    final DateTime conception = birthDate.subtract(const Duration(days: 280));
    final DateFormat format = DateFormat('dd/MM/yyyy');
    return (
      start: format.format(conception.subtract(const Duration(days: 7))),
      end: format.format(conception.add(const Duration(days: 7))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final range = _conceptionRange();

    return AppSection(
      eyebrow: 'Concepção',
      title: 'Muito provavelmente, no período de:',
      footer: const AppText.bodyLarge(
        'Foi quando a cegonha te levou ao colo da sua mãe.',
        align: TextAlign.center,
      ),
      child: GlassCard(
        level: GlassLevel.regular,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Duas datas empilhadas com um conector no meio leem melhor que
            // "data a data" em uma linha só — e não quebram em telas estreitas.
            _RangeBound(label: 'de', value: range.start, gradient: glass.coolGradient),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
              child: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: context.colors.textTertiary,
              ),
            ),
            _RangeBound(label: 'até', value: range.end, gradient: glass.warmGradient),
          ],
        ),
      ),
    );
  }
}

class _RangeBound extends StatelessWidget {
  const _RangeBound({
    required this.label,
    required this.value,
    required this.gradient,
  });

  final String label;
  final String value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.overline(label),
        const SizedBox(height: AppSpacing.xSmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText.numeric(value, gradient: gradient, maxLines: 1),
        ),
      ],
    );
  }
}
