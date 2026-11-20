import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/years_of_life.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  final birthDate = DateTime(1990, 5, 20);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('loads the summary, shows the first section and loads the ad', (tester) async {
    final curiosity = Completer<void>();
    final deps = TestDependencies(repository: FakeBrazilCuriositiesRepository(wait: curiosity));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    curiosity.complete();
    await tester.pumpAndSettle();

    expect(find.text(l10n.summaryPageTitle('20/05/1990')), findsOneWidget);
    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    expect(deps.adService.loadCalls, 1);
    expect(deps.adService.showCalls, 1);
    expect(deps.firebaseAnalytics.names, ['summary_viewed', 'summary_section_viewed']);
    expect(deps.firebaseAnalytics.events.last.parameters, {'section_name': 'years_of_life', 'section_index': 0});
  });

  testWidgets('shows an error when the repository fails', (tester) async {
    final deps = TestDependencies(repository: FakeBrazilCuriositiesRepository(error: StateError('No element')));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    expect(find.byType(YearsOfLifeSection), findsNothing);
    expect(find.textContaining('No element'), findsOneWidget);
  });
}
