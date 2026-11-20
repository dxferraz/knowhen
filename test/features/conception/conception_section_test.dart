import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the conception window formatted as dd/MM/yyyy', (tester) async {
    await tester.pumpApp(ConceptionSection(birthDate: DateTime(2000, 10, 10)), TestDependencies());

    expect(find.text('28/12/1999 a 11/01/2000'), findsOneWidget);
  });
}
