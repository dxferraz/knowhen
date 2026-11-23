import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/functions/int_formatter.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/components/kn_stat.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// "Até agora você viveu": dias, horas, minutos e segundos de vida, com os segundos ao vivo (DXF-9, 4.5).
///
/// Sem [birthTime] a conta parte da meia-noite do dia do nascimento: os dias seguem exatos, e horas, minutos e
/// segundos ficam aproximados (a hora é opcional justamente para deixar o relógio mais preciso).
class LifeClock extends StatefulWidget {
  const LifeClock({super.key, required this.birthDate, this.birthTime, this.clock = DateTime.now, this.ticks = true});

  final DateTime birthDate;
  final TimeOfDay? birthTime;

  /// De onde vem o "agora". Os testes passam um relógio próprio.
  final DateTime Function() clock;

  /// Atualiza uma vez por segundo. Desligado, mostra o instante lido na montagem (testes e goldens, que esperam a
  /// tela assentar).
  final bool ticks;

  @override
  State<LifeClock> createState() => _LifeClockState();
}

class _LifeClockState extends State<LifeClock> {
  Timer? _ticker;
  late DateTime _now = widget.clock();

  @override
  void initState() {
    super.initState();
    if (widget.ticks) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = widget.clock()));
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = _now;
    final birth = widget.birthDate;
    final birthInstant = DateTime(birth.year, birth.month, birth.day, widget.birthTime?.hour ?? 0, widget.birthTime?.minute ?? 0);
    final lived = now.isBefore(birthInstant) ? Duration.zero : now.difference(birthInstant);

    Widget stat(int value, String label) => Expanded(child: KnStat(value: IntFormatter.format(value), label: label));

    return KnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.lifeSoFar, style: context.knText.caption),
          const SizedBox(height: KnSpace.lg),
          Row(children: [stat(calculateDaysOfLife(birth, now), l10n.lifeUnitDays), stat(lived.inHours, l10n.lifeUnitHours)]),
          const SizedBox(height: KnSpace.lg),
          Row(children: [stat(lived.inMinutes, l10n.lifeUnitMinutes), stat(lived.inSeconds, l10n.lifeUnitSeconds)]),
        ],
      ),
    );
  }
}
