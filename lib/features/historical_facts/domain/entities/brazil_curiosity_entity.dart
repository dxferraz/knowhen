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

  factory BrazilCuriosityEntity.fromJson(Map<String, dynamic> json) => BrazilCuriosityEntity(
        fact: json['fact'] as String,
        imageUrl: json['imageUrl'] as String,
        month: json['month'] as String,
        year: json['year'] as String,
      );

  Map<String, dynamic> toJson() => {
        'fact': fact,
        'imageUrl': imageUrl,
        'month': month,
        'year': year,
      };
}
