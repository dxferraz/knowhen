// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_fact_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoricalFactEntity _$HistoricalFactEntityFromJson(
        Map<String, dynamic> json) =>
    HistoricalFactEntity(
      fact: json['fact'] as String,
      imageUrl: json['imageUrl'] as String,
      month: json['month'] as String,
      year: json['year'] as String,
    );

Map<String, dynamic> _$HistoricalFactEntityToJson(
        HistoricalFactEntity instance) =>
    <String, dynamic>{
      'fact': instance.fact,
      'imageUrl': instance.imageUrl,
      'month': instance.month,
      'year': instance.year,
    };
