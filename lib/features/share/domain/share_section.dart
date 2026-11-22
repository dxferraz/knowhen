/// Seções do resumo que podem virar card de compartilhamento, mais o card-resumo "Meu Knowhen".
enum ShareSection {
  yearsOfLife('years_of_life'),
  conception('conception'),
  moonPhase('moon_phase'),
  brazilCuriosity('brazil_curiosity'),
  summary('summary');

  /// Nome enviado nos eventos de Analytics (mesmos nomes de `summary_section_viewed`).
  final String analyticsName;

  const ShareSection(this.analyticsName);
}
