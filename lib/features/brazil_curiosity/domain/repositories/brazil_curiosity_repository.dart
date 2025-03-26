import 'package:knowhen/features/brazil_curiosity/data/dtos/brazil_curiosity_dto.dart';

abstract class BrazilCuriositiesRepository {
  Future<BrazilCuriosityDTO> getBrazilCuriosity(DateTime birthDate);
  Future<String> getCuriosityImage(String year, String month);
}
