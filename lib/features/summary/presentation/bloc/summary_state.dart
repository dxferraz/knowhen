import 'package:equatable/equatable.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/brazil_curiosity/domain/entities/brazil_curiosity_entity.dart';

abstract class SummaryState extends Equatable {}

class SummaryInitial extends SummaryState {
  @override
  List<Object?> get props => [];
}

class SummaryLoading extends SummaryState {
  @override
  List<Object?> get props => [];
}

class SummaryLoaded extends SummaryState {
  final MoonPhase moonPhase;
  final String curiosityImage;
  final BrazilCuriosityEntity brazilCuriosity;

  SummaryLoaded({
    required this.moonPhase,
    required this.curiosityImage,
    required this.brazilCuriosity,
  });

  @override
  List<Object?> get props => [moonPhase, curiosityImage, brazilCuriosity];
}

class SummaryError extends SummaryState {
  final String message;

  SummaryError({required this.message});

  @override
  List<Object?> get props => [message];
}
