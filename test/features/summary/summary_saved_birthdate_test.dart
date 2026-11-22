import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  final birthDate = DateTime(1990, 5, 20);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<TestDependencies> openSummary(WidgetTester tester) async {
    final deps = TestDependencies();
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();
    return deps;
  }

  testWidgets('depois do resumo oferece salvar a data e o toque em "Salvar" guarda só no aparelho', (tester) async {
    final deps = await openSummary(tester);

    expect(find.text(l10n.saveBirthdateOffer), findsOneWidget);
    expect(deps.profile.saved, isNull);

    await tester.tap(find.text(l10n.saveBirthdateShort));
    await tester.pumpAndSettle();

    expect(deps.profile.saved, SavedBirthdate(birthDate));
    expect(await BirthdateStorage().read(), SavedBirthdate(birthDate));
    expect(find.text(l10n.birthdateSaved), findsOneWidget);
    expect(deps.milestoneAnalytics.events, ['birthdate_saved:manual']);
  });

  testWidgets('não oferece salvar quando esta data já está salva', (tester) async {
    final deps = TestDependencies();
    await deps.profile.save(birthDate, null);
    deps.milestoneAnalytics.events.clear();

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    expect(find.text(l10n.saveBirthdateOffer), findsNothing);
  });

  testWidgets('menu: com data salva, "Apagar data salva" remove do aparelho', (tester) async {
    final deps = TestDependencies();
    await deps.profile.save(birthDate, null);

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('summary_menu')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.saveBirthdateAction), findsNothing);
    await tester.tap(find.text(l10n.deleteSavedBirthdate));
    await tester.pumpAndSettle();

    expect(deps.profile.saved, isNull);
    expect(await BirthdateStorage().read(), isNull);
    expect(find.text(l10n.birthdateDeleted), findsOneWidget);
  });

  testWidgets('menu: sem data salva oferece salvar e escolher outra data, mas não apagar', (tester) async {
    await openSummary(tester);
    await tester.tap(find.byKey(const Key('summary_menu')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.saveBirthdateAction), findsOneWidget);
    expect(find.text(l10n.chooseAnotherDate), findsOneWidget);
    expect(find.text(l10n.deleteSavedBirthdate), findsNothing);
  });
}
