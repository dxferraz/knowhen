import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/birthdate/presentation/widgets/birth_time_card.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

/// Tela de data num celular de 360x640 com o tema do app, igual ao de produção.
Future<void> _pumpPhone(
  WidgetTester tester,
  TestDependencies deps, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  DateTime? initialBirthDate,
  bool root = true,
}) async {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final page = BirthdatePage(initialBirthDate: initialBirthDate);
  await tester.pumpWidget(
    deps.wrap(
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          themeAnimationDuration: Duration.zero,
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: app!,
          ),
          home: root
              ? page
              : Builder(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => page)),
                      child: const Text('abrir'),
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
  if (!root) {
    await tester.tap(find.text('abrir'));
  }
  await tester.pumpAndSettle();
}

/// A rota nova entra `offstage` no primeiro quadro e só aparece no seguinte. Não dá para usar
/// `pumpAndSettle`: o resumo tem animações que nunca terminam.
Future<void> _openSummary(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// A borda dos campos muda de cor com uma animação de 167 ms. Sem esperar, o golden pega a cor antiga.
/// Não dá para usar `pumpAndSettle`: o cursor piscando nunca deixa de pedir quadros.
Future<void> _settleBorders(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 300));

Finder get _fields => find.byType(TextField);

Future<void> _type(
  WidgetTester tester,
  String day,
  String month,
  String year,
) async {
  await tester.enterText(_fields.at(0), day);
  await tester.enterText(_fields.at(1), month);
  await tester.enterText(_fields.at(2), year);
  await tester.pump();
}

String _two(int value) => value.toString().padLeft(2, '0');

bool _focused(WidgetTester tester, int index) =>
    tester.widget<TextField>(_fields.at(index)).focusNode!.hasFocus;

KnButton _cta(WidgetTester tester) =>
    tester.widget<KnButton>(find.byType(KnButton));

