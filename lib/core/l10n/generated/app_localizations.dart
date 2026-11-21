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
  /// **'Próximo'**
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

  /// No description provided for @onboarding1Title.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao Knowhen!'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Description.
  ///
  /// In pt, this message translates to:
  /// **'Descubra informações únicas, surpreendentes e personalizadas com base na sua data de nascimento'**
  String get onboarding1Description;

  /// No description provided for @onboarding2Title.
  ///
  /// In pt, this message translates to:
  /// **'Desvendando o que sua data de nascimento revela!'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Description.
  ///
  /// In pt, this message translates to:
  /// **'Explore dados personalizados sobre sua personalidade, curiosidades históricas e insights únicos baseados na sua data de nascimento.'**
  String get onboarding2Description;

  /// No description provided for @onboarding3Title.
  ///
  /// In pt, this message translates to:
  /// **'Vamos descobrir?'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Description.
  ///
  /// In pt, this message translates to:
  /// **'Insira sua data de nascimento e veja o que o universo tem reservado para você!'**
  String get onboarding3Description;

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
