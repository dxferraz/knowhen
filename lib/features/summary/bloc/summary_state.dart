import 'package:knowhen/features/brazil_curiosity/domain/entities/brazil_curiosity_entity.dart';

abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final String curiosityImage;
  final BrazilCuriosityEntity brazilCuriosity;

  SummaryLoaded({
    required this.curiosityImage,
    required this.brazilCuriosity,
  });
}

class SummaryError extends SummaryState {
  final String message;

  SummaryError({required this.message});
}
