import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConceptionSection extends StatelessWidget {
  final DateTime birthDate;
  const ConceptionSection({super.key, required this.birthDate});

  String calculateConception( BuildContext context, DateTime birthDate) {
    final l10n = AppLocalizations.of(context)!;
    final conceptionDate = birthDate.subtract(Duration(days: 280));
    final startRange = conceptionDate.subtract(Duration(days: 7));
    final endRange = conceptionDate.add(Duration(days: 7));

    final dateFormat = DateFormat('dd/MM/yyyy');

    return l10n.conceptionRange(dateFormat.format(startRange), dateFormat.format(endRange));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          calculateConception(context,birthDate),
        ),
      ],
    );
  }
}
