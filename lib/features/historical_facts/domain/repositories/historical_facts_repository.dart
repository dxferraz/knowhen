import 'package:knowhen/features/historical_facts/data/dtos/brazil_curiosity_dto.dart';
import 'package:knowhen/features/historical_facts/data/dtos/historical_fact_dto.dart';

abstract class HistoricalFactsRepository {
  Future<HistoricalFactDTO> getHistoricalFact(DateTime birthDate);
  Future<BrazilCuriosityDTO> getBrazilCuriosity(DateTime birthDate);
  Future<String> getFactImage(String year, String month);
}
