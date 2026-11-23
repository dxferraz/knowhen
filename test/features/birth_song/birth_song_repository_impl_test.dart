import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/features/birth_song/data/repositories/birth_song_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BirthSongRepositoryImpl repository;

  Map<String, dynamic> song(
    String year,
    String month, {
    String artist = 'Tom Jobim',
    String songName = 'Garota de Ipanema',
  }) => {
    'artist': artist,
    'songName': songName,
    'spotifyUrl': '',
    'month': month,
    'year': year,
  };

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = BirthSongRepositoryImpl(firestore: firestore);
  });

  test('reads the document by id AAAA-MM with a two-digit month', () async {
    await firestore
        .collection('brasil-songs')
        .doc('1995-03')
        .set(song('1995', '3'));

    final result = await repository.getBirthSong(DateTime(1995, 3, 14));

    expect(result?.artist, 'Tom Jobim');
    expect(result?.songName, 'Garota de Ipanema');
    expect(result?.month, '3');
    expect(result?.year, '1995');
  });

  test('keeps a two-digit month as is', () async {
    await firestore
        .collection('brasil-songs')
        .doc('1995-12')
        .set(song('1995', '12', artist: 'Cazuza'));

    final result = await repository.getBirthSong(DateTime(1995, 12, 1));

    expect(result?.artist, 'Cazuza');
  });

  test(
    'ignores old documents with a random id, even if year and month match',
    () async {
      await firestore
          .collection('brasil-songs')
          .doc('aB3xRandomId')
          .set(song('1995', '3', artist: 'Antigo'));

      expect(await repository.getBirthSong(DateTime(1995, 3, 14)), isNull);
    },
  );

  test('prefers the AAAA-MM document over an old random-id one', () async {
    await firestore
        .collection('brasil-songs')
        .doc('aB3xRandomId')
        .set(song('1995', '3', artist: 'Antigo'));
    await firestore
        .collection('brasil-songs')
        .doc('1995-03')
        .set(song('1995', '3', artist: 'Novo'));

    final result = await repository.getBirthSong(DateTime(1995, 3, 14));

    expect(result?.artist, 'Novo');
  });

  test('returns null when the document does not exist', () async {
    await firestore
        .collection('brasil-songs')
        .doc('1995-03')
        .set(song('1995', '3'));

    expect(await repository.getBirthSong(DateTime(1995, 4, 1)), isNull);
  });

  test(
    'returns null for a placeholder song, so the section stays hidden',
    () async {
      await firestore
          .collection('brasil-songs')
          .doc('1995-03')
          .set(
            song('1995', '3', artist: 'Desconhecido', songName: 'Desconhecido'),
          );

      expect(await repository.getBirthSong(DateTime(1995, 3, 14)), isNull);
    },
  );
}
