import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/birthdate_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sem nada salvo devolve null', () async {
    expect(await BirthdateStorage().read(), isNull);
    expect(await BirthdateStorage().readRemindersEnabled(), isFalse);
  });

  test('salva e lê a data e a hora de nascimento', () async {
    final storage = BirthdateStorage();
    await storage.write(SavedBirthdate(DateTime(1990, 5, 15), time: const TimeOfDay(hour: 7, minute: 5)));

    final saved = await BirthdateStorage().read();
    expect(saved?.date, DateTime(1990, 5, 15));
    expect(saved?.time, const TimeOfDay(hour: 7, minute: 5));
  });

  test('regravar sem hora remove a hora antiga', () async {
    final storage = BirthdateStorage();
    await storage.write(SavedBirthdate(DateTime(1990, 5, 15), time: const TimeOfDay(hour: 7, minute: 5)));
    await storage.write(SavedBirthdate(DateTime(1991, 1, 2)));

    final saved = await storage.read();
    expect(saved?.date, DateTime(1991, 1, 2));
    expect(saved?.time, isNull);
  });

  test('clear apaga data, hora e preferência de lembretes', () async {
    final storage = BirthdateStorage();
    await storage.write(SavedBirthdate(DateTime(1990, 5, 15), time: const TimeOfDay(hour: 7, minute: 5)));
    await storage.writeRemindersEnabled(true);

    await storage.clear();

    expect(await storage.read(), isNull);
    expect(await storage.readRemindersEnabled(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  test('só guarda strings e bool simples no aparelho (nenhuma outra chave)', () async {
    final storage = BirthdateStorage();
    await storage.write(SavedBirthdate(DateTime(1990, 5, 15), time: const TimeOfDay(hour: 7, minute: 5)));
    await storage.writeRemindersEnabled(true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {BirthdateStorage.dateKey, BirthdateStorage.timeKey, BirthdateStorage.remindersKey});
    expect(prefs.getString(BirthdateStorage.dateKey), '1990-05-15');
    expect(prefs.getString(BirthdateStorage.timeKey), '07:05');
  });

  test('valor corrompido vira "sem data salva" em vez de quebrar', () async {
    for (final bad in ['lixo', '1990-13-40', '1990-02-30', '']) {
      SharedPreferences.setMockInitialValues({BirthdateStorage.dateKey: bad});
      expect(await BirthdateStorage().read(), isNull, reason: bad);
    }
  });

  test('hora corrompida é ignorada mas a data continua valendo', () async {
    SharedPreferences.setMockInitialValues({BirthdateStorage.dateKey: '1990-05-15', BirthdateStorage.timeKey: '99:99'});
    final saved = await BirthdateStorage().read();
    expect(saved?.date, DateTime(1990, 5, 15));
    expect(saved?.time, isNull);
  });
}
