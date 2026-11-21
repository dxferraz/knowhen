import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';

class BirthSongDTO {
  /// Placeholders written by `fill-brasil-featured-song.js` when the model's
  /// answer could not be parsed. They are not real songs.
  static const _placeholders = {
    'unknown',
    'desconhecido',
    'desconhecida',
    'n/a',
    '-',
  };

  final String? artist;
  final String? songName;
  final String month;
  final String year;

  BirthSongDTO({
    required this.artist,
    required this.songName,
    required this.month,
    required this.year,
  });

  factory BirthSongDTO.fromJson(Map<String, dynamic> json) {
    return BirthSongDTO(
      artist: json['artist']?.toString(),
      songName: json['songName']?.toString(),
      month: json['month']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null ||
        trimmed.isEmpty ||
        _placeholders.contains(trimmed.toLowerCase())) {
      return null;
    }
    return trimmed;
  }

  /// `null` when artist or song is missing or a placeholder, so the section is
  /// hidden instead of showing a broken card.
  BirthSongEntity? toEntity() {
    final artist = _clean(this.artist);
    final songName = _clean(this.songName);
    if (artist == null || songName == null) return null;
    return BirthSongEntity(
      artist: artist,
      songName: songName,
      month: month,
      year: year,
    );
  }
}
