import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/int_formatter.dart';
import 'package:knowhen/core/theme/theme.dart';

/// Relógio da vida — horas, minutos e segundos desde o nascimento.
///
/// É o único elemento do app que muda a cada segundo, então usa algarismos
/// tabulares: sem eles a largura dos números oscila e o card "treme".
class LifeClock extends StatefulWidget {
  const LifeClock({
    super.key,
    required this.birthDateTime,
    required this.birthTime,
  });

  final DateTime birthDateTime;
  final TimeOfDay birthTime;

  @override
  State<LifeClock> createState() => _LifeClockState();
}

class _LifeClockState extends State<LifeClock> {
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  DateTime get _birthMoment => DateTime(
        widget.birthDateTime.year,
        widget.birthDateTime.month,
        widget.birthDateTime.day,
        widget.birthTime.hour,
        widget.birthTime.minute,
      );

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return StreamBuilder<DateTime>(
      stream: _timeStream,
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final Duration lived =
            (snapshot.data ?? DateTime.now()).difference(_birthMoment);

        return GlassCard(
          eyebrow: 'E viveu, exatamente',
          accent: context.colors.secondary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ClockRow(
                label: 'horas',
                value: IntFormatter.format(lived.inHours),
                gradient: glass.coolGradient,
              ),
              const SizedBox(height: AppSpacing.small),
              _ClockRow(
                label: 'minutos',
                value: IntFormatter.format(lived.inMinutes),
                gradient: glass.coolGradient,
              ),
              const SizedBox(height: AppSpacing.small),
              _ClockRow(
                label: 'segundos',
                value: IntFormatter.format(lived.inSeconds),
                gradient: glass.brandGradient,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClockRow extends StatelessWidget {
  const _ClockRow({
    required this.label,
    required this.value,
    required this.gradient,
  });

  final String label;
  final String value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AppText.numeric(value, gradient: gradient, maxLines: 1),
          ),
        ),
        const SizedBox(width: AppSpacing.sMedium),
        AppText.overline(label),
      ],
    );
  }
}
