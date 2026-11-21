import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('o seletor de data permite escolher até a data de hoje', (WidgetTester tester) async {
    await tester.pumpWidget(TestDependencies().wrap(const MyApp(showOnboarding: false)));
    await tester.pump();

    final datePicker = tester.widget<DatePicker>(find.byType(DatePicker));
    expect(datePicker.maxDate, DateUtils.dateOnly(DateTime.now()));
    expect(datePicker.minDate, DateTime(1925, 1, 1));
  });
}
