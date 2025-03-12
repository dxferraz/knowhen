import 'package:json_annotation/json_annotation.dart';

part 'brazil_curiosity_entity.g.dart';

@JsonSerializable()
class BrazilCuriosityEntity {
  final String fact;
  final String imageUrl;
  final String month;
  final String year;

  BrazilCuriosityEntity({
    required this.fact,
    required this.imageUrl,
    required this.month,
    required this.year,
  });

  factory BrazilCuriosityEntity.fromJson(Map<String, dynamic> json) => _$BrazilCuriosityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$BrazilCuriosityEntityToJson(this);
}
