import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/config/firebase_options.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:knowhen/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Knowhen',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: themeProvider.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: showOnboarding ? const OnboardingPage() : const BirthdatePage(),
          );
        },
      ),
    );
  }
}
