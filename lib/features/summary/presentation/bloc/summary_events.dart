import 'package:equatable/equatable.dart';

abstract class SummaryEvents extends Equatable {}

class GetSummary extends SummaryEvents {
  final DateTime birthDate;

  GetSummary({required this.birthDate});

  @override
  List<Object?> get props => [birthDate];
}

/// "Tentar de novo" do cartão do fato histórico: busca só a parte remota, sem refazer o resumo.
class RetryBrazilCuriosity extends SummaryEvents {
  final DateTime birthDate;

  RetryBrazilCuriosity({required this.birthDate});

  @override
  List<Object?> get props => [birthDate];
}
