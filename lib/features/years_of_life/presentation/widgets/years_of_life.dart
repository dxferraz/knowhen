import 'package:flutter/material.dart';
import 'package:knowhen/i18n/app_localizations.dart';

class YearsOfLifeSection extends StatelessWidget {
  final DateTime birthDate;

  const YearsOfLifeSection({super.key, required this.birthDate});

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

    final int yearsOfLife = getYearsOfLife();
    final int monthsOfLife = getMonthsOfLife();
    final int daysOfLife = getDaysOfLife();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://placehold.co/600x400'),
          fit: BoxFit.cover,
        ),
      ),
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
          ],
        ),
      ),
    );
  }
}
