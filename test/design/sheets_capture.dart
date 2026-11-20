// Pranchas (contact sheets) com as capturas da auditoria e dos mockups — DXF-9.
// Rodar depois de audit_capture.dart e proposal_capture.dart:
//
// flutter test test/design/sheets_capture.dart --update-goldens
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const double _cellW = 300;
const double _cellH = 649; // 390x844 reduzido
const int _cols = 4;

class _Sheet extends StatelessWidget {
  final String title;
  final List<(String, String)> items;
  final Map<String, ui.Image> images;
  final bool dark;
  const _Sheet({required this.title, required this.items, required this.images, required this.dark});

  @override
  Widget build(BuildContext context) {
    final fg = dark ? const Color(0xFFF5F1E8) : const Color(0xFF15172E);
    return Container(
      color: dark ? const Color(0xFF05071A) : const Color(0xFFEDEAE4),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'KnSerif', fontSize: 36, color: fg),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final (label, path) in items)
                SizedBox(
                  width: _cellW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontFamily: 'KnInter', fontSize: 16, fontWeight: FontWeight.w600, color: fg),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: RawImage(
                          image: images[path],
                          width: _cellW,
                          height: _cellW * images[path]!.height / images[path]!.width,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _sheet(
  WidgetTester tester,
  String name,
  String title,
  List<(String, String)> items, {
  bool dark = false,
}) async {
  final rows = (items.length / _cols).ceil();
  final size = Size(32 * 2 + _cols * _cellW + (_cols - 1) * 24, 32 * 2 + 80 + rows * (_cellH + 40) + (rows - 1) * 24);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final images = <String, ui.Image>{};
  await tester.runAsync(() async {
    for (final (_, path) in items) {
      final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
      images[path] = (await codec.getNextFrame()).image;
    }
  });
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _Sheet(title: title, items: items, images: images, dark: dark),
      ),
    ),
  );
  await tester.pump();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/sheets/$name.png'));
}

const _cur = 'test/design/shots/current';
const _pro = 'test/design/shots/proposal';
const _glass = 'test/design/shots/glass'; // capturas da branch claude/glassmorphism-custom-theme-yyfvyf

void main() {
  setUpAll(loadProposalFonts);

  testWidgets('atual', (tester) async {
    await _sheet(tester, '1_atual', 'Knowhen hoje (main @ bb67dd5)', [
      ('Onboarding 1/3', '$_cur/onboarding1_light.png'),
      ('Onboarding 2/3 (escuro)', '$_cur/onboarding2_dark.png'),
      ('Onboarding 3/3', '$_cur/onboarding3_light.png'),
      ('Data: abre na grade de anos', '$_cur/birthdate_light.png'),
      ('Data selecionada', '$_cur/birthdate_selected_light.png'),
      ('Hora: diálogo padrão azul', '$_cur/timepicker_light.png'),
      ('Resumo 1: tempo de vida', '$_cur/summary1_light.png'),
      ('Resumo 2: concepção', '$_cur/summary2_light.png'),
      ('Resumo 2: menor de 18 (vazio)', '$_cur/summary2_minor_light.png'),
      ('Resumo 3: lua (imagem falhou)', '$_cur/summary3_light.png'),
      ('Resumo 4: fato histórico', '$_cur/summary4_light.png'),
      ('Resumo 4 (escuro)', '$_cur/summary4_dark.png'),
      ('Carregando', '$_cur/summary_loading_light.png'),
      ('Erro (texto técnico)', '$_cur/summary_error_light.png'),
      ('Tela pequena 360x640: overflow', '$_cur/birthdate_small_light.png'),
      ('Fonte 130%', '$_cur/summary1_scale130_light.png'),
    ]);
  });

  for (final (t, dark) in [('escuro', true), ('claro', false)]) {
    final s = dark ? 'dark' : 'light';
    testWidgets('proposta $t', (tester) async {
      await _sheet(tester, dark ? '2_proposta_escuro' : '3_proposta_claro', 'Proposta "Céu de Nascimento" — tema $t', [
        ('Onboarding (1 tela)', '$_pro/onboarding_$s.png'),
        ('Data: vazia', '$_pro/birthdate_empty_$s.png'),
        ('Data: preenchida + hora', '$_pro/birthdate_$s.png'),
        ('Revelação (carregando)', '$_pro/reveal_$s.png'),
        ('1 · Tempo de vida', '$_pro/summary1_years_$s.png'),
        ('2 · Concepção', '$_pro/summary2_conception_$s.png'),
        ('3 · Fase da lua', '$_pro/summary3_moon_$s.png'),
        ('4 · Fato histórico', '$_pro/summary4_fact_$s.png'),
        ('5 · Fim: compartilhar + anúncio', '$_pro/summary5_end_$s.png'),
        ('Erro parcial', '$_pro/error_$s.png'),
        ('Tokens', '$_pro/tokens_$s.png'),
        if (dark) ('Fonte 130%', '$_pro/summary1_years_scale130_dark.png'),
        if (!dark) ('Fonte 130%', '$_pro/birthdate_scale130_light.png'),
      ], dark: dark);
    });
  }

  testWidgets('alternativa glass', (tester) async {
    await _sheet(tester, '4_alternativa_glass', 'Alternativa: branch claude/glassmorphism (0c92234)', [
      ('Onboarding (claro)', '$_glass/glass_onboarding1_light.png'),
      ('Data (claro)', '$_glass/glass_birthdate_light.png'),
      ('Tempo de vida (escuro)', '$_glass/glass_summary_years_dark.png'),
      ('Lua (escuro)', '$_glass/glass_summary_moon_dark.png'),
      ('Fato (claro)', '$_glass/glass_summary_fact_light.png'),
      ('Concepção (escuro)', '$_glass/glass_summary_conception_dark.png'),
      ('Design system (claro)', '$_glass/glass_design_system_light.png'),
      ('Design system (escuro)', '$_glass/glass_design_system_dark.png'),
    ], dark: true);
  });
}
