import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowhen/features/birth_song/data/dtos/birth_song_dto.dart';
import 'package:knowhen/features/birth_song/domain/entities/birth_song_entity.dart';
import 'package:knowhen/features/birth_song/domain/repositories/birth_song_repository.dart';

class BirthSongRepositoryImpl implements BirthSongRepository {
  final FirebaseFirestore firestore;

  BirthSongRepositoryImpl({required this.firestore});

  @override
  Future<BirthSongEntity?> getBirthSong(DateTime birthDate) async {
    final result = await firestore
        .collection('brasil-songs')
        .where('year', isEqualTo: birthDate.year.toString())
        .where('month', isEqualTo: birthDate.month.toString())
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    return BirthSongDTO.fromJson(result.docs.first.data()).toEntity();
  }
}
