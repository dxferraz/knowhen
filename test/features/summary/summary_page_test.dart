import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/services/ad_service.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/features/birth_song/presentation/widgets/birth_song_section.dart';
import 'package:knowhen/features/brazil_curiosity/presentation/widgets/brazil_curiosity_section.dart';
import 'package:knowhen/features/conception/presentation/widgets/conception_section.dart';
import 'package:knowhen/features/moon_phase/presentation/widgets/moon_phase_section.dart';
import 'package:knowhen/features/summary/presentation/pages/summary_page.dart';
import 'package:knowhen/features/summary/presentation/widgets/summary_reveal.dart';
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
    expect(find.byType(SummaryReveal), findsOneWidget);
    expect(find.byType(YearsOfLifeSection), findsNothing);

    curiosity.complete();
    await tester.pumpAndSettle();

    expect(find.byType(SummaryReveal), findsNothing);
    expect(find.text(DateText.compact(birthDate)), findsOneWidget);
    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    final adService = deps.adService as FakeAdService;
    expect(adService.loadCalls, 1);
    expect(adService.showCalls, 1);
    expect(deps.firebaseAnalytics.names, ['summary_viewed', 'summary_section_viewed']);
    expect(deps.firebaseAnalytics.events.last.parameters, {'section_name': 'years_of_life', 'section_index': 0});
  });

  testWidgets('shows the birth song as the last page and logs birth_song when it is viewed', (tester) async {
    final deps = TestDependencies(birthSongs: FakeBirthSongRepository(song: sampleBirthSong));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.childrenDelegate.estimatedChildCount, 6);

    pageView.controller!.jumpToPage(5);
    await tester.pumpAndSettle();

    expect(find.byType(BirthSongSection), findsOneWidget);
    expect(find.text('Garota de Ipanema'), findsOneWidget);
    expect(deps.firebaseAnalytics.events.last.parameters, {'section_name': 'birth_song', 'section_index': 5});
  });

  testWidgets('without a song for the month the page does not exist', (tester) async {
    final deps = TestDependencies(birthSongs: FakeBirthSongRepository());

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.childrenDelegate.estimatedChildCount, 5);
    expect(find.byType(BirthSongSection), findsNothing);
  });

  testWidgets('keeps the summary when the curiosity fails to load', (tester) async {
    final deps = TestDependencies(repository: FakeBrazilCuriositiesRepository(curiosityError: StateError('No element')));

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();

    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    expect(find.textContaining('No element'), findsNothing);
  });

  testWidgets('opening the summary twice reuses the app-wide ad instead of loading or leaking another', (tester) async {
    final loader = FakeAdLoader();
    final firebaseAnalytics = FakeFirebaseAnalytics();
    final adService = AdService(AnalyticsService(firebaseAnalytics), loader: loader.call);
    final deps = TestDependencies(adService: adService);
    final ad = FakeInterstitialAd();
    // showAd() toggles the system UI mode; answer it so the call completes under the fake clock.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    // First visit: the load starts and the ad is shown once it arrives.
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(loader.requests, hasLength(1));
    loader.requests.single.onAdLoaded(ad);
    await tester.idle();
    await tester.pumpAndSettle(); // runs the post-frame callback that shows the ad
    await tester.idle();
    expect(ad.showCalls, 1);

    // The user dismisses the ad, which preloads the next one, and leaves the summary.
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    await tester.pump();
    expect(loader.requests, hasLength(2));
    await tester.pumpWidget(const SizedBox());

    // Second visit while that preload is still in flight: no third request, no overwrite.
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pump();
    expect(loader.requests, hasLength(2));

    final next = FakeInterstitialAd();
    loader.requests.last.onAdLoaded(next);
    await tester.idle();
    await tester.pumpAndSettle(); // runs the post-frame callback that shows the ad
    await tester.idle();
    expect(next.showCalls, 1);
    expect(next.disposeCalls, 0);
    expect(ad.disposeCalls, 1);
    expect(ad.showCalls, 1);
  });

  group('share button on every page of the PageView', () {
    // The button next to the arrow only exists on pages that have a card to share.
    final shareButton = find.byTooltip(l10n.summaryShareCard);
    final adultBirthDate = DateTime(1990, 5, 20);
    final minorBirthDate = DateTime.now().subtract(const Duration(days: 365 * 10));

    // The offer to save the date sits over the bottom buttons until it is dismissed.
    Future<void> openSummary(WidgetTester tester, DateTime birth, TestDependencies deps) async {
      await tester.pumpApp(SummaryPage(birthDate: birth), deps);
      await tester.pumpAndSettle();
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).hideCurrentSnackBar();
      await tester.pumpAndSettle();
    }

    Future<List<bool>> pageThroughSummary(WidgetTester tester, DateTime birth, FakeBrazilCuriositiesRepository repository, int pageCount) async {
      await openSummary(tester, birth, TestDependencies(repository: repository));
      final hasShareButton = <bool>[];
      for (var page = 0; page < pageCount; page++) {
        hasShareButton.add(shareButton.evaluate().isNotEmpty);
        if (page < pageCount - 1) {
          await tester.tap(find.text(l10n.next));
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
      return hasShareButton;
    }

    testWidgets('adult with curiosity: every page but the milestone offers a card', (tester) async {
      final hasShareButton = await pageThroughSummary(tester, adultBirthDate, FakeBrazilCuriositiesRepository(), 5);

      expect(hasShareButton, [true, false, true, true, true]);
      expect(find.byType(BrazilCuriositySection), findsOneWidget);
    });

    testWidgets('adult without curiosity: the last page has no card', (tester) async {
      final hasShareButton = await pageThroughSummary(tester, adultBirthDate, FakeBrazilCuriositiesRepository(hasCuriosity: false), 5);

      expect(hasShareButton, [true, false, true, true, false]);
    });

    testWidgets('minor: the conception card is not part of the sequence', (tester) async {
      final hasShareButton = await pageThroughSummary(tester, minorBirthDate, FakeBrazilCuriositiesRepository(), 4);

      expect(hasShareButton, [true, false, true, true]);
      expect(find.byType(ConceptionSection), findsNothing);
    });

    testWidgets('tapping share opens the card preview of the current page', (tester) async {
      await openSummary(tester, adultBirthDate, TestDependencies());
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text(l10n.next));
        await tester.pumpAndSettle();
      }
      expect(find.byType(MoonPhaseSection), findsOneWidget);

      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      expect(find.text(l10n.shareSheetTitle), findsOneWidget);
    });
  });

  testWidgets('falha só na parte remota: o resumo abre e "Tentar de novo" busca o fato sem refazer o resto', (tester) async {
    final repository = FakeBrazilCuriositiesRepository(failFirstCuriosity: true);
    final deps = TestDependencies(repository: repository);

    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();
    expect(find.byType(YearsOfLifeSection), findsOneWidget);
    expect(find.textContaining('sem rede'), findsNothing);

    for (var i = 0; i < 4; i++) {
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).hideCurrentSnackBar();
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();
    }
    expect(find.text(l10n.historicalFactLoadError), findsOneWidget);

    await tester.tap(find.text(l10n.factRetry));
    await tester.pumpAndSettle();

    expect(find.text(l10n.historicalFactLoadError), findsNothing);
    expect(find.textContaining('Um fato curioso'), findsWidgets);
    expect(repository.requestedDates, hasLength(2));
    expect(deps.firebaseAnalytics.names.where((n) => n == 'summary_viewed'), hasLength(1));
  });

  testWidgets('"Escolher outra data" no último cartão volta para a data e esconde o convite de salvar', (tester) async {
    final deps = TestDependencies(birthSongs: FakeBirthSongRepository());
    await tester.pumpApp(SummaryPage(birthDate: birthDate), deps);
    await tester.pumpAndSettle();
    expect(find.text(l10n.saveBirthdateOffer), findsOneWidget);

    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(4);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.chooseAnotherDate));
    await tester.pumpAndSettle();

    expect(find.byType(SummaryPage), findsNothing);
    expect(find.text(l10n.saveBirthdateOffer), findsNothing);
  });
}
