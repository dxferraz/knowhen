import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';
import 'package:knowhen/features/brazil_curiosity/data/dtos/brazil_curiosity_dto.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_bloc.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

class FakeFacts extends Fake implements HistoricalFactsRepositoryImpl {
  @override
  Future<BrazilCuriosityDTO> getBrazilCuriosity(DateTime birthDate) async =>
      BrazilCuriosityDTO(
        fact: 'Um fato. Outro fato.',
        imageUrl: '',
        month: '${birthDate.month}',
        year: '${birthDate.year}',
      );

  @override
  Future<String> getCuriosityImage(String year, String month) async =>
      'https://example.com/$year/$month.png';
}

class FakeBirthSongs implements BirthSongRepository {
  FakeBirthSongs({this.song, this.error});

  final BirthSongEntity? song;
  final Object? error;
  final List<DateTime> requested = [];

  @override
  Future<BirthSongEntity?> getBirthSong(DateTime birthDate) async {
    requested.add(birthDate);
    if (error != null) throw error!;
    return song;
  }
}

void main() {
  final birthDate = DateTime(1995, 3, 14);
  const song = BirthSongEntity(
    artist: 'Tom Jobim',
    songName: 'Garota de Ipanema',
    month: '3',
    year: '1995',
  );

  Future<SummaryState> loadSummary(FakeBirthSongs songs) async {
    final bloc = SummaryBloc(FakeFacts(), songs);
    final states = bloc.stream.take(2).toList();
    bloc.add(GetSummary(birthDate: birthDate));
    final emitted = await states;
    await bloc.close();
    return emitted.last;
  }

  test('com música para o mês, o resumo carrega com ela', () async {
    final songs = FakeBirthSongs(song: song);
    final state = await loadSummary(songs) as SummaryLoaded;

    expect(state.birthSong, song);
    expect(songs.requested, [birthDate]);
  });

  test(
    'sem música para o mês, o resumo carrega sem a seção (birthSong nulo)',
    () async {
      final state = await loadSummary(FakeBirthSongs()) as SummaryLoaded;

      expect(state.birthSong, isNull);
      expect(state.brazilCuriosity.fact, 'Um fato. Outro fato.');
    },
  );

  test('erro ao buscar a música não derruba o resumo', () async {
    final state = await loadSummary(
      FakeBirthSongs(error: Exception('permission-denied')),
    );

    expect(state, isA<SummaryLoaded>());
    expect((state as SummaryLoaded).birthSong, isNull);
  });
}
