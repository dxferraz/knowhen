import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/life_milestones.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:knowhen/core/services/milestone_notifier.dart';

enum RemindersOutcome {
  enabled,

  /// O usuário (ou o sistema) negou a permissão de notificações. Nada foi agendado, o resto do app segue igual.
  permissionDenied,

  /// A permissão foi dada mas o agendamento falhou.
  failed,
}

/// A data de nascimento salva neste aparelho e os lembretes dos marcos de vida.
///
/// Tudo é local: SharedPreferences + notificações locais, sem backend.
class LifeProfileService extends ChangeNotifier {
  LifeProfileService({
    required BirthdateStorage storage,
    required MilestoneNotifier notifier,
    required MilestoneAnalytics analytics,
    required AppLocalizations l10n,
    DateTime Function()? clock,
  })  : _storage = storage,
        _notifier = notifier,
        _analytics = analytics,
        _l10n = l10n,
        _clock = clock ?? DateTime.now;

  final BirthdateStorage _storage;
  final MilestoneNotifier _notifier;
  final MilestoneAnalytics _analytics;
  final AppLocalizations _l10n;
  final DateTime Function() _clock;

  SavedBirthdate? _saved;
  bool _remindersEnabled = false;

  SavedBirthdate? get saved => _saved;
  bool get remindersEnabled => _remindersEnabled;

  /// Lê o que está salvo e reagenda os lembretes (cobre mudança de fuso e marcos novos, como o
  /// próximo aniversário). Chamado na abertura do app.
  Future<void> load() async {
    _saved = await _storage.read();
    _remindersEnabled = _saved != null && await _storage.readRemindersEnabled();
    if (_remindersEnabled) {
      // Se a permissão foi revogada nas configurações do sistema, o lembrete volta a "desativado".
      if (await _safe(_notifier.hasPermission, orElse: false)) {
        await _schedule();
      } else {
        await _disable();
      }
    }
    notifyListeners();
  }

  /// Salva a data neste aparelho. [source] vai para o evento `birthdate_saved`.
  Future<void> save(DateTime date, TimeOfDay? time, {String source = 'manual'}) async {
    final birthdate = SavedBirthdate(DateTime(date.year, date.month, date.day), time: time);
    await _storage.write(birthdate);
    _saved = birthdate;
    _analytics.logBirthdateSaved(source: source);
    if (_remindersEnabled) await _schedule();
    notifyListeners();
  }

  /// Apaga a data salva e todos os lembretes.
  Future<void> clear() async {
    await _storage.clear();
    _saved = null;
    _remindersEnabled = false;
    await _safe(_notifier.cancelAll);
    notifyListeners();
  }

  /// "Me avise": só aqui o sistema pede permissão de notificação. Os lembretes precisam da data
  /// salva (para reagendar depois de reiniciar e para abrir o card ao tocar), então ela é salva junto.
  Future<RemindersOutcome> enableReminders(DateTime birthDate, TimeOfDay? birthTime) async {
    var granted = await _safe(_notifier.hasPermission, orElse: false);
    if (!granted) {
      granted = await _safe(_notifier.requestPermission, orElse: false);
      _analytics.logNotificationPermissionResult(granted: granted);
    }
    if (!granted) return RemindersOutcome.permissionDenied;

    final date = DateTime(birthDate.year, birthDate.month, birthDate.day);
    if (_saved?.date != date || _saved?.time != birthTime) {
      await save(date, birthTime, source: 'reminder');
    }

    final scheduled = await _schedule();
    if (scheduled == null) return RemindersOutcome.failed;

    _remindersEnabled = true;
    await _storage.writeRemindersEnabled(true);
    final next = nextMilestone(date, _clock(), birthTime: birthTimeOf(birthTime));
    _analytics.logMilestoneReminderEnabled(milestone: next.kind.name, scheduled: scheduled);
    notifyListeners();
    return RemindersOutcome.enabled;
  }

  Future<void> disableReminders() async {
    await _disable();
    notifyListeners();
  }

  Future<void> openNotificationSettings() => _safe(_notifier.openSettings);

  Future<void> _disable() async {
    _remindersEnabled = false;
    await _storage.writeRemindersEnabled(false);
    await _safe(_notifier.cancelAll);
  }

  /// Agenda os lembretes do que está salvo. Devolve quantos agendou, ou `null` se o plugin falhou.
  Future<int?> _schedule() async {
    final saved = _saved;
    if (saved == null) return null;
    final reminders = buildReminders(_l10n, saved.date, _clock(), birthTime: birthTimeOf(saved.time));
    try {
      await _notifier.replaceAll(reminders);
      return reminders.length;
    } catch (e) {
      debugPrint('Error scheduling milestone reminders: $e');
      return null;
    }
  }

  /// Falha de plugin/plataforma nunca derruba o fluxo do app.
  Future<T> _safe<T>(Future<T> Function() action, {T? orElse}) async {
    try {
      return await action();
    } catch (e) {
      debugPrint('Notification error: $e');
      return orElse as T;
    }
  }
}

/// Hora de nascimento no formato que `life_milestones.dart` espera.
({int hour, int minute})? birthTimeOf(TimeOfDay? time) => time == null ? null : (hour: time.hour, minute: time.minute);
