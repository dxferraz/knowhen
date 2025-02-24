import 'package:json_annotation/json_annotation.dart';

part 'historical_fact_entity.g.dart';

@JsonSerializable()
class HistoricalFactEntity {
  final String fact;
  final String imageUrl;
  final String month;
  final String year;

  HistoricalFactEntity({
    required this.fact,
    required this.imageUrl,
    required this.month,
    required this.year,
  });

  factory HistoricalFactEntity.fromJson(Map<String, dynamic> json) => _$HistoricalFactEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HistoricalFactEntityToJson(this);
}
