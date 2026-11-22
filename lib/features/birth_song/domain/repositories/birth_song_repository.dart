import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';

abstract class BirthSongRepository {
  /// Returns the song for the birth month/year, or `null` when there is no
  /// valid data for it (the summary then hides the section).
  Future<BirthSongEntity?> getBirthSong(DateTime birthDate);
}
