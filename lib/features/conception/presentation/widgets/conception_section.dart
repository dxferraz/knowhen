import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

class ConceptionSection extends StatelessWidget {
  final DateTime birthDate;
  const ConceptionSection({super.key, required this.birthDate});

  String calculateConception(BuildContext context, DateTime birthDate) {
    final l10n = AppLocalizations.of(context)!;
    final conceptionDate = birthDate.subtract(Duration(days: 280));
    final startRange = conceptionDate.subtract(Duration(days: 7));
    final endRange = conceptionDate.add(Duration(days: 7));

    final dateFormat = DateFormat('dd/MM/yyyy');

    return l10n.conceptionRange(dateFormat.format(startRange), dateFormat.format(endRange));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SecondaryH2(
              text: 'Muito provavavelmente, no período de:',
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                children: [
                  PrimaryH3(
                    text: calculateConception(context, birthDate),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),
            ),
            SecondaryH2(
              text: 'Foi quando a cegonha te levou ao colo de sua mãe!',
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