void main() {
  late TestDependencies deps;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
    await initializeDateFormatting('pt');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    deps = TestDependencies();
  });

  group('campos', () {
    testWidgets(
      'abre vazia, com título, três campos, a ajuda e o CTA desabilitado',
      (tester) async {
        await _pumpPhone(tester, deps);

        expect(find.text(l10n.birthdateTitle), findsOneWidget);
        expect(_fields, findsNWidgets(3));
        expect(find.text(l10n.birthdateDayHint), findsOneWidget);
        expect(find.text(l10n.birthdateMonthHint), findsOneWidget);
        expect(find.text(l10n.birthdateYearHint), findsOneWidget);
        expect(find.text(l10n.birthdateHint), findsOneWidget);
        expect(find.text(l10n.birthdateReveal), findsOneWidget);
        expect(_cta(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'data válida mostra o dia da semana por extenso e habilita o CTA',
      (tester) async {
        await _pumpPhone(tester, deps);
        await _type(tester, '14', '03', '1991');

        expect(find.text('Quinta-feira, 14 de março de 1991'), findsOneWidget);
        expect(find.text(l10n.birthdateHint), findsNothing);
        expect(_cta(tester).onPressed, isNotNull);
      },
    );

    testWidgets('só aceita dígitos e limita 2, 2 e 4 caracteres', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '1a2b3', '0-9x7', '19 91x77');

      expect(tester.widget<TextField>(_fields.at(0)).controller!.text, '12');
      expect(tester.widget<TextField>(_fields.at(1)).controller!.text, '09');
      expect(tester.widget<TextField>(_fields.at(2)).controller!.text, '1991');
    });

    testWidgets('o foco avança sozinho do dia para o mês e do mês para o ano', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);

      await tester.tap(_fields.at(0));
      await tester.pump();
      await tester.enterText(_fields.at(0), '1');
      await tester.pump();
      expect(
        _focused(tester, 0),
        isTrue,
        reason: 'com um dígito ainda falta o segundo',
      );

      await tester.enterText(_fields.at(0), '14');
      await tester.pump();
      expect(_focused(tester, 1), isTrue);

      await tester.enterText(_fields.at(1), '03');
      await tester.pump();
      expect(_focused(tester, 2), isTrue);
    });

    testWidgets('apagar num campo vazio volta o foco para o anterior', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);
      await tester.tap(_fields.at(2));
      await tester.pump();
      expect(_focused(tester, 2), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(_focused(tester, 1), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(_focused(tester, 0), isTrue);
    });

    testWidgets('abre preenchida com a data de quem voltou do resumo', (
      tester,
    ) async {
      await _pumpPhone(tester, deps, initialBirthDate: DateTime(1991, 3, 5));

      expect(tester.widget<TextField>(_fields.at(0)).controller!.text, '05');
      expect(tester.widget<TextField>(_fields.at(1)).controller!.text, '03');
      expect(tester.widget<TextField>(_fields.at(2)).controller!.text, '1991');
      expect(_cta(tester).onPressed, isNotNull);
    });
  });

  group('validação', () {
    testWidgets(
      'dia que não existe no mês mostra o erro e mantém o CTA desabilitado',
      (tester) async {
        await _pumpPhone(tester, deps);
        await _type(tester, '31', '02', '1991');

        expect(find.text(l10n.birthdateErrorInvalid), findsOneWidget);
        expect(_cta(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'com erro, os três campos ganham a borda de erro, e perdem ao corrigir',
      (tester) async {
        await _pumpPhone(tester, deps);
        final danger = tester.element(find.byType(BirthdatePage)).kn.danger;
        Color border(int index, {bool focused = false}) {
          final decoration = tester
              .widget<TextField>(_fields.at(index))
              .decoration!;
          return ((focused
                      ? decoration.focusedBorder
                      : decoration.enabledBorder)!
                  as OutlineInputBorder)
              .borderSide
              .color;
        }

        await _type(tester, '31', '02', '1991');
        for (var i = 0; i < 3; i++) {
          expect(border(i), danger);
          expect(border(i, focused: true), danger);
        }

        await tester.enterText(_fields.at(0), '28');
        await tester.pump();
        for (var i = 0; i < 3; i++) {
          expect(border(i), isNot(danger));
        }
      },
    );

    testWidgets('data no futuro mostra o erro', (tester) async {
      await _pumpPhone(tester, deps);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await _type(
        tester,
        _two(tomorrow.day),
        _two(tomorrow.month),
        tomorrow.year.toString(),
      );

      expect(find.text(l10n.birthdateErrorFuture), findsOneWidget);
      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets('ano antes de 1900 mostra o erro', (tester) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '14', '03', '1899');

      expect(find.text(l10n.birthdateErrorTooOld), findsOneWidget);
      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets(
      'hoje é aceito: quem nasceu a partir de 2025 consegue usar o app',
      (tester) async {
        await _pumpPhone(tester, deps);
        final today = DateTime.now();
        await _type(
          tester,
          _two(today.day),
          _two(today.month),
          today.year.toString(),
        );

        expect(
          find.text(DateText.long(DateUtils.dateOnly(today))),
          findsOneWidget,
        );
        expect(_cta(tester).onPressed, isNotNull);
      },
    );

    testWidgets('com o ano incompleto não mostra erro nem habilita o CTA', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '14', '03', '19');

      expect(find.text(l10n.birthdateHint), findsOneWidget);
      expect(find.text(l10n.birthdateErrorTooOld), findsNothing);
      expect(_cta(tester).onPressed, isNull);
    });

    testWidgets('corrigir o campo errado tira o erro', (tester) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '31', '02', '1991');
      expect(find.text(l10n.birthdateErrorInvalid), findsOneWidget);

      await tester.enterText(_fields.at(0), '28');
      await tester.pump();

      expect(find.text(l10n.birthdateErrorInvalid), findsNothing);
      expect(
        find.text('Quinta-feira, 28 de fevereiro de 1991'),
        findsOneWidget,
      );
      expect(_cta(tester).onPressed, isNotNull);
    });
  });

  group('calendário', () {
    testWidgets(
      'o ícone abre o seletor e a data escolhida preenche os campos',
      (tester) async {
        await _pumpPhone(tester, deps);

        await tester.tap(find.byTooltip(l10n.birthdatePickFromCalendar));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        final today = DateTime.now();
        expect(
          tester.widget<TextField>(_fields.at(0)).controller!.text,
          _two(today.day),
        );
        expect(
          tester.widget<TextField>(_fields.at(1)).controller!.text,
          _two(today.month),
        );
        expect(
          tester.widget<TextField>(_fields.at(2)).controller!.text,
          (today.year - 25).toString(),
        );
        expect(_cta(tester).onPressed, isNotNull);
      },
    );

    testWidgets('cancelar o seletor não muda os campos', (tester) async {
      await _pumpPhone(tester, deps);
      await tester.tap(find.byTooltip(l10n.birthdatePickFromCalendar));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(_fields.at(0)).controller!.text, isEmpty);
      expect(_cta(tester).onPressed, isNull);
    });
  });

  group('hora do nascimento', () {
    testWidgets('começa desligada, sem seletor', (tester) async {
      await _pumpPhone(tester, deps);

      expect(find.text(l10n.birthdateTimeTitle), findsOneWidget);
      expect(find.text(l10n.birthdateTimeHelpOff), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text(l10n.birthdateTimeHour), findsNothing);
    });

    testWidgets('ligar abre o seletor de HH:MM na própria tela, sem diálogo', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(BirthTimeCard), findsOneWidget);
      expect(find.text(l10n.birthdateTimeHelpOn('12:00')), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    });

    testWidgets('desligar de novo esconde o seletor', (tester) async {
      await _pumpPhone(tester, deps);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.byType(ListWheelScrollView), findsNothing);
      expect(find.text(l10n.birthdateTimeHelpOff), findsOneWidget);
    });

    testWidgets('rolar as rodas muda a hora mostrada', (tester) async {
      await _pumpPhone(tester, deps);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Cada linha da roda tem a altura da fonte; arrastar um pouco menos de duas linhas sobe duas casas.
      final hours = find.byType(ListWheelScrollView).first;
      await tester.drag(hours, const Offset(0, -80));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(l10n.birthdateTimeHelpOn('12:00')),
        findsNothing,
      );
      expect(find.byType(BirthTimeCard), findsOneWidget);
    });

    testWidgets(
      'sem hora, o resumo abre sem birthTime e o evento diz has_birth_time 0',
      (tester) async {
        await _pumpPhone(tester, deps);
        await _type(tester, '14', '03', '1991');

        await tester.tap(find.byType(KnButton));
        await _openSummary(tester);

        final summary = tester.widget<SummaryPage>(find.byType(SummaryPage));
        expect(summary.birthDate, DateTime(1991, 3, 14));
        expect(summary.birthTime, isNull);
        expect(deps.firebaseAnalytics.names, contains('birthdate_submitted'));
        expect(
          deps.firebaseAnalytics.events
              .firstWhere((e) => e.name == 'birthdate_submitted')
              .parameters!['has_birth_time'],
          0,
        );
      },
    );

    testWidgets(
      'com a hora ligada, o resumo recebe a hora escolhida e o evento diz has_birth_time 1',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpPhone(tester, deps);
        await _type(tester, '14', '03', '1991');
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        tester.semantics.performAction(
          find.semantics.byLabel(l10n.birthdateTimeHour),
          SemanticsAction.increase,
        );
        await tester.pumpAndSettle();
        tester.semantics.performAction(
          find.semantics.byLabel(l10n.birthdateTimeMinute),
          SemanticsAction.decrease,
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.birthdateTimeHelpOn('13:59')), findsOneWidget);

        await tester.tap(find.byType(KnButton));
        await _openSummary(tester);

        final summary = tester.widget<SummaryPage>(find.byType(SummaryPage));
        expect(summary.birthTime, const TimeOfDay(hour: 13, minute: 59));
        expect(
          deps.firebaseAnalytics.events
              .firstWhere((e) => e.name == 'birthdate_submitted')
              .parameters!['has_birth_time'],
          1,
        );
        semantics.dispose();
      },
    );

    testWidgets('a hora desligada depois de escolhida não vai para o resumo', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '14', '03', '1991');
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(KnButton));
      await _openSummary(tester);

      expect(
        tester.widget<SummaryPage>(find.byType(SummaryPage)).birthTime,
        isNull,
      );
    });
  });

  group('navegação', () {
    testWidgets('com o CTA desabilitado, tocar nele não abre o resumo', (
      tester,
    ) async {
      await _pumpPhone(tester, deps);

      await tester.tap(find.byType(KnButton), warnIfMissed: false);
      await _openSummary(tester);

      expect(find.byType(SummaryPage), findsNothing);
      expect(
        deps.firebaseAnalytics.names,
        isNot(contains('birthdate_submitted')),
      );
    });

    testWidgets('como primeira tela não tem botão de voltar', (tester) async {
      await _pumpPhone(tester, deps);

      expect(find.byTooltip(l10n.birthdateBack), findsNothing);
    });

    testWidgets('aberta por cima de outra tela, o botão de voltar volta', (
      tester,
    ) async {
      await _pumpPhone(tester, deps, root: false);

      await tester.tap(find.byTooltip(l10n.birthdateBack));
      await tester.pumpAndSettle();

      expect(find.byType(BirthdatePage), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });
  });

  group('acessibilidade', () {
    testWidgets(
      'título é cabeçalho, cada campo tem rótulo e o CTA diz que está desabilitado',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpPhone(tester, deps);

        expect(
          tester
              .getSemantics(find.text(l10n.birthdateTitle))
              .flagsCollection
              .isHeader,
          isTrue,
        );
        for (final (index, label) in [
          l10n.birthdateDay,
          l10n.birthdateMonth,
          l10n.birthdateYear,
        ].indexed) {
          final node = tester.getSemantics(
            find.descendant(
              of: _fields.at(index),
              matching: find.byType(EditableText),
            ),
          );
          // O rótulo e o campo de texto são um nó só (mesclados), lidos juntos pelo leitor de tela.
          final data = node.getSemanticsData();
          expect(data.flagsCollection.isTextField, isTrue);
          expect(data.label, contains(label));
        }

        final cta = tester.getSemantics(find.byType(KnButton));
        expect(cta.flagsCollection.isButton, isTrue);
        expect(cta.flagsCollection.isEnabled, Tristate.isFalse);
        expect(cta.label, l10n.birthdateReveal);

        await _type(tester, '14', '03', '1991');
        expect(
          tester.getSemantics(find.byType(KnButton)).flagsCollection.isEnabled,
          Tristate.isTrue,
        );
        semantics.dispose();
      },
    );

    testWidgets('o interruptor da hora tem rótulo e diz se está ligado', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpPhone(tester, deps);

      var node = tester.getSemantics(find.byType(Switch));
      expect(node.label, contains(l10n.birthdateTimeToggle));
      expect(node.flagsCollection.isToggled, Tristate.isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      node = tester.getSemantics(find.byType(Switch));
      expect(node.flagsCollection.isToggled, Tristate.isTrue);
      semantics.dispose();
    });

    testWidgets('cada roda é um ajustável com rótulo e valor', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPhone(tester, deps);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final hour = tester.getSemantics(
        find.bySemanticsLabel(l10n.birthdateTimeHour),
      );
      expect(hour.value, '12');
      expect(hour.increasedValue, '13');
      expect(hour.decreasedValue, '11');
      expect(
        hour.getSemanticsData().hasAction(SemanticsAction.increase),
        isTrue,
      );
      expect(
        hour.getSemanticsData().hasAction(SemanticsAction.decrease),
        isTrue,
      );
      semantics.dispose();
    });

    testWidgets('o erro e a data por extenso são anunciados como região viva', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpPhone(tester, deps);
      await _type(tester, '31', '02', '1991');

      final error = tester.getSemantics(find.text(l10n.birthdateErrorInvalid));
      expect(error.flagsCollection.isLiveRegion, isTrue);
      semantics.dispose();
    });

    testWidgets(
      'os botões de calendário, voltar e tema têm alvo de 48 dp; o CTA, 56 dp',
      (tester) async {
        await _pumpPhone(tester, deps, root: false);

        for (final button
            in tester
                .widgetList<KnIconButton>(find.byType(KnIconButton))
                .indexed) {
          expect(
            tester.getSize(find.byType(KnIconButton).at(button.$1)),
            const Size(KnSize.touchTarget, KnSize.touchTarget),
          );
        }
        expect(
          tester.getSize(find.byType(KnButton)).height,
          greaterThanOrEqualTo(KnSize.button),
        );
      },
    );

    testWidgets(
      'com animações desligadas, ligar a hora leva o seletor para a tela sem animar',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await _pumpPhone(tester, deps);

        await tester.tap(find.byType(Switch));
        await tester.pump();
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byType(ListWheelScrollView).first).bottom,
          lessThanOrEqualTo(640),
        );
      },
    );
  });

  group('layout', () {
    for (final brightness in Brightness.values) {
      final name = brightness == Brightness.dark ? 'escuro' : 'claro';

      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '360x640 a ${(scale * 100).round()}% de fonte, tema $name: sem overflow e CTA alcançável',
          (tester) async {
            await _pumpPhone(
              tester,
              deps,
              brightness: brightness,
              scale: scale,
            );
            expect(tester.takeException(), isNull);

            final screen =
                tester.view.physicalSize / tester.view.devicePixelRatio;
            void expectCtaOnScreen() {
              final cta = tester.getRect(find.byType(KnButton));
              expect(cta.bottom, lessThanOrEqualTo(screen.height));
              expect(cta.left, greaterThanOrEqualTo(0));
              expect(cta.right, lessThanOrEqualTo(screen.width));
            }

            expectCtaOnScreen();

            // Com erro, com a data válida e com a hora ligada: nada estoura e o conteúdo rola até o fim.
            await _type(tester, '31', '02', '1991');
            expect(tester.takeException(), isNull);
            await _type(tester, '14', '03', '1991');
            await tester.ensureVisible(find.byType(Switch));
            await tester.pumpAndSettle();
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expectCtaOnScreen();

            await tester.ensureVisible(find.byType(ListWheelScrollView).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final wheel = tester.getRect(find.byType(ListWheelScrollView).last);
            expect(
              wheel.bottom,
              lessThanOrEqualTo(tester.getRect(find.byType(KnButton)).top),
            );
          },
        );
      }
    }

    testWidgets(
      'a 200% de fonte os três campos continuam lado a lado e legíveis',
      (tester) async {
        await _pumpPhone(tester, deps, scale: 2);
        await _type(tester, '14', '03', '1991');

        final rects = [
          for (var i = 0; i < 3; i++) tester.getRect(_fields.at(i)),
        ];
        expect(rects[0].right, lessThan(rects[1].left));
        expect(rects[1].right, lessThan(rects[2].left));
        expect(rects[2].right, lessThanOrEqualTo(360));
        for (final rect in rects) {
          expect(rect.height, greaterThanOrEqualTo(KnSize.touchTarget));
        }
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('goldens', () {
    // Imagens geradas no Linux (o mesmo ambiente do CI) com as fontes empacotadas. Para regenerar depois de
    // uma mudança intencional: `flutter test test/features/birthdate --update-goldens`.
    testWidgets('vazia, tema claro', (tester) async {
      await _pumpPhone(tester, deps);

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(BirthdatePage),
        matchesGoldenFile('goldens/birthdate_vazia_claro.png'),
      );
    });

    testWidgets('preenchida, tema escuro', (tester) async {
      await _pumpPhone(tester, deps, brightness: Brightness.dark);
      await _type(tester, '14', '03', '1991');
      await _settleBorders(tester);

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(BirthdatePage),
        matchesGoldenFile('goldens/birthdate_preenchida_escuro.png'),
      );
    });

    testWidgets('com hora, tema claro', (tester) async {
      await _pumpPhone(tester, deps);
      await _type(tester, '14', '03', '1991');
      await _settleBorders(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(BirthdatePage),
        matchesGoldenFile('goldens/birthdate_com_hora_claro.png'),
      );
    });

    testWidgets('com erro, tema escuro', (tester) async {
      await _pumpPhone(tester, deps, brightness: Brightness.dark);
      await _type(tester, '31', '02', '1991');
      await _settleBorders(tester);

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(BirthdatePage),
        matchesGoldenFile('goldens/birthdate_erro_escuro.png'),
      );
    });
  });
}
