import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/features/years_of_life/presentation/widgets/life_clock.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

class YearsOfLifeSection extends StatelessWidget {
  final DateTime birthDate;
  final TimeOfDay? birthTime;

  const YearsOfLifeSection({super.key, required this.birthDate, required this.birthTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    int getYearsOfLife() {
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final age = difference.inDays ~/ 365;

      return age;
    }

    int getMonthsOfLife() {
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final age = difference.inDays ~/ 30;

      return age;
    }

    int getDaysOfLife() {
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final age = difference.inDays;

      return age;
    }

    final int yearsOfLife = getYearsOfLife();
    final int monthsOfLife = getMonthsOfLife();
    final int daysOfLife = getDaysOfLife();

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SecondaryH2(
              l10n.yearsOfLifeTitle,
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
                    l10n.yearsOfLife(yearsOfLife),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  PrimaryH3(
                    l10n.monthsOfLife(monthsOfLife),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  PrimaryH3(
                    l10n.daysOfLife(daysOfLife),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),
            ),
            birthTime != null
                ? Column(
                    children: [
                      SecondaryH2(
                        'E viveu:',
                        textAlign: TextAlign.center,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      birthTime != null
                          ? LifeClock(
                              birthDateTime: birthDate,
                              birthTime: birthTime!,
                            )
                          : Container()
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
