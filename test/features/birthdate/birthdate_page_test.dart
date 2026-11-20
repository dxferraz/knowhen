import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/theme/theme_provider.dart';
import 'package:knowhen/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('o seletor de data permite escolher até a data de hoje', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(showOnboarding: false),
      ),
    );
    await tester.pump();

    final datePicker = tester.widget<DatePicker>(find.byType(DatePicker));
    expect(datePicker.maxDate, DateUtils.dateOnly(DateTime.now()));
    expect(datePicker.minDate, DateTime(1925, 1, 1));
  });
}
