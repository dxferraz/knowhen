/// Cálculos de idade por calendário (não por aproximação de 365/30 dias).
///
/// Só a data (ano/mês/dia) é considerada; o horário de [birthDate] e [now] é ignorado.
/// Um mês/ano se completa no dia de mesmo número; se o mês não tiver esse dia
/// (ex.: nascido em 31/01 ou 29/02), completa no dia seguinte (01/03),
/// como no art. 132, § 3º do Código Civil.
library;

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
