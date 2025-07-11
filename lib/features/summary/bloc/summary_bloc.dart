import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/features/summary/bloc/summary_events.dart';
import 'package:knowhen/features/summary/bloc/summary_state.dart';
import 'package:knowhen/features/brazil_curiosity/data/repositories/brazil_curiosity_repository_impl.dart';

class SummaryBloc extends Bloc<SummaryEvents, SummaryState> {
  final HistoricalFactsRepositoryImpl historicalFactsRepository;

  SummaryBloc(this.historicalFactsRepository) : super(SummaryInitial()) {
    on<GetSummary>((event, emit) async {
      emit(SummaryLoading());
      try {
        final brazilCuriosity = await historicalFactsRepository.getBrazilCuriosity(event.birthDate);
        final curiosityImage = await historicalFactsRepository.getCuriosityImage(event.birthDate.year.toString(), event.birthDate.month.toString());
        emit(
          SummaryLoaded(brazilCuriosity: brazilCuriosity.toEntity(), curiosityImage: curiosityImage),
        );
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });
  }
}
