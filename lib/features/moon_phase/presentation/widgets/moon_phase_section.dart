import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/moon_phase/presentation/moon_phase_l10n.dart';

/// Cartão "Fase da Lua" (DXF-9, 4.7): a lua desenhada na fase exata do dia, sem rede, e o ciclo de 8 fases com a
/// do nascimento em destaque (assim a lua nova, que é invisível, também fica compreensível).
class MoonPhaseSection extends StatelessWidget {
  const MoonPhaseSection({super.key, required this.moonPhase, required this.birthDate});

  final MoonPhase moonPhase;
  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = context.knText;
    final name = l10n.moonPhaseName(moonPhase.type);

    return KnStoryPage(
      eyebrow: l10n.moonEyebrow,
      title: l10n.moonBornUnder(name),
      children: [
        // O Brasil fica no hemisfério sul: a Lua se vê espelhada em relação aos desenhos do hemisfério norte.
        Center(child: KnMoon(phase: getMoonPhaseFraction(birthDate), size: 150, southernHemisphere: true)),
        _MoonCycle(highlighted: moonPhase.type, label: l10n.moonCycleLabel(name)),
        Text(l10n.moonPhaseDescription(moonPhase.type), style: text.body),
        Text(l10n.moonPhaseInfluence(moonPhase.type), style: text.bodyMuted),
      ],
    );
  }
}

/// As 8 fases em fila, com um anel na do nascimento.
class _MoonCycle extends StatelessWidget {
  const _MoonCycle({required this.highlighted, required this.label});

  final MoonPhaseType highlighted;
  final String label;

  static const double _ring = 2;
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    const phases = MoonPhaseType.values;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Em telas estreitas as 8 luas encolhem em vez de estourar a linha.
          final moon = math.min(28.0, constraints.maxWidth / phases.length - 2 * (_ring + _gap));
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final type in phases)
                Container(
                  padding: const EdgeInsets.all(_gap),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: type == highlighted ? c.primary : Colors.transparent, width: _ring),
                  ),
                  child: KnMoon(phase: type.index / phases.length, size: moon, glow: false, southernHemisphere: true),
                ),
            ],
          );
        },
      ),
    );
  }
}
