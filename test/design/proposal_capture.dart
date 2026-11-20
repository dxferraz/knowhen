// Mockups da direção "Céu de Nascimento" para a proposta de redesign — DXF-9.
//
// flutter test test/design/proposal_capture.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'proposal/kn_design.dart';
import 'proposal/kn_screens.dart';
import 'support.dart';

Widget mock(Widget home, {double textScale = 1.0}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(fontFamily: knSans, useMaterial3: true),
  locale: const Locale('pt', 'BR'),
  supportedLocales: const [Locale('pt', 'BR')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

void main() {
  setUpAll(loadProposalFonts);

  final screens = <String, Widget Function(KnPalette)>{
    'tokens': (p) => TokensSheet(p: p),
    'onboarding': (p) => OnboardingMock(p: p),
    'birthdate': (p) => BirthdateMock(p: p),
    'birthdate_empty': (p) => BirthdateMock(p: p, filled: false),
    'reveal': (p) => RevealMock(p: p),
    'summary1_years': (p) => YearsCardMock(p: p),
    'summary2_conception': (p) => ConceptionCardMock(p: p),
    'summary3_moon': (p) => MoonCardMock(p: p),
    'summary4_fact': (p) => FactCardMock(p: p),
    'summary5_end': (p) => EndCardMock(p: p),
    'error': (p) => ErrorMock(p: p),
  };

  for (final (p, t) in [(knNight, 'dark'), (knDawn, 'light')]) {
    screens.forEach((name, build) {
      testWidgets('$name $t', (tester) async {
        await capture(tester, mock(build(p)), 'proposal/${name}_$t');
      });
    });
  }

  testWidgets('summary1 textScale 1.3', (tester) async {
    await capture(tester, mock(YearsCardMock(p: knNight), textScale: 1.3), 'proposal/summary1_years_scale130_dark');
  });
  testWidgets('birthdate textScale 1.3', (tester) async {
    await capture(tester, mock(BirthdateMock(p: knDawn), textScale: 1.3), 'proposal/birthdate_scale130_light');
  });
  testWidgets('birthdate small', (tester) async {
    await capture(tester, mock(BirthdateMock(p: knDawn)), 'proposal/birthdate_small_light', size: const Size(360, 640));
  });
  testWidgets('summary1 small', (tester) async {
    await capture(
      tester,
      mock(YearsCardMock(p: knNight)),
      'proposal/summary1_years_small_dark',
      size: const Size(360, 640),
    );
  });
}
