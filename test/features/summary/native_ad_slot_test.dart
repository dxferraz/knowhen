import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/features/summary/presentation/widgets/native_ad_slot.dart';

import '../../helpers/contrast.dart';
import '../../helpers/fakes.dart';
import '../../helpers/load_app_fonts.dart';
import '../../helpers/pump_app.dart';

Future<void> _pump(WidgetTester tester, {Brightness brightness = Brightness.light, double scale = 1, FakeNativeAd? ad}) {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    TestDependencies().wrap(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.dark ? darkTheme : lightTheme,
        themeAnimationDuration: Duration.zero,
        builder: (context, app) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: app!),
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(24), child: NativeAdSlot(ad: ad ?? FakeNativeAd()))),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('mostra o rótulo "Anúncio" acima do anúncio, separado dele', (tester) async {
    await _pump(tester);

    final label = find.text(l10n.adLabel);
    final view = find.byKey(const Key('fake_native_ad_view'));
    expect(label, findsOneWidget);
    expect(view, findsOneWidget);
    expect(tester.getBottomLeft(label).dy, lessThanOrEqualTo(tester.getTopLeft(view).dy));
    expect(tester.getSize(view).height, NativeAdSlot.adHeight);
  });

  for (final scale in [1.0, 2.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('${(scale * 100).round()}% de fonte, tema ${brightness.name}: sem overflow e rótulo legível (contraste AA)', (tester) async {
        await _pump(tester, brightness: brightness, scale: scale);

        expect(tester.takeException(), isNull);
        final c = tester.element(find.byType(Scaffold)).kn;
        final label = tester.widget<Text>(find.text(l10n.adLabel));
        expect(label.style!.color, c.inkMuted);
        expect(contrastRatio(c.inkMuted, c.bg), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('o visual do anúncio usa as cores do tema (fundo, texto e botão)', () {
    for (final c in [KnColors.dawn, KnColors.night]) {
      final style = nativeAdStyle(c);

      expect(style.templateType, TemplateType.small);
      expect(style.mainBackgroundColor, c.surface);
      expect(style.primaryTextStyle!.textColor, c.ink);
      expect(style.secondaryTextStyle!.textColor, c.inkMuted);
      expect(style.callToActionTextStyle!.textColor, c.onPrimary);
      expect(style.callToActionTextStyle!.backgroundColor, c.primary);
    }
  });
}
