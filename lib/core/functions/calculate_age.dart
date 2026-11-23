/// Cálculos de idade por calendário (não por aproximação de 365/30 dias).
///
/// Só a data (ano/mês/dia) é considerada; o horário de [birthDate] e [now] é ignorado.
/// Um mês/ano se completa no dia de mesmo número; se o mês não tiver esse dia
/// (ex.: nascido em 31/01 ou 29/02), completa no dia seguinte (01/03),
/// como no art. 132, § 3º do Código Civil.
library;

import 'package:knowhen/core/functions/life_milestones.dart';

/// Meses completos de vida em [now].
int calculateMonthsOfLife(DateTime birthDate, DateTime now) {
  var months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  if (now.day < birthDate.day) months--;
  return months < 0 ? 0 : months;
}

/// Anos completos de vida (idade) em [now].
int calculateAge(DateTime birthDate, DateTime now) => calculateMonthsOfLife(birthDate, now) ~/ 12;

/// Dias de vida em [now], contados em datas UTC para não sofrer com horário de verão.
int calculateDaysOfLife(DateTime birthDate, DateTime now) {
  final days = DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(birthDate.year, birthDate.month, birthDate.day)).inDays;
  return days < 0 ? 0 : days;
}

/// A seção de concepção (resumo e card de compartilhamento) só aparece para maiores de 18 anos.
bool shouldShowConception(DateTime birthDate, DateTime now) => calculateAge(birthDate, now) > 18;

/// Idade exata em anos, meses e dias completos ("35 anos, 8 meses e 6 dias"), pela mesma regra de calendário.
///
/// Os dias contam desde o último mês completo, então não passam de 30 e nunca ficam negativos.
({int years, int months, int days}) calculateAgeParts(DateTime birthDate, DateTime now) {
  final totalMonths = calculateMonthsOfLife(birthDate, now);
  final lastCompleted = addMonthsToDate(DateTime(birthDate.year, birthDate.month, birthDate.day), totalMonths);
  final days = DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(lastCompleted.year, lastCompleted.month, lastCompleted.day)).inDays;
  return (years: totalMonths ~/ 12, months: totalMonths % 12, days: days < 0 ? 0 : days);
}

/// Dias de hoje até o próximo aniversário (0 = é hoje), pela regra do calendário (29/02 vale 01/03 fora de ano bissexto).
int daysUntilNextBirthday(DateTime birthDate, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var age = calculateAge(birthDate, now);
  var birthday = birthdayDate(birthDate, age);
  while (birthday.isBefore(today)) {
    age++;
    birthday = birthdayDate(birthDate, age);
  }
  return DateTime.utc(birthday.year, birthday.month, birthday.day).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
}
