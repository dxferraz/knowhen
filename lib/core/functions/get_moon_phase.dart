import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MoonPhase extends Equatable {
  final String phaseName;
  final String imageUrl;
  final String description;
  final String influence;

  const MoonPhase({
    required this.phaseName,
    required this.imageUrl,
    required this.description,
    required this.influence,
  });

  @override
  List<Object?> get props => [phaseName, imageUrl, description, influence];
}

MoonPhase getMoonPhase(DateTime date) {
  debugPrint('Calculating moon phase for date: $date');
  int year = date.year;
  int month = date.month;
  int day = date.day;

  int r = year % 100;
  r = r % 19;

  if (r > 9) r -= 19;

  int phase = ((r * 11) % 30) + month + day;

  if (month < 3) phase += 2;

  bool isLeapYear = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  if (isLeapYear && month > 2) phase += 1;

  phase = phase % 30;
  if (phase < 0) phase += 30;

  String phaseName = '';
  String description = '';
  String imageUrl = '';
  String influence = '';

  if (phase < 10) {
    phaseName = 'Lua nova';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fnew-moon.jpg?alt=media&token=52d6c354-b02b-4b3b-beb2-6e6967eade0d';
    description = 'A Lua está invisível no céu, marcando o início de um novo ciclo.';
    influence =
        'Pessoas nascidas sob a Lua Nova costumam ser visionárias, cheias de ideias e energia para começar do zero. Tendem a buscar novos caminhos e gostam de recomeços, mesmo em situações difíceis.';
  } else if (phase < 19) {
    phaseName = 'Lua crescente';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaxing-crescent.jpg?alt=media&token=ded511df-63b5-466d-a261-a10f88362e83';
    description = 'A Lua começa a ganhar luz, simbolizando crescimento e construção.';
    influence =
        'Nascidos nessa fase têm perfil determinado e progressivo. São pessoas que aprendem com o tempo, gostam de desafios e têm sede de evolução. Costumam ser persistentes e confiantes no que querem conquistar.';
  } else if (phase < 27) {
    phaseName = 'Lua quarto crescente';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Ffirst-quarter.jpg?alt=media&token=c76dee1d-05af-4b99-bbf4-18c4b6700275';
    description = 'Metade da Lua está iluminada e visível. O ciclo está ganhando força.';
    influence =
        'Pessoas do Quarto Crescente têm espírito de ação. São decididas, práticas e focadas em realizar. Lidam bem com pressões e sabem transformar ideias em realidade.';
  } else if (phase < 30) {
    phaseName = 'Lua gibosa crescente';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaxing-gibbous.jpg?alt=media&token=98f07b45-27f8-437c-8938-d844e84604a1';
    description = 'Mais de metade da Lua está iluminada, aproximando-se da Lua Cheia.';
    influence =
        'Nascidos sob essa fase são visionários e idealistas. Buscam aprimoramento constante e querem deixar sua marca no mundo. São guiados por propósito e aperfeiçoamento.';
  } else if (phase < 37) {
    phaseName = 'Lua cheia';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Ffull.webp?alt=media&token=370f0f03-b613-4f16-9513-8adc8227526d';
    description = 'A Lua está totalmente visível e oposta ao Sol. É o auge do ciclo lunar.';
    influence =
        'Intensos, carismáticos e sensíveis — pessoas de Lua Cheia sentem tudo profundamente. São expressivas, envolventes e têm grande energia emocional e magnética.';
  } else if (phase < 46) {
    phaseName = 'Lua gibosa minguante';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaning-gibbous.webp?alt=media&token=c934a06a-005d-4729-bc5c-d6cda5cd0a9a';
    description = 'A Lua começa a perder luz, logo após a Lua Cheia.';
    influence =
        'Pessoas dessa fase tendem a ser analíticas e sábias. Gostam de refletir, entender o porquê das coisas e aprender com a experiência. Buscam sentido em tudo o que fazem.';
  } else if (phase < 54) {
    phaseName = 'Lua quarto minguante';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fthird-quarter.webp?alt=media&token=4e04cc7b-29b7-42ba-af5c-90c694551ccb';
    description =
        'Metade da Lua ainda está visível, mas está minguando. O ciclo se aproxima do fim.';
    influence =
        'Nascidos nessa fase são desapegados, introspectivos e bons em encerrar ciclos. Costumam ser calmos, observadores e têm uma maturidade emocional profunda.';
  } else {
    phaseName = 'Lua minguante';
    imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/moon-phases%2Fwaning-crescent.webp?alt=media&token=54a527ee-80d8-4479-81bc-8e1b5e7c195e';
    description = 'Apenas uma pequena parte da Lua ainda está iluminada antes da fase nova.';
    influence =
        'Pessoas de Lua Minguante são intuitivas, espirituais e ligadas ao invisível. Têm sabedoria interior, são reservadas e vivem bem no silêncio e na contemplação.';
  }

  return MoonPhase(
    phaseName: phaseName,
    description: description,
    imageUrl: imageUrl,
    influence: influence,
  );
}
