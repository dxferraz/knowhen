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
  String get next => 'Próximo';

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
  String get birthTimeQuestion => 'Você sabe a hora exata do seu nascimento?';

  @override
  String get unknownBirthTime => 'Não sei';

  @override
  String get conceptionTitle => 'Muito provavelmente, no período de:';

  @override
  String get conceptionNote =>
      'Estimativa baseada na duração média de uma gestação, com margem de uma semana.';

  @override
  String get moonPhaseTitle => 'Você nasceu na:';

  @override
  String get livedTitle => 'E viveu:';

  @override
  String get moonPhaseNewMoonName => 'Lua nova';

  @override
  String get moonPhaseNewMoonDescription =>
      'A Lua está invisível no céu, marcando o início de um novo ciclo.';

  @override
  String get moonPhaseNewMoonInfluence =>
      'Pessoas nascidas sob a Lua Nova costumam ser visionárias, cheias de ideias e energia para começar do zero. Tendem a buscar novos caminhos e gostam de recomeços, mesmo em situações difíceis.';

  @override
  String get moonPhaseWaxingCrescentName => 'Lua crescente';

  @override
  String get moonPhaseWaxingCrescentDescription =>
      'A Lua começa a ganhar luz, simbolizando crescimento e construção.';

  @override
  String get moonPhaseWaxingCrescentInfluence =>
      'Nascidos nessa fase têm perfil determinado e progressivo. São pessoas que aprendem com o tempo, gostam de desafios e têm sede de evolução. Costumam ser persistentes e confiantes no que querem conquistar.';

  @override
  String get moonPhaseFirstQuarterName => 'Lua quarto crescente';

  @override
  String get moonPhaseFirstQuarterDescription =>
      'Metade da Lua está iluminada e visível. O ciclo está ganhando força.';

  @override
  String get moonPhaseFirstQuarterInfluence =>
      'Pessoas do Quarto Crescente têm espírito de ação. São decididas, práticas e focadas em realizar. Lidam bem com pressões e sabem transformar ideias em realidade.';

  @override
  String get moonPhaseWaxingGibbousName => 'Lua gibosa crescente';

  @override
  String get moonPhaseWaxingGibbousDescription =>
      'Mais de metade da Lua está iluminada, aproximando-se da Lua Cheia.';

  @override
  String get moonPhaseWaxingGibbousInfluence =>
      'Nascidos sob essa fase são visionários e idealistas. Buscam aprimoramento constante e querem deixar sua marca no mundo. São guiados por propósito e aperfeiçoamento.';

  @override
  String get moonPhaseFullMoonName => 'Lua cheia';

  @override
  String get moonPhaseFullMoonDescription =>
      'A Lua está totalmente visível e oposta ao Sol. É o auge do ciclo lunar.';

  @override
  String get moonPhaseFullMoonInfluence =>
      'Intensos, carismáticos e sensíveis — pessoas de Lua Cheia sentem tudo profundamente. São expressivas, envolventes e têm grande energia emocional e magnética.';

  @override
  String get moonPhaseWaningGibbousName => 'Lua gibosa minguante';

  @override
  String get moonPhaseWaningGibbousDescription =>
      'A Lua começa a perder luz, logo após a Lua Cheia.';

  @override
  String get moonPhaseWaningGibbousInfluence =>
      'Pessoas dessa fase tendem a ser analíticas e sábias. Gostam de refletir, entender o porquê das coisas e aprender com a experiência. Buscam sentido em tudo o que fazem.';

  @override
  String get moonPhaseLastQuarterName => 'Lua quarto minguante';

  @override
  String get moonPhaseLastQuarterDescription =>
      'Metade da Lua ainda está visível, mas está minguando. O ciclo se aproxima do fim.';

  @override
  String get moonPhaseLastQuarterInfluence =>
      'Nascidos nessa fase são desapegados, introspectivos e bons em encerrar ciclos. Costumam ser calmos, observadores e têm uma maturidade emocional profunda.';

  @override
  String get moonPhaseWaningCrescentName => 'Lua minguante';

  @override
  String get moonPhaseWaningCrescentDescription =>
      'Apenas uma pequena parte da Lua ainda está iluminada antes da fase nova.';

  @override
  String get moonPhaseWaningCrescentInfluence =>
      'Pessoas de Lua Minguante são intuitivas, espirituais e ligadas ao invisível. Têm sabedoria interior, são reservadas e vivem bem no silêncio e na contemplação.';

  @override
  String get authSignInError =>
      'Não foi possível entrar no app agora. Verifique sua conexão e tente novamente.';

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

  @override
  String get onboardingTitle => 'O que o dia em que você nasceu tem a contar?';

  @override
  String get onboardingRevealLife => 'Quanto tempo você já viveu';

  @override
  String get onboardingRevealConception => 'Quando a sua história começou';

  @override
  String get onboardingRevealMoon => 'Em que fase estava a Lua';

  @override
  String get onboardingRevealFact =>
      'Um fato histórico perto do seu nascimento';

  @override
  String get onboardingTakesLess => 'Leva menos de um minuto';

  @override
  String get birthdateTitle => 'Quando você nasceu?';

  @override
  String get birthdateDay => 'Dia';

  @override
  String get birthdateMonth => 'Mês';

  @override
  String get birthdateYear => 'Ano';

  @override
  String get birthdatePickFromCalendar => 'Escolher no calendário';

  @override
  String get birthdateTimeTitle => 'Hora do nascimento';

  @override
  String get birthdateTimeOptional => 'Opcional';

  @override
  String get birthdateTimeToggle => 'Sei a hora em que nasci';

  @override
  String get birthdateReveal => 'Revelar meu resumo';

  @override
  String get birthdateErrorInvalid =>
      'Essa data não existe. Confira o dia e o mês.';

  @override
  String get birthdateErrorFuture => 'A data não pode estar no futuro.';

  @override
  String get birthdateErrorTooOld => 'Digite um ano a partir de 1900.';

  @override
  String revealTitle(String date) {
    return 'Olhando o céu de $date…';
  }

  @override
  String get revealStepLife => 'Calculando o seu tempo de vida';

  @override
  String get revealStepMoon => 'Encontrando a fase da Lua';

  @override
  String get revealStepFact => 'Buscando um fato histórico';

  @override
  String get summaryClose => 'Fechar o resumo';

  @override
  String summaryProgress(int current, int total) {
    return 'Cartão $current de $total';
  }

  @override
  String get summaryShareCard => 'Compartilhar este cartão';

  @override
  String get lifeEyebrow => 'Tempo de vida';

  @override
  String lifeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String lifeMonthsAndDays(int months, int days) {
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
    return '$_temp0 e $_temp1';
  }

  @override
  String get lifeSoFar => 'Até agora você viveu';

  @override
  String get lifeUnitDays => 'dias';

  @override
  String get lifeUnitHours => 'horas';

  @override
  String get lifeUnitMinutes => 'minutos';

  @override
  String get lifeUnitSeconds => 'segundos';

  @override
  String lifeNextBirthday(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias para o seu próximo aniversário',
      one: 'Falta 1 dia para o seu próximo aniversário',
      zero: 'Hoje é o seu aniversário!',
    );
    return '$_temp0';
  }

  @override
  String get conceptionEyebrow => 'Concepção';

  @override
  String get conceptionLead => 'Sua história começou entre';

  @override
  String get moonEyebrow => 'Fase da Lua';

  @override
  String moonBornUnder(String phase) {
    return 'Você nasceu numa $phase';
  }

  @override
  String get moonCycleLabel => 'Ciclo da Lua';

  @override
  String get factEyebrow => 'Fato histórico';

  @override
  String factDaysAfterBirth(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias depois do seu nascimento',
      one: '1 dia depois do seu nascimento',
      zero: 'No dia do seu nascimento',
    );
    return '$_temp0';
  }

  @override
  String factDaysBeforeBirth(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias antes do seu nascimento',
      one: '1 dia antes do seu nascimento',
    );
    return '$_temp0';
  }

  @override
  String get factAiBadge => 'Ilustração gerada por IA';

  @override
  String get factErrorTitle => 'Não conseguimos buscar o fato histórico';

  @override
  String get factRetry => 'Tentar de novo';

  @override
  String get factSeeWhatIsReady => 'Ver o que já está pronto';

  @override
  String get endShare => 'Compartilhar meu resumo';

  @override
  String get adLabel => 'Anúncio';

  @override
  String get birthSongTitle => 'A trilha do seu nascimento';

  @override
  String birthSongIntro(String period) {
    return 'Em $period, uma das músicas em destaque no Brasil foi:';
  }

  @override
  String get birthSongDisclaimer =>
      'Informação gerada por I.A.; pode conter imprecisões.';

  @override
  String get listenOnSpotify => 'Ouvir no Spotify';

  @override
  String get listenOnYoutube => 'Ouvir no YouTube';

  @override
  String get birthSongOpenError => 'Não foi possível abrir o link.';
}
