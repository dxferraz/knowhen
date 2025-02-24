abstract class SummaryEvents {}

class GetSummary extends SummaryEvents {
  final DateTime birthDate;

  GetSummary({required this.birthDate});
}
