import 'package:equatable/equatable.dart';

/// As 8 fases da Lua, na ordem do ciclo a partir da lua nova. Os textos de cada uma ficam no l10n.
enum MoonPhaseType { newMoon, waxingCrescent, firstQuarter, waxingGibbous, fullMoon, waningGibbous, lastQuarter, waningCrescent }

class MoonPhase extends Equatable {
  final MoonPhaseType type;
  final String imageUrl;

  const MoonPhase({required this.type, required this.imageUrl});

  @override
  List<Object?> get props => [type, imageUrl];
}

/// Lua nova de referência (06/01/2000 18:14 UTC) e duração média do mês sinódico, em dias.
final _referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
const _synodicMonth = 29.530588853;

/// Idade da Lua (dias desde a última lua nova, de 0 a ~29,53) no meio-dia de Brasília de [date].
///
/// Só a data (ano/mês/dia) é considerada; o horário de [date] é ignorado.
double getMoonAge(DateTime date) {
  final noonInBrasilia = DateTime.utc(date.year, date.month, date.day, 15);
  final days = noonInBrasilia.difference(_referenceNewMoon).inMinutes / Duration.minutesPerDay;
  return days % _synodicMonth;
}

/// Fração do ciclo lunar em [date], de 0 (lua nova) a 1 (próxima lua nova): 0,5 é a lua cheia. Alimenta o `KnMoon`.
double getMoonPhaseFraction(DateTime date) => getMoonAge(date) / _synodicMonth;

/// Fase da Lua em [date], entre as 8 fases, cada uma cobrindo ~3,69 dias centrados nela.
MoonPhase getMoonPhase(DateTime date) {
  final index = (getMoonAge(date) / _synodicMonth * _moonPhases.length).round() % _moonPhases.length;
  return _moonPhases[index];
}

/// As 8 fases na ordem do ciclo, a partir da lua nova.
const _moonPhases = [
  MoonPhase(
    type: MoonPhaseType.newMoon,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fnew-moon.jpg?alt=media&token=52d6c354-b02b-4b3b-beb2-6e6967eade0d',
  ),
  MoonPhase(
    type: MoonPhaseType.waxingCrescent,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaxing-crescent.jpg?alt=media&token=ded511df-63b5-466d-a261-a10f88362e83',
  ),
  MoonPhase(
    type: MoonPhaseType.firstQuarter,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Ffirst-quarter.jpg?alt=media&token=c76dee1d-05af-4b99-bbf4-18c4b6700275',
  ),
  MoonPhase(
    type: MoonPhaseType.waxingGibbous,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaxing-gibbous.jpg?alt=media&token=98f07b45-27f8-437c-8938-d844e84604a1',
  ),
  MoonPhase(
    type: MoonPhaseType.fullMoon,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Ffull.webp?alt=media&token=370f0f03-b613-4f16-9513-8adc8227526d',
  ),
  MoonPhase(
    type: MoonPhaseType.waningGibbous,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaning-gibbous.webp?alt=media&token=c934a06a-005d-4729-bc5c-d6cda5cd0a9a',
  ),
  MoonPhase(
    type: MoonPhaseType.lastQuarter,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fthird-quarter.webp?alt=media&token=4e04cc7b-29b7-42ba-af5c-90c694551ccb',
  ),
  MoonPhase(
    type: MoonPhaseType.waningCrescent,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaning-crescent.webp?alt=media&token=54a527ee-80d8-4479-81bc-8e1b5e7c195e',
  ),
];
