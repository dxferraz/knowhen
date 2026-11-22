import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/services/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/milestone_fakes.dart';

void main() {
  final birth = DateTime(1990, 5, 15);
  late FakeMilestoneAnalytics analytics;
  late LifeProfileService profile;
  late GlobalKey<NavigatorState> navigatorKey;
  late List<bool> opened;

  NotificationRouter buildRouter() => NotificationRouter(
    navigatorKey: navigatorKey,
    profile: profile,
    analytics: analytics,
    summaryBuilder: (saved, {required openMilestone}) {
      opened.add(openMilestone);
      return Scaffold(
        body: Text('resumo ${saved.date.year} milestone=$openMilestone'),
      );
    },
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    analytics = FakeMilestoneAnalytics();
    navigatorKey = GlobalKey<NavigatorState>();
    opened = [];
    profile = LifeProfileService(
      storage: BirthdateStorage(),
      notifier: FakeMilestoneNotifier(),
      analytics: analytics,
      l10n: lookupAppLocalizations(const Locale('pt')),
    );
  });

  group('app fechado (handleLaunch)', () {
    test(
      'payload de marco com data salva: registra o evento e pede para abrir no card',
      () async {
        await profile.save(birth, null);
        analytics.events.clear();

        expect(buildRouter().handleLaunch('milestone:days10000'), isTrue);
        expect(analytics.events, ['milestone_notification_opened:days10000']);
      },
    );

    test('sem payload (abertura normal) não registra nada', () async {
      await profile.save(birth, null);
      analytics.events.clear();

      expect(buildRouter().handleLaunch(null), isFalse);
      expect(analytics.events, isEmpty);
    });

    test('sem data salva não abre o resumo, mas o evento é registrado', () {
      expect(buildRouter().handleLaunch('milestone:birthday'), isFalse);
      expect(analytics.events, ['milestone_notification_opened:birthday']);
    });
  });

  group('app aberto (open)', () {
    testWidgets('toque na notificação leva ao resumo no card do marco', (
      tester,
    ) async {
      await tester.runAsync(() => profile.save(birth, null));
      analytics.events.clear();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('inicio')),
        ),
      );

      buildRouter().open('milestone:weeks1000');
      await tester.pumpAndSettle();

      expect(find.text('resumo 1990 milestone=true'), findsOneWidget);
      expect(find.text('inicio'), findsNothing);
      expect(analytics.events, ['milestone_notification_opened:weeks1000']);
    });

    testWidgets('payload desconhecido não navega', (tester) async {
      await tester.runAsync(() => profile.save(birth, null));
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('inicio')),
        ),
      );

      buildRouter().open('lixo');
      await tester.pumpAndSettle();

      expect(find.text('inicio'), findsOneWidget);
      expect(opened, isEmpty);
    });
  });
}
