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

  /// No description provided for @conceptionFooter.
  ///
  /// In pt, this message translates to:
  /// **'Foi quando a cegonha te levou ao colo de sua mãe!'**
  String get conceptionFooter;

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
