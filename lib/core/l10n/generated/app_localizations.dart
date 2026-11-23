import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Knowhen'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get next;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @continueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @selectBirthdateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Para começar selecione a sua data de nascimento:'**
  String get selectBirthdateTitle;

  /// No description provided for @selectADate.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma data'**
  String get selectADate;

  /// No description provided for @selectABirthdate.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma data de nascimento'**
  String get selectABirthdate;

  /// Resumo da data selecionada
  ///
  /// In pt, this message translates to:
  /// **'Resumo de {date}'**
  String summaryPageTitle(String date);

  /// No description provided for @yearsOld.
  ///
  /// In pt, this message translates to:
  /// **'Caso você não saiba, você tem {age} anos de vida!'**
  String yearsOld(String age);

  /// No description provided for @monthsOld.
  ///
  /// In pt, this message translates to:
  /// **'Você passou por {months} meses em toda a sua vida até agora.'**
  String monthsOld(String months);

  /// No description provided for @daysOld.
  ///
  /// In pt, this message translates to:
  /// **'E {days} dias em toda a sua vida.'**
  String daysOld(String days);

  /// No description provided for @conceptionRange.
  ///
  /// In pt, this message translates to:
  /// **'{startRange} a {endRange}'**
  String conceptionRange(String startRange, String endRange);

  /// No description provided for @historicalFact.
  ///
  /// In pt, this message translates to:
  /// **'Fato histórico'**
  String get historicalFact;

  /// No description provided for @firstFactParagraph.
  ///
  /// In pt, this message translates to:
  /// **'{paragraph1}.'**
  String firstFactParagraph(String paragraph1);

  /// No description provided for @noImageForFact.
  ///
  /// In pt, this message translates to:
  /// **'Sem imagem para o fato'**
  String get noImageForFact;

  /// No description provided for @noHistoricalFact.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não temos um fato histórico para o mês do seu nascimento. Volte em breve!'**
  String get noHistoricalFact;

  /// No description provided for @historicalFactLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o fato histórico agora. Verifique sua conexão e tente novamente mais tarde.'**
  String get historicalFactLoadError;

  /// No description provided for @aiGeneratedImage.
  ///
  /// In pt, this message translates to:
  /// **'Imagem gerada por I.A.'**
  String get aiGeneratedImage;

  /// No description provided for @lastFactParagraph.
  ///
  /// In pt, this message translates to:
  /// **'{paragraph2}'**
  String lastFactParagraph(String paragraph2);

  /// No description provided for @yearsOfLifeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Caso você não saiba, você tem:'**
  String get yearsOfLifeTitle;

  /// No description provided for @yearsOfLife.
  ///
  /// In pt, this message translates to:
  /// **'{years} anos,'**
  String yearsOfLife(int years);

  /// No description provided for @monthsOfLife.
  ///
  /// In pt, this message translates to:
  /// **'{months} meses'**
  String monthsOfLife(int months);

  /// No description provided for @daysOfLife.
  ///
  /// In pt, this message translates to:
  /// **'e {days} dias.'**
  String daysOfLife(int days);

  /// No description provided for @hoursOfLife.
  ///
  /// In pt, this message translates to:
  /// **'{hours} horas'**
  String hoursOfLife(Object hours);

  /// No description provided for @minutesOfLife.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} minutos'**
  String minutesOfLife(Object minutes);

  /// No description provided for @secondsOfLife.
  ///
  /// In pt, this message translates to:
  /// **'{seconds} segundos'**
  String secondsOfLife(Object seconds);

  /// No description provided for @birthTimeQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Você sabe a hora exata do seu nascimento?'**
  String get birthTimeQuestion;

  /// No description provided for @unknownBirthTime.
  ///
  /// In pt, this message translates to:
  /// **'Não sei'**
  String get unknownBirthTime;

  /// No description provided for @conceptionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Muito provavelmente, no período de:'**
  String get conceptionTitle;

  /// No description provided for @conceptionNote.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa baseada na duração média de uma gestação, com margem de uma semana.'**
  String get conceptionNote;

  /// No description provided for @moonPhaseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você nasceu na:'**
  String get moonPhaseTitle;

  /// No description provided for @livedTitle.
  ///
  /// In pt, this message translates to:
  /// **'E viveu:'**
  String get livedTitle;

  /// No description provided for @moonPhaseNewMoonName.
  ///
  /// In pt, this message translates to:
  /// **'Lua nova'**
  String get moonPhaseNewMoonName;

  /// No description provided for @moonPhaseNewMoonDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Lua está invisível no céu, marcando o início de um novo ciclo.'**
  String get moonPhaseNewMoonDescription;

  /// No description provided for @moonPhaseNewMoonInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas nascidas sob a Lua Nova costumam ser visionárias, cheias de ideias e energia para começar do zero. Tendem a buscar novos caminhos e gostam de recomeços, mesmo em situações difíceis.'**
  String get moonPhaseNewMoonInfluence;

  /// No description provided for @moonPhaseWaxingCrescentName.
  ///
  /// In pt, this message translates to:
  /// **'Lua crescente'**
  String get moonPhaseWaxingCrescentName;

  /// No description provided for @moonPhaseWaxingCrescentDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Lua começa a ganhar luz, simbolizando crescimento e construção.'**
  String get moonPhaseWaxingCrescentDescription;

  /// No description provided for @moonPhaseWaxingCrescentInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Nascidos nessa fase têm perfil determinado e progressivo. São pessoas que aprendem com o tempo, gostam de desafios e têm sede de evolução. Costumam ser persistentes e confiantes no que querem conquistar.'**
  String get moonPhaseWaxingCrescentInfluence;

  /// No description provided for @moonPhaseFirstQuarterName.
  ///
  /// In pt, this message translates to:
  /// **'Lua quarto crescente'**
  String get moonPhaseFirstQuarterName;

  /// No description provided for @moonPhaseFirstQuarterDescription.
  ///
  /// In pt, this message translates to:
  /// **'Metade da Lua está iluminada e visível. O ciclo está ganhando força.'**
  String get moonPhaseFirstQuarterDescription;

  /// No description provided for @moonPhaseFirstQuarterInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas do Quarto Crescente têm espírito de ação. São decididas, práticas e focadas em realizar. Lidam bem com pressões e sabem transformar ideias em realidade.'**
  String get moonPhaseFirstQuarterInfluence;

  /// No description provided for @moonPhaseWaxingGibbousName.
  ///
  /// In pt, this message translates to:
  /// **'Lua gibosa crescente'**
  String get moonPhaseWaxingGibbousName;

  /// No description provided for @moonPhaseWaxingGibbousDescription.
  ///
  /// In pt, this message translates to:
  /// **'Mais de metade da Lua está iluminada, aproximando-se da Lua Cheia.'**
  String get moonPhaseWaxingGibbousDescription;

  /// No description provided for @moonPhaseWaxingGibbousInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Nascidos sob essa fase são visionários e idealistas. Buscam aprimoramento constante e querem deixar sua marca no mundo. São guiados por propósito e aperfeiçoamento.'**
  String get moonPhaseWaxingGibbousInfluence;

  /// No description provided for @moonPhaseFullMoonName.
  ///
  /// In pt, this message translates to:
  /// **'Lua cheia'**
  String get moonPhaseFullMoonName;

  /// No description provided for @moonPhaseFullMoonDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Lua está totalmente visível e oposta ao Sol. É o auge do ciclo lunar.'**
  String get moonPhaseFullMoonDescription;

  /// No description provided for @moonPhaseFullMoonInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Intensos, carismáticos e sensíveis — pessoas de Lua Cheia sentem tudo profundamente. São expressivas, envolventes e têm grande energia emocional e magnética.'**
  String get moonPhaseFullMoonInfluence;

  /// No description provided for @moonPhaseWaningGibbousName.
  ///
  /// In pt, this message translates to:
  /// **'Lua gibosa minguante'**
  String get moonPhaseWaningGibbousName;

  /// No description provided for @moonPhaseWaningGibbousDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Lua começa a perder luz, logo após a Lua Cheia.'**
  String get moonPhaseWaningGibbousDescription;

  /// No description provided for @moonPhaseWaningGibbousInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas dessa fase tendem a ser analíticas e sábias. Gostam de refletir, entender o porquê das coisas e aprender com a experiência. Buscam sentido em tudo o que fazem.'**
  String get moonPhaseWaningGibbousInfluence;

  /// No description provided for @moonPhaseLastQuarterName.
  ///
  /// In pt, this message translates to:
  /// **'Lua quarto minguante'**
  String get moonPhaseLastQuarterName;

  /// No description provided for @moonPhaseLastQuarterDescription.
  ///
  /// In pt, this message translates to:
  /// **'Metade da Lua ainda está visível, mas está minguando. O ciclo se aproxima do fim.'**
  String get moonPhaseLastQuarterDescription;

  /// No description provided for @moonPhaseLastQuarterInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Nascidos nessa fase são desapegados, introspectivos e bons em encerrar ciclos. Costumam ser calmos, observadores e têm uma maturidade emocional profunda.'**
  String get moonPhaseLastQuarterInfluence;

  /// No description provided for @moonPhaseWaningCrescentName.
  ///
  /// In pt, this message translates to:
  /// **'Lua minguante'**
  String get moonPhaseWaningCrescentName;

  /// No description provided for @moonPhaseWaningCrescentDescription.
  ///
  /// In pt, this message translates to:
  /// **'Apenas uma pequena parte da Lua ainda está iluminada antes da fase nova.'**
  String get moonPhaseWaningCrescentDescription;

  /// No description provided for @moonPhaseWaningCrescentInfluence.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas de Lua Minguante são intuitivas, espirituais e ligadas ao invisível. Têm sabedoria interior, são reservadas e vivem bem no silêncio e na contemplação.'**
  String get moonPhaseWaningCrescentInfluence;

  /// No description provided for @authSignInError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar no app agora. Verifique sua conexão e tente novamente.'**
  String get authSignInError;

  /// No description provided for @shareButtonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get shareButtonLabel;

  /// No description provided for @shareSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Prévia do card'**
  String get shareSheetTitle;

  /// No description provided for @shareHideFullDate.
  ///
  /// In pt, this message translates to:
  /// **'Esconder data completa'**
  String get shareHideFullDate;

  /// No description provided for @shareHideFullDateHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostra só o mês e o ano do nascimento no card.'**
  String get shareHideFullDateHint;

  /// No description provided for @shareAction.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar card'**
  String get shareAction;

  /// No description provided for @shareGenerating.
  ///
  /// In pt, this message translates to:
  /// **'Gerando card…'**
  String get shareGenerating;

  /// No description provided for @shareError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o card agora. Tente novamente.'**
  String get shareError;

  /// No description provided for @shareMessage.
  ///
  /// In pt, this message translates to:
  /// **'Descubra o seu no Knowhen: {url}'**
  String shareMessage(String url);

  /// No description provided for @shareWatermark.
  ///
  /// In pt, this message translates to:
  /// **'Descubra o seu no Knowhen'**
  String get shareWatermark;

  /// No description provided for @shareSummaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Knowhen'**
  String get shareSummaryTitle;

  /// No description provided for @shareYearsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Eu já vivi'**
  String get shareYearsTitle;

  /// No description provided for @shareYearsHighlight.
  ///
  /// In pt, this message translates to:
  /// **'{years, plural, =1{1 ano} other{{years} anos}}'**
  String shareYearsHighlight(int years);

  /// No description provided for @shareYearsDetail.
  ///
  /// In pt, this message translates to:
  /// **'{months, plural, =1{1 mês} other{{months} meses}} e {days, plural, =1{1 dia} other{{days} dias}} de vida'**
  String shareYearsDetail(int months, int days);

  /// No description provided for @shareYearsDetailHidden.
  ///
  /// In pt, this message translates to:
  /// **'{months, plural, =1{1 mês} other{{months} meses}} de vida'**
  String shareYearsDetailHidden(int months);

  /// No description provided for @shareConceptionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fui concebido por volta de'**
  String get shareConceptionTitle;

  /// No description provided for @shareMoonTitle.
  ///
  /// In pt, this message translates to:
  /// **'Eu nasci na'**
  String get shareMoonTitle;

  /// No description provided for @shareMoonLine.
  ///
  /// In pt, this message translates to:
  /// **'Nasci na {phase}'**
  String shareMoonLine(String phase);

  /// No description provided for @shareConceptionLine.
  ///
  /// In pt, this message translates to:
  /// **'Concebido(a) por volta de {when}'**
  String shareConceptionLine(String when);

  /// No description provided for @shareBirthFull.
  ///
  /// In pt, this message translates to:
  /// **'Nascimento: {date}'**
  String shareBirthFull(DateTime date);

  /// No description provided for @shareBirthMonthYear.
  ///
  /// In pt, this message translates to:
  /// **'Nascimento: {date}'**
  String shareBirthMonthYear(DateTime date);

  /// No description provided for @shareMonthYear.
  ///
  /// In pt, this message translates to:
  /// **'{date}'**
  String shareMonthYear(DateTime date);

  /// No description provided for @shareConceptionRange.
  ///
  /// In pt, this message translates to:
  /// **'{startRange} a {endRange}'**
  String shareConceptionRange(DateTime startRange, DateTime endRange);

  /// No description provided for @milestoneWeeks1000.
  ///
  /// In pt, this message translates to:
  /// **'1.000 semanas de vida'**
  String get milestoneWeeks1000;

  /// No description provided for @milestoneDays10000.
  ///
  /// In pt, this message translates to:
  /// **'10.000 dias de vida'**
  String get milestoneDays10000;

  /// No description provided for @milestoneSeconds1Billion.
  ///
  /// In pt, this message translates to:
  /// **'1 bilhão de segundos de vida'**
  String get milestoneSeconds1Billion;

  /// No description provided for @milestoneMonths500.
  ///
  /// In pt, this message translates to:
  /// **'500 meses de vida'**
  String get milestoneMonths500;

  /// No description provided for @milestoneDays15000.
  ///
  /// In pt, this message translates to:
  /// **'15.000 dias de vida'**
  String get milestoneDays15000;

  /// No description provided for @milestoneDays20000.
  ///
  /// In pt, this message translates to:
  /// **'20.000 dias de vida'**
  String get milestoneDays20000;

  /// No description provided for @milestoneBirthday.
  ///
  /// In pt, this message translates to:
  /// **'{age} anos de vida'**
  String milestoneBirthday(int age);

  /// No description provided for @milestoneNotificationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hoje é um dia de marco!'**
  String get milestoneNotificationTitle;

  /// No description provided for @milestoneNotificationBody.
  ///
  /// In pt, this message translates to:
  /// **'Hoje você completa {milestone}. Toque para ver.'**
  String milestoneNotificationBody(String milestone);

  /// No description provided for @nextMilestoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Próximo marco'**
  String get nextMilestoneTitle;

  /// No description provided for @milestoneCountdown.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =0{É hoje!} =1{Falta 1 dia} other{Faltam {days} dias}}'**
  String milestoneCountdown(int days);

  /// No description provided for @milestoneOnDate.
  ///
  /// In pt, this message translates to:
  /// **'Em {date}'**
  String milestoneOnDate(String date);

  /// No description provided for @remindMeButton.
  ///
  /// In pt, this message translates to:
  /// **'Me avise'**
  String get remindMeButton;

  /// No description provided for @remindersEnabledInfo.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete ativado: avisamos às 9h no dia de cada marco.'**
  String get remindersEnabledInfo;

  /// No description provided for @disableReminders.
  ///
  /// In pt, this message translates to:
  /// **'Desativar lembrete'**
  String get disableReminders;

  /// No description provided for @remindersSaveDateInfo.
  ///
  /// In pt, this message translates to:
  /// **'Ao ativar, sua data fica salva só neste aparelho.'**
  String get remindersSaveDateInfo;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem a permissão de notificações não dá para avisar. Você pode ativá-la nas configurações do aparelho.'**
  String get notificationPermissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get openSettings;

  /// No description provided for @reminderFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível agendar o lembrete. Tente novamente.'**
  String get reminderFailed;

  /// No description provided for @saveBirthdateOffer.
  ///
  /// In pt, this message translates to:
  /// **'Quer abrir direto no seu resumo da próxima vez?'**
  String get saveBirthdateOffer;

  /// No description provided for @saveBirthdateShort.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get saveBirthdateShort;

  /// No description provided for @saveBirthdateAction.
  ///
  /// In pt, this message translates to:
  /// **'Salvar minha data neste aparelho'**
  String get saveBirthdateAction;

  /// No description provided for @birthdateSaved.
  ///
  /// In pt, this message translates to:
  /// **'Data salva neste aparelho.'**
  String get birthdateSaved;

  /// No description provided for @deleteSavedBirthdate.
  ///
  /// In pt, this message translates to:
  /// **'Apagar data salva'**
  String get deleteSavedBirthdate;

  /// No description provided for @birthdateDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Data apagada deste aparelho.'**
  String get birthdateDeleted;

  /// No description provided for @chooseAnotherDate.
  ///
  /// In pt, this message translates to:
  /// **'Escolher outra data'**
  String get chooseAnotherDate;

  /// No description provided for @milestoneChannelName.
  ///
  /// In pt, this message translates to:
  /// **'Marcos de vida'**
  String get milestoneChannelName;

  /// No description provided for @milestoneChannelDescription.
  ///
  /// In pt, this message translates to:
  /// **'Avisos no dia dos marcos da sua vida'**
  String get milestoneChannelDescription;

  /// No description provided for @onboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que o dia em que você nasceu tem a contar?'**
  String get onboardingTitle;

  /// No description provided for @onboardingRevealLife.
  ///
  /// In pt, this message translates to:
  /// **'Quanto tempo você já viveu'**
  String get onboardingRevealLife;

  /// No description provided for @onboardingRevealConception.
  ///
  /// In pt, this message translates to:
  /// **'Quando a sua história começou'**
  String get onboardingRevealConception;

  /// No description provided for @onboardingRevealMoon.
  ///
  /// In pt, this message translates to:
  /// **'Em que fase estava a Lua'**
  String get onboardingRevealMoon;

  /// No description provided for @onboardingRevealFact.
  ///
  /// In pt, this message translates to:
  /// **'Um fato histórico perto do seu nascimento'**
  String get onboardingRevealFact;

  /// No description provided for @onboardingTakesLess.
  ///
  /// In pt, this message translates to:
  /// **'Leva menos de um minuto'**
  String get onboardingTakesLess;

  /// No description provided for @onboardingIntro.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua data de nascimento e veja quatro revelações sobre ela.'**
  String get onboardingIntro;

  /// No description provided for @themeSwitchToLight.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para o tema claro'**
  String get themeSwitchToLight;

  /// No description provided for @themeSwitchToDark.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para o tema escuro'**
  String get themeSwitchToDark;

  /// No description provided for @birthdateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quando você nasceu?'**
  String get birthdateTitle;

  /// No description provided for @birthdateDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get birthdateDay;

  /// No description provided for @birthdateMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get birthdateMonth;

  /// No description provided for @birthdateYear.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get birthdateYear;

  /// No description provided for @birthdatePickFromCalendar.
  ///
  /// In pt, this message translates to:
  /// **'Escolher no calendário'**
  String get birthdatePickFromCalendar;

  /// No description provided for @birthdateTimeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hora do nascimento'**
  String get birthdateTimeTitle;

  /// No description provided for @birthdateTimeOptional.
  ///
  /// In pt, this message translates to:
  /// **'Opcional'**
  String get birthdateTimeOptional;

  /// No description provided for @birthdateTimeToggle.
  ///
  /// In pt, this message translates to:
  /// **'Sei a hora em que nasci'**
  String get birthdateTimeToggle;

  /// No description provided for @birthdateReveal.
  ///
  /// In pt, this message translates to:
  /// **'Revelar meu resumo'**
  String get birthdateReveal;

  /// No description provided for @birthdateErrorInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Essa data não existe. Confira o dia e o mês.'**
  String get birthdateErrorInvalid;

  /// No description provided for @birthdateErrorFuture.
  ///
  /// In pt, this message translates to:
  /// **'A data não pode estar no futuro.'**
  String get birthdateErrorFuture;

  /// No description provided for @birthdateErrorTooOld.
  ///
  /// In pt, this message translates to:
  /// **'Digite um ano a partir de 1900.'**
  String get birthdateErrorTooOld;

  /// No description provided for @revealTitle.
  ///
  /// In pt, this message translates to:
  /// **'Olhando o céu de {date}…'**
  String revealTitle(String date);

  /// No description provided for @revealStepLife.
  ///
  /// In pt, this message translates to:
  /// **'Calculando o seu tempo de vida'**
  String get revealStepLife;

  /// No description provided for @revealStepMoon.
  ///
  /// In pt, this message translates to:
  /// **'Encontrando a fase da Lua'**
  String get revealStepMoon;

  /// No description provided for @revealStepFact.
  ///
  /// In pt, this message translates to:
  /// **'Buscando um fato histórico'**
  String get revealStepFact;

  /// No description provided for @summaryClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar o resumo'**
  String get summaryClose;

  /// No description provided for @summaryProgress.
  ///
  /// In pt, this message translates to:
  /// **'Cartão {current} de {total}'**
  String summaryProgress(int current, int total);

  /// No description provided for @summaryShareCard.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar este cartão'**
  String get summaryShareCard;

  /// No description provided for @lifeEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de vida'**
  String get lifeEyebrow;

  /// No description provided for @lifeYears.
  ///
  /// In pt, this message translates to:
  /// **'{years, plural, =1{1 ano} other{{years} anos}}'**
  String lifeYears(int years);

  /// No description provided for @lifeMonthsAndDays.
  ///
  /// In pt, this message translates to:
  /// **'{months, plural, =1{1 mês} other{{months} meses}} e {days, plural, =1{1 dia} other{{days} dias}}'**
  String lifeMonthsAndDays(int months, int days);

  /// No description provided for @lifeSoFar.
  ///
  /// In pt, this message translates to:
  /// **'Até agora você viveu'**
  String get lifeSoFar;

  /// No description provided for @lifeUnitDays.
  ///
  /// In pt, this message translates to:
  /// **'dias'**
  String get lifeUnitDays;

  /// No description provided for @lifeUnitHours.
  ///
  /// In pt, this message translates to:
  /// **'horas'**
  String get lifeUnitHours;

  /// No description provided for @lifeUnitMinutes.
  ///
  /// In pt, this message translates to:
  /// **'minutos'**
  String get lifeUnitMinutes;

  /// No description provided for @lifeUnitSeconds.
  ///
  /// In pt, this message translates to:
  /// **'segundos'**
  String get lifeUnitSeconds;

  /// No description provided for @lifeNextBirthday.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =0{Hoje é o seu aniversário!} =1{Falta 1 dia para o seu próximo aniversário} other{Faltam {days} dias para o seu próximo aniversário}}'**
  String lifeNextBirthday(int days);

  /// No description provided for @conceptionEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Concepção'**
  String get conceptionEyebrow;

  /// No description provided for @conceptionLead.
  ///
  /// In pt, this message translates to:
  /// **'Sua história começou entre'**
  String get conceptionLead;

  /// No description provided for @moonEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Fase da Lua'**
  String get moonEyebrow;

  /// No description provided for @moonBornUnder.
  ///
  /// In pt, this message translates to:
  /// **'Você nasceu numa {phase}'**
  String moonBornUnder(String phase);

  /// No description provided for @moonCycleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ciclo da Lua'**
  String get moonCycleLabel;

  /// No description provided for @factEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Fato histórico'**
  String get factEyebrow;

  /// No description provided for @factDaysAfterBirth.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =0{No dia do seu nascimento} =1{1 dia depois do seu nascimento} other{{days} dias depois do seu nascimento}}'**
  String factDaysAfterBirth(int days);

  /// No description provided for @factDaysBeforeBirth.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{1 dia antes do seu nascimento} other{{days} dias antes do seu nascimento}}'**
  String factDaysBeforeBirth(int days);

  /// No description provided for @factAiBadge.
  ///
  /// In pt, this message translates to:
  /// **'Ilustração gerada por IA'**
  String get factAiBadge;

  /// No description provided for @factErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos buscar o fato histórico'**
  String get factErrorTitle;

  /// No description provided for @factRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get factRetry;

  /// No description provided for @factSeeWhatIsReady.
  ///
  /// In pt, this message translates to:
  /// **'Ver o que já está pronto'**
  String get factSeeWhatIsReady;

  /// No description provided for @endShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar meu resumo'**
  String get endShare;

  /// No description provided for @adLabel.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio'**
  String get adLabel;

  /// No description provided for @birthSongTitle.
  ///
  /// In pt, this message translates to:
  /// **'A trilha do seu nascimento'**
  String get birthSongTitle;

  /// No description provided for @birthSongIntro.
  ///
  /// In pt, this message translates to:
  /// **'Em {period}, uma das músicas em destaque no Brasil foi:'**
  String birthSongIntro(String period);

  /// No description provided for @birthSongDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Informação gerada por I.A.; pode conter imprecisões.'**
  String get birthSongDisclaimer;

  /// No description provided for @listenOnSpotify.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir no Spotify'**
  String get listenOnSpotify;

  /// No description provided for @listenOnYoutube.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir no YouTube'**
  String get listenOnYoutube;

  /// No description provided for @birthSongOpenError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o link.'**
  String get birthSongOpenError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
