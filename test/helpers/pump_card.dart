import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';

import 'pump_app.dart';

/// Tamanho da área de um cartão num celular de 360x640: a tela menos o topo, o progresso e o rodapé da casca.
const cardArea = Size(360, 440);

/// O que um cartão do resumo precisa para ser testado sozinho: o tema do app, as datas em pt-BR e a área que a casca
/// lhe dá. Devolve depois de assentar as animações de entrada.
Future<void> pumpCard(
  WidgetTester tester,
  Widget card, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool disableAnimations = false,
  TestDependencies? deps,
  bool settle = true,
}) async {
  await initializeDateFormatting('pt');
  tester.view
    ..physicalSize = cardArea
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    (deps ?? TestDependencies()).wrap(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark ? darkTheme : lightTheme,
        themeAnimationDuration: Duration.zero,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: disableAnimations),
          child: app!,
        ),
        home: Scaffold(body: card),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}
