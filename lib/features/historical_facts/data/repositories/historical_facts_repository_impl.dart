import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fal_client/fal_client.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:knowhen/env/env.dart';
import 'package:knowhen/features/historical_facts/data/dtos/brazil_curiosity_dto.dart';
import 'package:knowhen/features/historical_facts/data/dtos/historical_fact_dto.dart';
import 'package:knowhen/features/historical_facts/domain/repositories/historical_facts_repository.dart';
import 'package:http/http.dart' as http;

class HistoricalFactsRepositoryImpl implements HistoricalFactsRepository {
  final FirebaseFirestore firestore;

  HistoricalFactsRepositoryImpl({required this.firestore});

  @override
  Future<HistoricalFactDTO> getHistoricalFact(DateTime birthDate) async {
    final result = await firestore.collection('historical-facts').where('year', isEqualTo: birthDate.year.toString()).where('month', isEqualTo: birthDate.month.toString()).get();
    return HistoricalFactDTO.fromJson(result.docs.first.data());
  }

  @override
  Future<BrazilCuriosityDTO> getBrazilCuriosity(DateTime birthDate) async {
    final result = await firestore.collection('brasil-curiosities').where('year', isEqualTo: birthDate.year.toString()).where('month', isEqualTo: birthDate.month.toString()).get();
    return BrazilCuriosityDTO.fromJson(result.docs.first.data());
  }

  @override
  Future<String> getFactImage(String year, String month) async {
    Future<bool> imageExists(String path) async {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(path);
        await storageRef.getDownloadURL();
        debugPrint("A imagem existe no Storage.");
        return true;
      } catch (e) {
        debugPrint("Imagem não encontrada ou erro ao acessar: $e");
        return false;
      }
    }

    bool exists = await imageExists('historical-facts-images/$year/$month.png');

    if (exists) {
      final storageRef = FirebaseStorage.instance.ref().child('historical-facts-images/$year/$month.png');
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } else {
      final fact = await firestore.collection('historical-facts').where('year', isEqualTo: year.toString()).where('month', isEqualTo: month.toString()).get().then((value) => HistoricalFactDTO.fromJson(value.docs.first.data()));

      final fal = FalClient.withCredentials(Env.falAiApiKey);

      final generatedImage = await fal.subscribe(
        "fal-ai/flux/dev",
        input: {
          "prompt": "Quero uma imagem detalhada que represente o seguinte fato: ${fact.fact}",
          "image_size": "landscape_16_9",
        },
        logs: true,
        webhookUrl: "https://optional.webhook.url/for/results",
        onQueueUpdate: (update) {
          debugPrint(update.toString());
        },
      );

      final imageFile = await http.get(Uri.parse(generatedImage.data["images"][0]["url"]));

      final uploadRef = FirebaseStorage.instance.ref().child('historical-facts-images/$year/$month.png');

      final uploadTask = uploadRef.putData(imageFile.bodyBytes);

      await uploadTask.whenComplete(() => debugPrint('Upload complete'));

      final imageUrl = await uploadRef.getDownloadURL();

      await firestore.collection('historical-facts').where('year', isEqualTo: year).where('month', isEqualTo: month).get().then((value) => value.docs.first.reference.update({'imageUrl': imageUrl}));

      return imageUrl;
    }
  }
}
