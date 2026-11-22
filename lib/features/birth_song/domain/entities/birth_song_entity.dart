import 'package:equatable/equatable.dart';

class BirthSongEntity extends Equatable {
  final String artist;
  final String songName;
  final String month;
  final String year;

  const BirthSongEntity({required this.artist, required this.songName, required this.month, required this.year});

  /// Month and year as `MM/yyyy`, e.g. `03/1995`.
  String get period => '${month.padLeft(2, '0')}/$year';

  @override
  List<Object?> get props => [artist, songName, month, year];
}
