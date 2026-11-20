// Utilitários de captura de tela para a auditoria de design (DXF-9).
//
// Não é um teste de regressão: os arquivos *_capture.dart só rodam quando
// chamados explicitamente (ver test/design/README.md) e gravam PNGs em
// test/design/shots/ via `--update-goldens`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String _fixtures = 'test/design/fixtures/fonts';

Future<void> loadFontFiles(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(File(path).readAsBytes().then((b) => ByteData.view(Uint8List.fromList(b).buffer)));
  }
  await loader.load();
}

String _flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null) return env;
  // flutter_tester roda a partir de <flutter>/bin/cache/artifacts/engine/...
  final exe = File(Platform.resolvedExecutable).absolute.path;
  return exe.substring(0, exe.indexOf('/bin/cache/'));
}

/// Carrega Material Icons e Roboto do SDK. Roboto é registrada também como
/// "Inter": o tema atual declara `fontFamily: 'Inter'` sem empacotar a fonte,
/// então no Android o texto sem família explícita cai na fonte do sistema.
Future<void> loadBaseFonts() async {
  final fonts = '${_flutterRoot()}/bin/cache/artifacts/material_fonts';
  await loadFontFiles('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
  final roboto = ['$fonts/Roboto-Regular.ttf', '$fonts/Roboto-Medium.ttf', '$fonts/Roboto-Bold.ttf'];
  await loadFontFiles('Roboto', roboto);
  await loadFontFiles('Inter', roboto);
}

/// Fontes exatamente como o `main` atual as recebe do google_fonts em
/// runtime: o próprio google_fonts baixa os arquivos (servidos aqui a partir
/// de fixtures/gstatic, mesmos bytes e hash do fonts.gstatic.com). Só o peso
/// regular de cada família é baixado; o negrito é sintetizado.
Future<void> loadCurrentAppFonts() async {
  await loadBaseFonts();
  final cacheDir = Directory.systemTemp.createTempSync('knowhen_fonts');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => cacheDir.path,
  );
  GoogleFonts.config.allowRuntimeFetching = true;
  GoogleFonts.config.httpClient = MockClient((request) async {
    final file = File('test/design/fixtures/gstatic/${request.url.pathSegments.last}');
    if (!file.existsSync()) return http.Response('', 404);
    return http.Response.bytes(await file.readAsBytes(), 200);
  });
  await GoogleFonts.pendingFonts([GoogleFonts.inter(), GoogleFonts.poppins(), GoogleFonts.yatraOne()]);
}

/// Fontes da proposta "Céu de Nascimento".
Future<void> loadProposalFonts() async {
  await loadBaseFonts();
  await loadFontFiles('KnInter', [
    '$_fixtures/Inter-Regular.ttf',
    '$_fixtures/Inter-SemiBold.ttf',
    '$_fixtures/Inter-Bold.ttf',
  ]);
  await loadFontFiles('KnSerif', ['$_fixtures/DMSerifDisplay-Regular.ttf']);
  await loadFontFiles('KnSerifItalic', ['$_fixtures/DMSerifDisplay-Italic.ttf']);
  await loadFontFiles('YatraOne', ['$_fixtures/YatraOne-Regular.ttf']);
}

/// Configura um viewport de celular (390x844 lógico, 2x) e devolve uma
/// função para gravar o PNG da tela inteira.
Future<void> capture(
  WidgetTester tester,
  Widget app,
  String name, {
  Size size = const Size(390, 844),
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(app);
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 25));
  }
  if (interact != null) await interact(tester);
  // Erros de imagem de rede e overflow fazem parte do retrato do estado
  // atual; ficam registrados no log e não interrompem a captura.
  final error = tester.takeException();
  if (error != null) debugPrint('[$name] exceção capturada: $error');
  await expectLater(find.byType(MaterialApp).first, matchesGoldenFile('shots/$name.png'));
}
