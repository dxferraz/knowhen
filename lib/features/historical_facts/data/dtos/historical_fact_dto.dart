import 'package:knowhen/features/historical_facts/domain/entities/historical_fact_entity.dart';

class HistoricalFactDTO {
  final String fact;
  final String imageUrl;
  final String month;
  final String year;

  HistoricalFactDTO({
    required this.fact,
    required this.imageUrl,
    required this.month,
    required this.year,
  });

  factory HistoricalFactDTO.fromJson(Map<String, dynamic> json) {
    return HistoricalFactDTO(
      fact: json['fact'],
      imageUrl: json['imageUrl'],
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
      'imageUrl': imageUrl,
      'month': month,
      'year': year,
    };
  }

  HistoricalFactEntity toEntity() {
    return HistoricalFactEntity(
      fact: fact,
      imageUrl: imageUrl,
      month: month,
      year: year,
    );
  }
}
