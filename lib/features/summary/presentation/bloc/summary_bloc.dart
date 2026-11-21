import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/brazil_curiosity/domain/entities/brazil_curiosity_entity.dart';
import 'package:knowhen/features/brazil_curiosity/domain/repositories/brazil_curiosity_repository.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_events.dart';
import 'package:knowhen/features/summary/presentation/bloc/summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvents, SummaryState> {
  final BrazilCuriositiesRepository historicalFactsRepository;

  SummaryBloc(this.historicalFactsRepository) : super(SummaryInitial()) {
    on<GetSummary>((event, emit) async {
      emit(SummaryLoading());
      final moonPhase = getMoonPhase(event.birthDate);

      // A curiosidade vem do Firestore/fal.ai e pode faltar ou falhar sem derrubar as outras seções.
      BrazilCuriosityEntity? brazilCuriosity;
      var brazilCuriosityFailed = false;
      try {
        final brazilCuriosityDto = await historicalFactsRepository.getBrazilCuriosity(event.birthDate);
        brazilCuriosity = brazilCuriosityDto?.toEntity();
      } catch (e) {
        debugPrint('Error loading Brazil curiosity: $e');
        brazilCuriosityFailed = true;
      }

      var curiosityImage = '';
      if (brazilCuriosity != null) {
        try {
          curiosityImage = await historicalFactsRepository.getCuriosityImage(event.birthDate.year.toString(), event.birthDate.month.toString());
        } catch (e) {
          debugPrint('Error loading curiosity image: $e');
        }
      }

      emit(
        SummaryLoaded(
          moonPhase: moonPhase,
          brazilCuriosity: brazilCuriosity,
          brazilCuriosityFailed: brazilCuriosityFailed,
          curiosityImage: curiosityImage,
        ),
      );
    });
  }
}
