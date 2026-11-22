import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedBirthdate {
  const SavedBirthdate(this.date, {this.time});

  final DateTime date;
  final TimeOfDay? time;

  @override
  bool operator ==(Object other) => other is SavedBirthdate && other.date == date && other.time == time;

  @override
  int get hashCode => Object.hash(date, time);
}

/// Guarda a data de nascimento só neste aparelho (SharedPreferences). Nada daqui vai para o backend.
class BirthdateStorage {
  static const dateKey = 'saved_birthdate';
  static const timeKey = 'saved_birth_time';
  static const remindersKey = 'milestone_reminders_enabled';

  Future<SavedBirthdate?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final date = _parseDate(prefs.getString(dateKey));
    if (date == null) return null;
    return SavedBirthdate(date, time: _parseTime(prefs.getString(timeKey)));
  }

  Future<void> write(SavedBirthdate birthdate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dateKey, _formatDate(birthdate.date));
    final time = birthdate.time;
    if (time == null) {
      await prefs.remove(timeKey);
    } else {
      await prefs.setString(timeKey, _formatTime(time));
    }
  }

  /// Apaga a data, a hora e a preferência de lembretes.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dateKey);
    await prefs.remove(timeKey);
    await prefs.remove(remindersKey);
  }

  Future<bool> readRemindersEnabled() async => (await SharedPreferences.getInstance()).getBool(remindersKey) ?? false;

  Future<void> writeRemindersEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool(remindersKey, enabled);

  static String _formatDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  /// Dados corrompidos viram "sem data salva" em vez de derrubar o app na abertura.
  static DateTime? _parseDate(String? value) {
    final match = value == null ? null : RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match[1]!), month = int.parse(match[2]!), day = int.parse(match[3]!);
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day ? date : null;
  }

  static TimeOfDay? _parseTime(String? value) {
    final match = value == null ? null : RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match[1]!), minute = int.parse(match[2]!);
    return hour < 24 && minute < 60 ? TimeOfDay(hour: hour, minute: minute) : null;
  }
}
