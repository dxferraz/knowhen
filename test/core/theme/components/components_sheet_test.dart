import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/load_app_fonts.dart';
import 'components_sheet.dart';

/// Goldens dos componentes nos dois temas. Imagens geradas no Linux (o mesmo ambiente do CI) com as fontes
/// empacotadas. Para regenerar depois de uma mudança intencional:
/// `flutter test test/core/theme/components/components_sheet_test.dart --update-goldens`.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  for (final brightness in Brightness.values) {
    final name = brightness == Brightness.dark ? 'escuro' : 'claro';

    testWidgets('folha de componentes, tema $name', (tester) async {
      tester.view
        ..physicalSize = ComponentsSheet.size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ComponentsSheet(brightness: brightness));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(find.byType(ComponentsSheet), matchesGoldenFile('goldens/components_sheet_$name.png'));
    });
  }
}
