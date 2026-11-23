import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowhen/features/birth_song/data/dtos/birth_song_dto.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';

class BirthSongRepositoryImpl implements BirthSongRepository {
  final FirebaseFirestore firestore;

  BirthSongRepositoryImpl({required this.firestore});

  /// Reads the document `AAAA-MM` directly: deterministic, and it ignores documents with random ids
  /// written by older versions of the fill script.
  @override
  Future<BirthSongEntity?> getBirthSong(DateTime birthDate) async {
    final id =
        '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}';
    final snapshot = await firestore.collection('brasil-songs').doc(id).get();
    final data = snapshot.data();
    if (data == null) return null;
    return BirthSongDTO.fromJson(data).toEntity();
  }
}
