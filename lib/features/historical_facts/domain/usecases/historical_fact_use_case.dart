import 'package:knowhen/features/historical_facts/data/dtos/historical_fact_dto.dart';
import 'package:knowhen/features/historical_facts/domain/repositories/historical_facts_repository.dart';

class HistoricalFactUseCase {
  final HistoricalFactsRepository historicalFactsRepository;

  HistoricalFactUseCase(this.historicalFactsRepository);

  Future<HistoricalFactDTO> getHistoricalFact(DateTime birthDate) {
    final result = historicalFactsRepository.getHistoricalFact(birthDate);
    return result;
  }
}
