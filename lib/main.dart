import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/config/firebase_options.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/firebase_service.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/services/local_milestone_notifier.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';
import 'package:knowhen/core/services/notification_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService().signInUserAnonymously();
  await MobileAds.instance.initialize();
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ['9C1FE904906DF4C7D5C7E2287B821399'],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  final analytics = AnalyticsService(FirebaseAnalytics.instance);

  final l10n = lookupAppLocalizations(const Locale('pt'));
  final navigatorKey = GlobalKey<NavigatorState>();
  final notifier = LocalMilestoneNotifier(
    channelName: l10n.milestoneChannelName,
    channelDescription: l10n.milestoneChannelDescription,
  );
  final profile = LifeProfileService(
    storage: BirthdateStorage(),
    notifier: notifier,
    analytics: analytics,
    l10n: l10n,
  );
  final router = NotificationRouter(navigatorKey: navigatorKey, profile: profile, analytics: analytics);

  final openMilestone = await startLifeProfile(notifier: notifier, profile: profile, router: router);

  runApp(
    MultiProvider(
      providers: [
        Provider<AnalyticsService>.value(value: analytics),
        Provider<AdService>(create: (context) => AdService(analytics)),
        Provider<BrazilCuriositiesRepository>(
          create: (context) => HistoricalFactsRepositoryImpl(firestore: FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(create: (context) => ThemeProvider(analytics)),
        ChangeNotifierProvider.value(value: profile),
      ],
      child: MyApp(
        showOnboarding: showOnboarding,
        savedBirthdate: profile.saved,
        openMilestone: openMilestone,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

/// Prepara notificações e carrega a data salva. Cada etapa falha isoladamente: notificações são um
/// extra, então um erro do plugin nunca impede o app de ler a data salva nem de abrir.
/// Retorna se o app foi aberto por uma notificação de marco.
Future<bool> startLifeProfile({
  required MilestoneNotifier notifier,
  required LifeProfileService profile,
  required NotificationRouter router,
}) async {
  var pluginReady = false;
  try {
    await notifier.initialize(onSelected: router.open);
    pluginReady = true;
  } catch (e) {
    debugPrint('Error starting notifications: $e');
  }

  try {
    await profile.load();
  } catch (e) {
    debugPrint('Error loading saved birthdate: $e');
  }

  if (!pluginReady) return false;
  try {
    return router.handleLaunch(await notifier.launchPayload());
  } catch (e) {
    debugPrint('Error reading launch notification: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  /// Com data salva o app abre direto no resumo.
  final SavedBirthdate? savedBirthdate;

  /// Abre o resumo já no card "Próximo marco" (app aberto por uma notificação).
  final bool openMilestone;
  final GlobalKey<NavigatorState>? navigatorKey;
  final SummaryBuilder summaryBuilder;

  const MyApp({
    super.key,
    required this.showOnboarding,
    this.savedBirthdate,
    this.openMilestone = false,
    this.navigatorKey,
    this.summaryBuilder = buildSummaryPage,
  });

  Widget _home() {
    final saved = savedBirthdate;
    if (saved != null) {
      return summaryBuilder(saved, openMilestone: openMilestone);
    }
    return showOnboarding ? const OnboardingPage() : const BirthdatePage();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: _home(),
        );
      },
    );
  }
}
