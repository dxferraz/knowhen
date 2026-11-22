import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

import '../../helpers/fakes.dart';

void main() {
  final birthDate = DateTime(2000, 1, 21);

  Future<SummaryLoaded> loadSummary(FakeBrazilCuriositiesRepository repository) async {
    final bloc = SummaryBloc(repository);
    final states = bloc.stream.take(2).toList();
    bloc.add(GetSummary(birthDate: birthDate));

    final emitted = await states;
    await bloc.close();
    expect(emitted.first, isA<SummaryLoading>());
    expect(emitted.last, isA<SummaryLoaded>());
    return emitted.last as SummaryLoaded;
  }

  test('starts in SummaryInitial', () {
    final bloc = SummaryBloc(FakeBrazilCuriositiesRepository());
    addTearDown(bloc.close);

    expect(bloc.state, isA<SummaryInitial>());
  });

  test('carrega todas as seções quando há curiosidade e imagem', () async {
    final repository = FakeBrazilCuriositiesRepository(imageUrl: 'https://example.com/2000/1.png');
    final state = await loadSummary(repository);

    expect(state.moonPhase, getMoonPhase(birthDate));
    expect(state.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
    expect(state.brazilCuriosity?.year, '2000');
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, 'https://example.com/2000/1.png');
    expect(repository.requestedDates, [birthDate]);
  });

  test('sem curiosidade para o mês/ano o resumo carrega com a seção vazia e não gera imagem', () async {
    final repository = FakeBrazilCuriositiesRepository(hasCuriosity: false);
    final state = await loadSummary(repository);

    expect(state.moonPhase.type, MoonPhaseType.fullMoon);
    expect(state.brazilCuriosity, isNull);
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, isEmpty);
    expect(repository.imageRequests, 0);
  });

  test('erro ao buscar a curiosidade não derruba as outras seções', () async {
    final state = await loadSummary(FakeBrazilCuriositiesRepository(curiosityError: Exception('sem rede')));

    expect(state.moonPhase.type, MoonPhaseType.fullMoon);
    expect(state.brazilCuriosity, isNull);
    expect(state.brazilCuriosityFailed, isTrue);
  });

  test('erro ao gerar a imagem mantém a curiosidade, sem imagem', () async {
    final state = await loadSummary(FakeBrazilCuriositiesRepository(imageError: Exception('fal.ai fora do ar')));

    expect(state.brazilCuriosity?.fact, 'Um fato curioso de 1/2000');
    expect(state.brazilCuriosityFailed, isFalse);
    expect(state.curiosityImage, isEmpty);
  });
}
