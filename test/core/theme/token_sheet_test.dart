import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/load_app_fonts.dart';
import 'token_sheet.dart';

/// Golden da folha de tokens nos dois temas. Imagens geradas no Linux (o mesmo ambiente do CI) com as fontes
/// empacotadas e sem rede. Para regenerar depois de uma mudança intencional:
/// `flutter test test/core/theme/token_sheet_test.dart --update-goldens`.
void main() {
  late Map<String, List<String>> fontFiles;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    fontFiles = await loadAppFonts();
  });

  test('o app empacota as famílias e os pesos da folha de tokens', () {
    expect(fontFiles.keys, containsAll(['Inter', 'DM Serif Display', 'Yatra One', 'Poppins']));
    expect(fontFiles['Inter'], hasLength(3), reason: 'Inter: regular, semibold e bold');
    expect(fontFiles['DM Serif Display'], hasLength(1));
    expect(fontFiles['Yatra One'], hasLength(1));
    expect(fontFiles['Poppins'], hasLength(1));
  });

  for (final brightness in Brightness.values) {
    final name = brightness == Brightness.dark ? 'escuro' : 'claro';

    testWidgets('folha de tokens, tema $name', (tester) async {
      tester.view
        ..physicalSize = TokenSheet.size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(TokenSheet(brightness: brightness));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(find.byType(TokenSheet), matchesGoldenFile('goldens/token_sheet_$name.png'));
    });
  }
}
