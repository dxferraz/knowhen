// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Knowhen';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get start => 'Começar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get onboarding1Title => 'Bem-vindo ao Knowhen!';

  @override
  String get onboarding1Description =>
      'Descubra informações únicas, surpreendentes e personalizadas com base na sua data de nascimento';

  @override
  String get onboarding2Title =>
      'Desvendando o que sua data de nascimento revela!';

  @override
  String get onboarding2Description =>
      'Explore dados personalizados sobre sua personalidade, curiosidades históricas e insights únicos baseados na sua data de nascimento.';

  @override
  String get onboarding3Title => 'Vamos descobrir?';

  @override
  String get onboarding3Description =>
      'Insira sua data de nascimento e veja o que o universo tem reservado para você!';

  @override
  String get selectBirthdateTitle =>
      'Para começar selecione a sua data de nascimento:';

  @override
  String get selectADate => 'Selecione uma data';

  @override
  String get selectABirthdate => 'Selecione uma data de nascimento';

  @override
  String summaryPageTitle(String date) {
    return 'Resumo de $date';
  }

  @override
  String yearsOld(String age) {
    return 'Caso você não saiba, você tem $age anos de vida!';
  }

  @override
  String monthsOld(String months) {
    return 'Você passou por $months meses em toda a sua vida até agora.';
  }

  @override
  String daysOld(String days) {
    return 'E $days dias em toda a sua vida.';
  }

  @override
  String conceptionRange(String startRange, String endRange) {
    return '$startRange a $endRange';
  }

  @override
  String get historicalFact => 'Fato histórico';

  @override
  String firstFactParagraph(String paragraph1) {
    return '$paragraph1.';
  }

  @override
  String get noImageForFact => 'Sem imagem para o fato';

  @override
  String get noHistoricalFact =>
      'Ainda não temos um fato histórico para o mês do seu nascimento. Volte em breve!';

  @override
  String get historicalFactLoadError =>
      'Não foi possível carregar o fato histórico agora. Verifique sua conexão e tente novamente mais tarde.';

  @override
  String get aiGeneratedImage => 'Imagem gerada por I.A.';

  @override
  String lastFactParagraph(String paragraph2) {
    return '$paragraph2';
  }

  @override
  String get yearsOfLifeTitle => 'Caso você não saiba, você tem:';

  @override
  String yearsOfLife(int years) {
    return '$years anos,';
  }

  @override
  String monthsOfLife(int months) {
    return '$months meses';
  }

  @override
  String daysOfLife(int days) {
    return 'e $days dias.';
  }

  @override
  String hoursOfLife(Object hours) {
    return '$hours horas';
  }

  @override
  String minutesOfLife(Object minutes) {
    return '$minutes minutos';
  }

  @override
  String secondsOfLife(Object seconds) {
    return '$seconds segundos';
  }

  @override
  String get shareButtonLabel => 'Compartilhar';

  @override
  String get shareSheetTitle => 'Prévia do card';

  @override
  String get shareHideFullDate => 'Esconder data completa';

  @override
  String get shareHideFullDateHint =>
      'Mostra só o mês e o ano do nascimento no card.';

  @override
  String get shareAction => 'Compartilhar card';

  @override
  String get shareGenerating => 'Gerando card…';

  @override
  String get shareError =>
      'Não foi possível gerar o card agora. Tente novamente.';

  @override
  String shareMessage(String url) {
    return 'Descubra o seu no Knowhen: $url';
  }

  @override
  String get shareWatermark => 'Descubra o seu no Knowhen';

  @override
  String get shareSummaryTitle => 'Meu Knowhen';

  @override
  String get shareYearsTitle => 'Eu já vivi';

  @override
  String shareYearsHighlight(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String shareYearsDetail(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0 e $_temp1 de vida';
  }

  @override
  String shareYearsDetailHidden(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    return '$_temp0 de vida';
  }

  @override
  String get shareConceptionTitle => 'Fui concebido por volta de';

  @override
  String get shareMoonTitle => 'Eu nasci na';

  @override
  String shareMoonLine(String phase) {
    return 'Nasci na $phase';
  }

  @override
  String shareConceptionLine(String when) {
    return 'Concebido(a) por volta de $when';
  }

  @override
  String shareBirthFull(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Nascimento: $dateString';
  }

  @override
  String shareBirthMonthYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMM(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Nascimento: $dateString';
  }

  @override
  String shareMonthYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMM(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String shareConceptionRange(DateTime startRange, DateTime endRange) {
    final intl.DateFormat startRangeDateFormat = intl.DateFormat.yMd(
      localeName,
    );
    final String startRangeString = startRangeDateFormat.format(startRange);
    final intl.DateFormat endRangeDateFormat = intl.DateFormat.yMd(localeName);
    final String endRangeString = endRangeDateFormat.format(endRange);

    return '$startRangeString a $endRangeString';
  }
}
