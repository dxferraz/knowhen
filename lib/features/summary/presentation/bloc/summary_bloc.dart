import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';
import 'package:knowhen/features/brazil_curiosity/domain/entities/brazil_curiosity_entity.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

typedef _CuriosityResult = ({BrazilCuriosityEntity? curiosity, String image, bool failed});

class SummaryBloc extends Bloc<SummaryEvents, SummaryState> {
  final BrazilCuriositiesRepository historicalFactsRepository;
  final BirthSongRepository birthSongRepository;

  /// Quanto esperar cada chamada remota antes de seguir sem ela, para a revelação nunca ficar presa na rede.
  final Duration remoteTimeout;

  SummaryBloc(this.historicalFactsRepository, this.birthSongRepository, {this.remoteTimeout = const Duration(seconds: 10)})
    : super(SummaryInitial()) {
    on<GetSummary>((event, emit) async {
      emit(SummaryLoading());
      // O que é local (lua, tempo de vida) fica pronto na hora; só o fato e a música dependem da rede.
      final moonPhase = getMoonPhase(event.birthDate);

      final birthSongFuture = _getBirthSong(event.birthDate);
      final curiosity = await _loadCuriosity(event.birthDate);
      final birthSong = await birthSongFuture;

      emit(
        SummaryLoaded(
          moonPhase: moonPhase,
          brazilCuriosity: curiosity.curiosity,
          brazilCuriosityFailed: curiosity.failed,
          curiosityImage: curiosity.image,
          birthSong: birthSong,
        ),
      );
    });

    on<RetryBrazilCuriosity>((event, emit) async {
      final current = state;
      if (current is! SummaryLoaded || current.brazilCuriosityRetrying) return;

      emit(current.withRetrying());
      final curiosity = await _loadCuriosity(event.birthDate);
      emit(
        SummaryLoaded(
          moonPhase: current.moonPhase,
          brazilCuriosity: curiosity.curiosity,
          brazilCuriosityFailed: curiosity.failed,
          curiosityImage: curiosity.image,
          birthSong: current.birthSong,
        ),
      );
    });
  }

  /// A curiosidade vem do Firestore/fal.ai e pode faltar ou falhar sem derrubar as outras seções.
  Future<_CuriosityResult> _loadCuriosity(DateTime birthDate) async {
    BrazilCuriosityEntity? curiosity;
    try {
      final dto = await historicalFactsRepository.getBrazilCuriosity(birthDate).timeout(remoteTimeout);
      curiosity = dto?.toEntity();
    } catch (e) {
      debugPrint('Error loading Brazil curiosity: $e');
      return (curiosity: null, image: '', failed: true);
    }

    var image = '';
    if (curiosity != null) {
      try {
        image = await historicalFactsRepository.getCuriosityImage(birthDate.year.toString(), birthDate.month.toString()).timeout(remoteTimeout);
      } catch (e) {
        debugPrint('Error loading curiosity image: $e');
      }
    }
    return (curiosity: curiosity, image: image, failed: false);
  }

  /// A música é opcional: qualquer falha só esconde a seção, sem derrubar o resumo.
  Future<BirthSongEntity?> _getBirthSong(DateTime birthDate) async {
    try {
      return await birthSongRepository.getBirthSong(birthDate).timeout(remoteTimeout);
    } catch (e) {
      debugPrint('Could not load birth song: $e');
      return null;
    }
  }
}
