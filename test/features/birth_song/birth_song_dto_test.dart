import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birth_song/data/dtos/birth_song_dto.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';

void main() {
  Map<String, dynamic> doc({
    Object? artist = 'Tom Jobim',
    Object? songName = 'Garota de Ipanema',
    Object? month = '3',
    Object? year = '1995',
  }) => {
    'artist': artist,
    'songName': songName,
    'month': month,
    'year': year,
    'spotifyUrl': '',
  };

  test('documento válido vira entidade', () {
    final entity = BirthSongDTO.fromJson(doc()).toEntity();

    expect(
      entity,
      const BirthSongEntity(
        artist: 'Tom Jobim',
        songName: 'Garota de Ipanema',
        month: '3',
        year: '1995',
      ),
    );
  });

  test('remove espaços e aceita mês/ano numéricos', () {
    final entity = BirthSongDTO.fromJson(
      doc(
        artist: '  Tom Jobim ',
        songName: ' Garota de Ipanema',
        month: 3,
        year: 1995,
      ),
    ).toEntity();

    expect(entity?.artist, 'Tom Jobim');
    expect(entity?.songName, 'Garota de Ipanema');
    expect(entity?.month, '3');
    expect(entity?.year, '1995');
  });

  test(
    'o "Unknown" que o script grava quando não consegue ler a resposta não é uma música',
    () {
      expect(BirthSongDTO.fromJson(doc(artist: 'Unknown')).toEntity(), isNull);
      expect(
        BirthSongDTO.fromJson(doc(songName: 'unknown')).toEntity(),
        isNull,
      );
      expect(
        BirthSongDTO.fromJson(doc(songName: 'Desconhecido')).toEntity(),
        isNull,
      );
    },
  );

  test('artista ou música vazios, em branco ou ausentes escondem a seção', () {
    expect(BirthSongDTO.fromJson(doc(artist: '')).toEntity(), isNull);
    expect(BirthSongDTO.fromJson(doc(songName: '   ')).toEntity(), isNull);
    expect(BirthSongDTO.fromJson(doc(artist: null)).toEntity(), isNull);
    expect(
      BirthSongDTO.fromJson({'month': '3', 'year': '1995'}).toEntity(),
      isNull,
    );
  });

  test('period usa dois dígitos para o mês', () {
    expect(
      const BirthSongEntity(
        artist: 'a',
        songName: 'b',
        month: '3',
        year: '1995',
      ).period,
      '03/1995',
    );
    expect(
      const BirthSongEntity(
        artist: 'a',
        songName: 'b',
        month: '11',
        year: '2002',
      ).period,
      '11/2002',
    );
  });
}
