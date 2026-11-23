import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/life_clock.dart';

/// Cartão "Tempo de vida" (DXF-9, 4.5): a idade exata por calendário como herói, o que já foi vivido e quanto falta
/// para o próximo aniversário.
class YearsOfLifeSection extends StatelessWidget {
  const YearsOfLifeSection({super.key, required this.birthDate, required this.birthTime, this.now});

  final DateTime birthDate;
  final TimeOfDay? birthTime;

  /// Só para testes: um instante fixo no lugar do relógio, que então não corre.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = context.knText;
    final c = context.kn;

    final today = now ?? DateTime.now();
    final age = calculateAgeParts(birthDate, today);

    // Quem nasceu há menos de um ano não tem "0 anos": o herói passa a ser os meses e, antes disso, os dias.
    final (int heroValue, String Function(int) heroText, String? detail) = switch (age) {
      (:final years, :final months, :final days) when years > 0 => (years, l10n.lifeYears, l10n.lifeMonthsAndDays(months, days)),
      (years: _, :final months, :final days) when months > 0 => (months, l10n.lifeMonths, l10n.lifeAndDays(days)),
      (years: _, months: _, :final days) => (days, l10n.lifeDays, null),
    };
    final heroLabel = detail == null ? heroText(heroValue) : '${heroText(heroValue)} $detail';

    return KnStoryPage(
      eyebrow: l10n.lifeEyebrow,
      children: [
        Semantics(
          header: true,
          label: heroLabel,
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A contagem de 0 até o valor (800 ms) é só visual; o leitor de tela lê o valor final.
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: heroValue),
                duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(heroText(value), style: text.display),
                ),
              ),
              if (detail != null) Text(detail, style: text.title.copyWith(color: c.inkMuted)),
            ],
          ),
        ),
        LifeClock(birthDate: birthDate, birthTime: birthTime, clock: () => now ?? DateTime.now(), ticks: now == null),
        KnCard(
          padding: const EdgeInsets.symmetric(horizontal: KnSpace.lg, vertical: KnSpace.md),
          child: Row(
            children: [
              ExcludeSemantics(child: Icon(Icons.cake_outlined, color: c.accentText)),
              const SizedBox(width: KnSpace.md),
              Expanded(child: Text(l10n.lifeNextBirthday(daysUntilNextBirthday(birthDate, today)), style: text.label)),
            ],
          ),
        ),
      ],
    );
  }
}
