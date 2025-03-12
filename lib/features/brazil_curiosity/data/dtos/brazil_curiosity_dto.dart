import 'package:knowhen/features/brazil_curiosity/domain/entities/brazil_curiosity_entity.dart';

class BrazilCuriosityDTO {
  final String fact;
  final String imageUrl;
  final String month;
  final String year;

  BrazilCuriosityDTO({
    required this.fact,
    required this.imageUrl,
    required this.month,
    required this.year,
  });

  factory BrazilCuriosityDTO.fromJson(Map<String, dynamic> json) {
    return BrazilCuriosityDTO(
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

  BrazilCuriosityEntity toEntity() {
    return BrazilCuriosityEntity(
      fact: fact,
      imageUrl: imageUrl,
      month: month,
      year: year,
    );
  }
}
