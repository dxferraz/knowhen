import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

import '../../helpers/fakes.dart';

void main() {
  final birthDate = DateTime(1990, 5, 20);

  Future<SummaryLoaded> loadSummary(FakeBirthSongRepository songs) async {
    final bloc = SummaryBloc(FakeBrazilCuriositiesRepository(), songs);
    final states = bloc.stream.take(2).toList();
    bloc.add(GetSummary(birthDate: birthDate));
    final emitted = await states;
    await bloc.close();
    return emitted.last as SummaryLoaded;
  }

  test('com música para o mês, o resumo carrega com ela', () async {
    final songs = FakeBirthSongRepository(song: sampleBirthSong);
    final state = await loadSummary(songs);

    expect(state.birthSong, sampleBirthSong);
    expect(songs.requestedDates, [birthDate]);
  });

  test('sem música para o mês, o resumo carrega sem a seção (birthSong nulo)', () async {
    final state = await loadSummary(FakeBirthSongRepository());

    expect(state.birthSong, isNull);
    expect(state.brazilCuriosity?.fact, 'Um fato curioso de 5/1990');
  });

  test('erro ao buscar a música não derruba o resumo', () async {
    final state = await loadSummary(FakeBirthSongRepository(error: Exception('permission-denied')));

    expect(state.birthSong, isNull);
    expect(state.brazilCuriosity, isNotNull);
  });
}
