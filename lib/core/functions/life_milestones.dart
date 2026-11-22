/// Marcos de vida (1.000 semanas, 10.000 dias, 1 bilhão de segundos...) e aniversários.
///
/// As datas são de calendário (só ano/mês/dia, no fuso do aparelho). Meses e anos seguem a mesma
/// regra de `calculate_age.dart`: se o mês não tem o dia de nascimento (31/01, 29/02), o marco
/// cai no dia 1º do mês seguinte.
library;

enum MilestoneKind {
  weeks1000,
  days10000,
  seconds1Billion,
  months500,
  days15000,
  days20000,
  birthday,
}

class LifeMilestone {
  const LifeMilestone({required this.kind, required this.date, this.age});

  final MilestoneKind kind;

  /// Dia do marco (meia-noite local).
  final DateTime date;

  /// Idade completada no dia, só para [MilestoneKind.birthday].
  final int? age;

  /// Identificador estável da notificação: o mesmo marco sempre agenda no mesmo id.
  int get notificationId => kind == MilestoneKind.birthday ? 100 + age! : kind.index;

  /// Dias de hoje até o marco (0 = hoje). Contados em UTC para não sofrer com horário de verão.
  int daysUntil(DateTime now) => DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(now.year, now.month, now.day)).inDays;

  @override
  bool operator ==(Object other) => other is LifeMilestone && other.kind == kind && other.date == date && other.age == age;

  @override
  int get hashCode => Object.hash(kind, date, age);

  @override
  String toString() => 'LifeMilestone($kind, $date${age == null ? '' : ', age: $age'})';
}

/// [date] mais [months] meses, pela regra do calendário descrita no topo do arquivo.
DateTime addMonthsToDate(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return date.day <= daysInMonth ? DateTime(year, month, date.day) : DateTime(year, month + 1, 1);
}

/// Dia do aniversário de [age] anos.
DateTime birthdayDate(DateTime birthDate, int age) => addMonthsToDate(DateTime(birthDate.year, birthDate.month, birthDate.day), age * 12);

/// Os marcos de vida em ordem cronológica, do primeiro (7.000 dias de vida) ao último fixo.
/// Com [birthTime] o marco de 1 bilhão de segundos usa o instante exato do nascimento.
List<LifeMilestone> fixedMilestones(DateTime birthDate, {({int hour, int minute})? birthTime}) {
  final birthDay = DateTime(birthDate.year, birthDate.month, birthDate.day);
  DateTime afterDays(int days) => DateTime(birthDay.year, birthDay.month, birthDay.day + days);

  final birthInstant = DateTime(birthDay.year, birthDay.month, birthDay.day, birthTime?.hour ?? 0, birthTime?.minute ?? 0);
  final billion = birthInstant.add(const Duration(seconds: 1000000000));

  final milestones = [
    LifeMilestone(kind: MilestoneKind.weeks1000, date: afterDays(1000 * 7)),
    LifeMilestone(kind: MilestoneKind.days10000, date: afterDays(10000)),
    LifeMilestone(kind: MilestoneKind.seconds1Billion, date: DateTime(billion.year, billion.month, billion.day)),
    LifeMilestone(kind: MilestoneKind.months500, date: addMonthsToDate(birthDay, 500)),
    LifeMilestone(kind: MilestoneKind.days15000, date: afterDays(15000)),
    LifeMilestone(kind: MilestoneKind.days20000, date: afterDays(20000)),
  ];
  milestones.sort((a, b) => a.date.compareTo(b.date));
  return milestones;
}

/// Marcos a partir de hoje (inclusive), em ordem cronológica: os fixos que ainda não passaram e os
/// próximos [birthdays] aniversários.
List<LifeMilestone> upcomingMilestones(
  DateTime birthDate,
  DateTime now, {
  ({int hour, int minute})? birthTime,
  int birthdays = 1,
}) {
  final today = DateTime(now.year, now.month, now.day);

  var nextAge = 1;
  while (birthdayDate(birthDate, nextAge).isBefore(today)) {
    nextAge++;
  }

  final milestones = <LifeMilestone>[
    ...fixedMilestones(birthDate, birthTime: birthTime).where((m) => !m.date.isBefore(today)),
    for (var i = 0; i < birthdays; i++) LifeMilestone(kind: MilestoneKind.birthday, date: birthdayDate(birthDate, nextAge + i), age: nextAge + i),
  ];
  milestones.sort((a, b) => a.date.compareTo(b.date));
  return milestones;
}

/// O marco mais próximo de [now] (hoje conta). Sempre existe: no mínimo o próximo aniversário.
LifeMilestone nextMilestone(DateTime birthDate, DateTime now, {({int hour, int minute})? birthTime}) =>
    upcomingMilestones(birthDate, now, birthTime: birthTime).first;
