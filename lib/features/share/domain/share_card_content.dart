import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/calculate_age.dart';
import 'package:knowhen/core/functions/conception_window.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/features/brazil_curiosity/domain/fact_text.dart';
import 'package:knowhen/features/moon_phase/presentation/moon_phase_l10n.dart';
import 'package:knowhen/features/share/domain/share_section.dart';

/// Dados do resumo necessários para montar os cards.
class ShareCardData {
  final DateTime birthDate;
  final DateTime now;
  final MoonPhase moonPhase;

  /// `null` quando não há curiosidade do mês/ano (o card da curiosidade não é oferecido).
  final String? curiosity;
  final String curiosityImageUrl;

  const ShareCardData({required this.birthDate, required this.now, required this.moonPhase, this.curiosity, this.curiosityImageUrl = ''});

  /// Fração do ciclo lunar no dia do nascimento, para desenhar a lua na fase exata.
  double get moonFraction => getMoonPhaseFraction(birthDate);

  /// Título curto do fato do mês, o gancho do card-resumo; `null` sem fato ou quando a primeira frase é longa demais.
  String? get factTitle {
    final fact = curiosity;
    return fact == null ? null : splitFact(fact).title;
  }

  /// Data central da concepção (a mesma janela do resumo, em dias de calendário).
  DateTime get conceptionDate => DateTime(birthDate.year, birthDate.month, birthDate.day - conceptionDaysBeforeBirth);
}

/// Texto e ilustração de um card, já localizados e com a privacidade aplicada.
class ShareCardContent {
  final ShareSection section;
  final String title;
  final String highlight;
  final List<String> details;
  final String birthLabel;
  final IconData icon;

  /// Fase da lua (fração do ciclo) a desenhar no lugar de [icon]; `null` quando o card não tem lua.
  final double? moonFraction;

  /// Imagem remota opcional; [icon] é o fallback quando ela falta ou falha.
  final String? imageUrl;

  const ShareCardContent({
    required this.section,
    required this.title,
    required this.highlight,
    required this.details,
    required this.birthLabel,
    required this.icon,
    this.moonFraction,
    this.imageUrl,
  });

  /// Monta o conteúdo do card de [section].
  ///
  /// Com [hideFullDate], nenhum texto do card revela o dia do nascimento: aparecem só mês e ano
  /// (inclusive na concepção) e os dias de vida são omitidos, já que com a data de hoje os
  /// denunciariam.
  factory ShareCardContent.build(AppLocalizations l10n, ShareSection section, ShareCardData data, {required bool hideFullDate}) {
    final birthLabel = hideFullDate ? l10n.shareBirthMonthYear(data.birthDate) : l10n.shareBirthFull(data.birthDate);
    final age = _ageHighlight(l10n, data);
    final totalMonths = calculateMonthsOfLife(data.birthDate, data.now);
    final days = calculateDaysOfLife(data.birthDate, data.now);
    final yearsDetail = hideFullDate ? l10n.shareYearsDetailHidden(totalMonths) : l10n.shareYearsDetail(totalMonths, days);
    final conception = _conceptionLabel(l10n, data, hideFullDate);

    switch (section) {
      case ShareSection.yearsOfLife:
        return ShareCardContent(
          section: section,
          title: l10n.shareYearsTitle,
          highlight: age,
          details: [yearsDetail],
          birthLabel: birthLabel,
          icon: Icons.cake_rounded,
        );
      case ShareSection.conception:
        return ShareCardContent(
          section: section,
          title: l10n.shareConceptionTitle,
          highlight: conception,
          details: const [],
          birthLabel: birthLabel,
          icon: Icons.child_friendly_rounded,
        );
      case ShareSection.moonPhase:
        return ShareCardContent(
          section: section,
          title: l10n.shareMoonTitle,
          highlight: l10n.moonPhaseName(data.moonPhase.type),
          details: [l10n.moonPhaseDescription(data.moonPhase.type)],
          birthLabel: birthLabel,
          icon: Icons.nightlight_round,
          moonFraction: data.moonFraction,
        );
      case ShareSection.brazilCuriosity:
        final paragraphs = (data.curiosity ?? '').split('. ');
        return ShareCardContent(
          section: section,
          title: l10n.historicalFact,
          highlight: l10n.firstFactParagraph(paragraphs.first),
          details: paragraphs.length > 1 ? [l10n.lastFactParagraph(paragraphs.last)] : const [],
          birthLabel: birthLabel,
          icon: Icons.public_rounded,
          imageUrl: data.curiosityImageUrl.isEmpty ? null : data.curiosityImageUrl,
        );
      case ShareSection.summary:
        return ShareCardContent(
          section: section,
          title: l10n.shareSummaryTitle,
          highlight: age,
          details: [
            yearsDetail,
            l10n.shareMoonLine(l10n.moonPhaseName(data.moonPhase.type)),
            if (data.factTitle != null) l10n.shareFactLine(data.factTitle!),
          ],
          birthLabel: birthLabel,
          icon: Icons.auto_awesome_rounded,
          moonFraction: data.moonFraction,
        );
    }
  }

  /// A idade como no cartão "Tempo de vida": anos e, antes do primeiro aniversário, meses ou dias (sem "0 anos").
  static String _ageHighlight(AppLocalizations l10n, ShareCardData data) {
    final (:years, :months, :days) = calculateAgeParts(data.birthDate, data.now);
    if (years > 0) return l10n.lifeYears(years);
    if (months > 0) return l10n.lifeMonths(months);
    return l10n.lifeDays(days);
  }

  static String _conceptionLabel(AppLocalizations l10n, ShareCardData data, bool hideFullDate) {
    if (hideFullDate) return l10n.shareMonthYear(data.conceptionDate);
    final window = conceptionWindow(data.birthDate);
    return l10n.shareConceptionRange(window.start, window.end);
  }
}
