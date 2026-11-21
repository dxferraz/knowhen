import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birth_song/domain/birth_song_links.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';

void main() {
  BirthSongEntity song(String name, String artist) =>
      BirthSongEntity(artist: artist, songName: name, month: '3', year: '1995');

  test('link de busca do Spotify é https e codifica a consulta no caminho', () {
    final url = BirthSongLinks.spotify(song('Garota de Ipanema', 'Tom Jobim'));

    expect(
      url.toString(),
      'https://open.spotify.com/search/Garota%20de%20Ipanema%20Tom%20Jobim',
    );
  });

  test('link de busca do YouTube é https e codifica a consulta', () {
    final url = BirthSongLinks.youtube(song('Garota de Ipanema', 'Tom Jobim'));

    expect(url.scheme, 'https');
    expect(url.host, 'www.youtube.com');
    expect(url.path, '/results');
    expect(url.queryParameters, {
      'search_query': 'Garota de Ipanema Tom Jobim',
    });
  });

  test(
    'acentos e caracteres reservados não quebram nem injetam parâmetros',
    () {
      final tricky = song('Ai, Ai, Ai? #1 & mais/ação', 'Zeca & Cia');

      final youtube = BirthSongLinks.youtube(tricky);
      expect(youtube.queryParameters, {
        'search_query': 'Ai, Ai, Ai? #1 & mais/ação Zeca & Cia',
      });
      expect(youtube.fragment, isEmpty);

      final spotify = BirthSongLinks.spotify(tricky);
      expect(spotify.pathSegments, [
        'search',
        'Ai, Ai, Ai? #1 & mais/ação Zeca & Cia',
      ]);
      expect(spotify.hasQuery, isFalse);
      expect(spotify.fragment, isEmpty);
    },
  );
}
