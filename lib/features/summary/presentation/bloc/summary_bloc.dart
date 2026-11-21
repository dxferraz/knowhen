import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';

class SummaryBloc extends Bloc<SummaryEvents, SummaryState> {
  final HistoricalFactsRepositoryImpl historicalFactsRepository;
  final BirthSongRepository birthSongRepository;

  SummaryBloc(this.historicalFactsRepository, this.birthSongRepository)
    : super(SummaryInitial()) {
    on<GetSummary>((event, emit) async {
      emit(SummaryLoading());
      try {
        final moonPhase = getMoonPhase(event.birthDate);
        final brazilCuriosity = await historicalFactsRepository
            .getBrazilCuriosity(event.birthDate);
        final curiosityImage = await historicalFactsRepository
            .getCuriosityImage(
              event.birthDate.year.toString(),
              event.birthDate.month.toString(),
            );
        final birthSong = await _getBirthSong(event.birthDate);
        emit(
          SummaryLoaded(
            moonPhase: moonPhase,
            brazilCuriosity: brazilCuriosity.toEntity(),
            curiosityImage: curiosityImage,
            birthSong: birthSong,
          ),
        );
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });
  }

  /// The song is optional: any failure just hides its section instead of
  /// breaking the whole summary.
  Future<BirthSongEntity?> _getBirthSong(DateTime birthDate) async {
    try {
      return await birthSongRepository.getBirthSong(birthDate);
    } catch (e) {
      debugPrint('Could not load birth song: $e');
      return null;
    }
  }
}
