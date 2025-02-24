import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowhen/features/summary/bloc/summary_events.dart';
import 'package:knowhen/features/summary/bloc/summary_state.dart';
import 'package:knowhen/features/historical_facts/data/repositories/historical_facts_repository_impl.dart';


class SummaryBloc extends Bloc<SummaryEvents, SummaryState> {
  final HistoricalFactsRepositoryImpl historicalFactsRepository;

  SummaryBloc(this.historicalFactsRepository) : super(SummaryInitial()) {
    on<GetSummary>((event, emit) async {
      emit(SummaryLoading());
      try {
        final factImage = await historicalFactsRepository.getFactImage(event.birthDate.year.toString(), event.birthDate.month.toString());
        final historicalFact = await historicalFactsRepository.getHistoricalFact(event.birthDate);
        final brazilCuriosity = await historicalFactsRepository.getBrazilCuriosity(event.birthDate);
        emit(SummaryLoaded(historicalFact: historicalFact.toEntity(), factImage: factImage, brazilCuriosity: brazilCuriosity.toEntity(), curiosityImage: brazilCuriosity.imageUrl),);
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });
  }
}
