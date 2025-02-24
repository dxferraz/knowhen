import 'package:knowhen/features/historical_facts/domain/entities/brazil_curiosity_entity.dart';
import 'package:knowhen/features/historical_facts/domain/entities/historical_fact_entity.dart';

abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final String factImage;
  final String curiosityImage;
  final HistoricalFactEntity historicalFact;
  final BrazilCuriosityEntity brazilCuriosity;

  SummaryLoaded({
    required this.factImage,
    required this.curiosityImage,
    required this.historicalFact,
    required this.brazilCuriosity,
  });
}

class SummaryError extends SummaryState {
  final String message;

  SummaryError({required this.message});
}
