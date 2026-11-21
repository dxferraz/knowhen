import 'package:knowhen/features/brazil_curiosity/data/dtos/brazil_curiosity_dto.dart';

abstract class BrazilCuriositiesRepository {
  /// Retorna `null` quando não há curiosidade cadastrada para o mês/ano de [birthDate].
  Future<BrazilCuriosityDTO?> getBrazilCuriosity(DateTime birthDate);
  /// Retorna `''` quando não há curiosidade cadastrada para [year]/[month].
  Future<String> getCuriosityImage(String year, String month);
}
