import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';

/// Search links (no API or key needed). On a phone with the app installed the
/// OS hands these https links to the Spotify / YouTube app, otherwise they open
/// in the browser.
class BirthSongLinks {
  BirthSongLinks._();

  static String _query(BirthSongEntity song) =>
      '${song.songName} ${song.artist}';

  static Uri spotify(BirthSongEntity song) => Uri(
    scheme: 'https',
    host: 'open.spotify.com',
    pathSegments: ['search', _query(song)],
  );

  static Uri youtube(BirthSongEntity song) =>
      Uri.https('www.youtube.com', '/results', {'search_query': _query(song)});
}
