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
  String get milestoneWeeks1000 => '1.000 semanas de vida';

  @override
  String get milestoneDays10000 => '10.000 dias de vida';

  @override
  String get milestoneSeconds1Billion => '1 bilhão de segundos de vida';

  @override
  String get milestoneMonths500 => '500 meses de vida';

  @override
  String get milestoneDays15000 => '15.000 dias de vida';

  @override
  String get milestoneDays20000 => '20.000 dias de vida';

  @override
  String milestoneBirthday(int age) {
    return '$age anos de vida';
  }

  @override
  String get milestoneNotificationTitle => 'Hoje é um dia de marco!';

  @override
  String milestoneNotificationBody(String milestone) {
    return 'Hoje você completa $milestone. Toque para ver.';
  }

  @override
  String get nextMilestoneTitle => 'Próximo marco';

  @override
  String milestoneCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias',
      one: 'Falta 1 dia',
      zero: 'É hoje!',
    );
    return '$_temp0';
  }

  @override
  String milestoneOnDate(String date) {
    return 'Em $date';
  }

  @override
  String get remindMeButton => 'Me avise';

  @override
  String get remindersEnabledInfo =>
      'Lembrete ativado: avisamos às 9h no dia de cada marco.';

  @override
  String get disableReminders => 'Desativar lembrete';

  @override
  String get remindersSaveDateInfo =>
      'Ao ativar, sua data fica salva só neste aparelho.';

  @override
  String get notificationPermissionDenied =>
      'Sem a permissão de notificações não dá para avisar. Você pode ativá-la nas configurações do aparelho.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get reminderFailed =>
      'Não foi possível agendar o lembrete. Tente novamente.';

  @override
  String get saveBirthdateOffer =>
      'Quer abrir direto no seu resumo da próxima vez?';

  @override
  String get saveBirthdateShort => 'Salvar';

  @override
  String get saveBirthdateAction => 'Salvar minha data neste aparelho';

  @override
  String get birthdateSaved => 'Data salva neste aparelho.';

  @override
  String get deleteSavedBirthdate => 'Apagar data salva';

  @override
  String get birthdateDeleted => 'Data apagada deste aparelho.';

  @override
  String get chooseAnotherDate => 'Escolher outra data';

  @override
  String get milestoneChannelName => 'Marcos de vida';

  @override
  String get milestoneChannelDescription =>
      'Avisos no dia dos marcos da sua vida';
}
