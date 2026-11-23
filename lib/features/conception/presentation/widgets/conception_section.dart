import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/conception_window.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

class ConceptionSection extends StatelessWidget {
  final DateTime birthDate;
  const ConceptionSection({super.key, required this.birthDate});

  String calculateConception(BuildContext context, DateTime birthDate) {
    final l10n = AppLocalizations.of(context)!;
    final window = conceptionWindow(birthDate);

    return l10n.conceptionRange(DateText.numeric(window.start), DateText.numeric(window.end));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.conceptionTitle,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  PrimaryH3(
                    calculateConception(context, birthDate),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            SecondaryH2(
              l10n.conceptionNote,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
