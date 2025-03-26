import 'package:equatable/equatable.dart';

abstract class SummaryEvents extends Equatable {}

class GetSummary extends SummaryEvents {
  final DateTime birthDate;

  GetSummary({required this.birthDate});

  @override
  List<Object?> get props => [birthDate];
}
