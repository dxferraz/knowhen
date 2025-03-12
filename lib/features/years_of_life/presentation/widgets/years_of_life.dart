import 'package:flutter/material.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

class YearsOfLifeSection extends StatelessWidget {
  final DateTime birthDate;
  final TimeOfDay? birthTime;

  const YearsOfLifeSection({super.key, required this.birthDate, required this.birthTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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

    int getHoursOfLife() {
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final hours = difference.inHours;

      return hours;
    }

    final int yearsOfLife = getYearsOfLife();
    final int monthsOfLife = getMonthsOfLife();
    final int daysOfLife = getDaysOfLife();
    final int hoursOfLife = getHoursOfLife();

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              l10n.yearsOfLifeTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              l10n.yearsOfLife(yearsOfLife, monthsOfLife, daysOfLife),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(hoursOfLife.toString())
          ],
        ),
      ),
    );
  }
}
