import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/life_profile_service.dart';
import 'package:knowhen/core/services/notification_router.dart';
import 'package:knowhen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/milestone_fakes.dart';

void main() {
  late FakeMilestoneNotifier notifier;
  late FakeMilestoneAnalytics analytics;
  late LifeProfileService profile;
  late NotificationRouter router;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BirthdateStorage().write(SavedBirthdate(DateTime(1990, 5, 15)));
    notifier = FakeMilestoneNotifier();
    analytics = FakeMilestoneAnalytics();
    profile = LifeProfileService(
      storage: BirthdateStorage(),
      notifier: notifier,
      analytics: analytics,
      l10n: lookupAppLocalizations(const Locale('pt')),
    );
    router = NotificationRouter(navigatorKey: GlobalKey<NavigatorState>(), profile: profile, analytics: analytics);
  });

  Future<bool> start() => startLifeProfile(notifier: notifier, profile: profile, router: router);

  test('carrega a data salva e retorna false quando o app não veio de notificação', () async {
    expect(await start(), isFalse);
    expect(profile.saved?.date, DateTime(1990, 5, 15));
  });

  test('aberto por notificação de marco, retorna true e registra o evento', () async {
    notifier.launch = 'milestone:days10000';

    expect(await start(), isTrue);
    expect(analytics.events, ['milestone_notification_opened:days10000']);
  });

  test('falha na inicialização do plugin não impede de carregar a data salva', () async {
    notifier.initializeError = Exception('plugin indisponível');

    expect(await start(), isFalse);
    expect(profile.saved?.date, DateTime(1990, 5, 15));
  });

  test('falha ao ler a notificação de abertura não impede de carregar a data salva', () async {
    notifier.launchError = Exception('sem payload');

    expect(await start(), isFalse);
    expect(profile.saved?.date, DateTime(1990, 5, 15));
  });
}
