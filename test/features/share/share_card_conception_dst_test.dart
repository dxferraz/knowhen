import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowhen/core/functions/conception_window.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations_pt.dart';
import 'package:knowhen/features/share/domain/share_card_content.dart';
import 'package:knowhen/features/share/domain/share_section.dart';

/// A janela de concepção do compartilhável tem de ser a mesma do cartão, inclusive quando ela cruza o início do
/// horário de verão. Em UTC não há mudança de horário e o teste passa de qualquer jeito; para ele pegar a regressão,
/// rode com o fuso de São Paulo (é o que o CI faz num passo à parte):
///
///     TZ=America/Sao_Paulo flutter test test/features/share/share_card_conception_dst_test.dart
///
/// No código antigo (`center ± Duration(days: 7)`), o início da janela de quem nasceu em 15/07/2018 caía em
/// 14/10/2017 23:00 e o texto mostrava 14/10, um dia antes do cartão.
void main() {
  setUpAll(() => initializeDateFormatting('pt'));

  final l10n = AppLocalizationsPt();
  final inSaoPaulo = Platform.environment['TZ'] == 'America/Sao_Paulo';

  test('o fuso do teste tem horário de verão começando em 15/10/2017', () {
    expect(DateTime(2017, 10, 15, 1).timeZoneOffset, isNot(DateTime(2017, 10, 14, 23).timeZoneOffset));
  }, skip: inSaoPaulo ? false : 'rode com TZ=America/Sao_Paulo');

  test('o rótulo do compartilhável usa as mesmas datas de conceptionWindow quando a janela cruza o horário de verão', () {
    final birth = DateTime(2018, 7, 15);
    final window = conceptionWindow(birth);
    final data = ShareCardData(
      birthDate: birth,
      now: DateTime(2026, 11, 21),
      moonPhase: const MoonPhase(type: MoonPhaseType.fullMoon, imageUrl: ''),
    );

    final content = ShareCardContent.build(l10n, ShareSection.conception, data, hideFullDate: false);

    expect(window.start, DateTime(2017, 10, 15));
    expect(window.end, DateTime(2017, 10, 29));
    expect(content.highlight, l10n.shareConceptionRange(window.start, window.end));
    expect(content.highlight, '15/10/2017 a 29/10/2017');
  });
}
