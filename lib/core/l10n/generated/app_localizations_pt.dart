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
}
