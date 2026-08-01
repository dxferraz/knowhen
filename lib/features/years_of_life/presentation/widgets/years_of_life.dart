import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/int_formatter.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/life_clock.dart';

class YearsOfLifeSection extends StatelessWidget {
  const YearsOfLifeSection({
    super.key,
    required this.birthDate,
    required this.birthTime,
  });

  final DateTime birthDate;
  final TimeOfDay? birthTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final glass = context.glass;
    final Duration lived = DateTime.now().difference(birthDate);

    return AppSection(
      eyebrow: 'Tempo de vida',
      title: l10n.yearsOfLifeTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassCard(
            level: GlassLevel.regular,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GlassStatTile(
                    value: IntFormatter.format(lived.inDays ~/ 365),
                    label: 'anos',
                    gradient: glass.brandGradient,
                    compact: true,
                  ),
                ),
                _Divider(color: glass.dividerColor),
                Expanded(
                  child: GlassStatTile(
                    value: IntFormatter.format(lived.inDays ~/ 30),
                    label: 'meses',
                    gradient: glass.coolGradient,
                    compact: true,
                  ),
                ),
                _Divider(color: glass.dividerColor),
                Expanded(
                  child: GlassStatTile(
                    value: IntFormatter.format(lived.inDays),
                    label: 'dias',
                    gradient: glass.warmGradient,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          if (birthTime != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Flexible(
              child: LifeClock(
                birthDateTime: birthDate,
                birthTime: birthTime!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
      color: color,
    );
  }
}
