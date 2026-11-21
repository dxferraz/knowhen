import 'package:equatable/equatable.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
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
  final BirthSongEntity? birthSong;

  SummaryLoaded({
    required this.moonPhase,
    required this.curiosityImage,
    required this.brazilCuriosity,
    this.birthSong,
  });

  @override
  List<Object?> get props => [
    moonPhase,
    curiosityImage,
    brazilCuriosity,
    birthSong,
  ];
}

class SummaryError extends SummaryState {
  final String message;

  SummaryError({required this.message});

  @override
  List<Object?> get props => [message];
}
