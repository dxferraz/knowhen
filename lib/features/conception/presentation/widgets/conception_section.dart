import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/conception_window.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/components/kn_story_page.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Cartão "Concepção" (DXF-9, 4.6): a janela estimada de duas semanas, 38 semanas antes do nascimento.
class ConceptionSection extends StatelessWidget {
  const ConceptionSection({super.key, required this.birthDate});

  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = context.knText;
    final c = context.kn;
    final window = conceptionWindow(birthDate);

    return KnStoryPage(
      eyebrow: l10n.conceptionEyebrow,
      title: l10n.conceptionLead,
      children: [
        KnCard(
          child: Row(
            children: [
              Expanded(child: _ConceptionDate(label: l10n.conceptionFrom, date: window.start)),
              ExcludeSemantics(child: Icon(Icons.arrow_forward_rounded, color: c.inkMuted)),
              const SizedBox(width: KnSpace.lg),
              Expanded(child: _ConceptionDate(label: l10n.conceptionTo, date: window.end)),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(Icons.info_outline_rounded, size: 18, color: c.inkMuted)),
            const SizedBox(width: KnSpace.sm),
            Expanded(child: Text(l10n.conceptionNote, style: text.caption)),
          ],
        ),
      ],
    );
  }
}

class _ConceptionDate extends StatelessWidget {
  const _ConceptionDate({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final text = context.knText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.caption),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(DateText.dayMonthShort(date), style: text.stat)),
        Text('${date.year}', style: text.bodyMuted),
      ],
    );
  }
}
