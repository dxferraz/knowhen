import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/features/moon_phase/presentation/moon_phase_l10n.dart';

class MoonPhaseSection extends StatelessWidget {
  final MoonPhase moonPhase;
  const MoonPhaseSection({super.key, required this.moonPhase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            SecondaryH2(
              l10n.moonPhaseTitle,
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
                    l10n.moonPhaseName(moonPhase.type),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    moonPhase.imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      return loadingProgress == null
                          ? child
                          : CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimaryContainer);
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.nightlight_round,
                      size: MediaQuery.of(context).size.width * 0.3,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  const SizedBox(height: 10),
                  PrimaryParagraphS(
                    l10n.moonPhaseDescription(moonPhase.type),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  PrimaryParagraphS(
                    l10n.moonPhaseInfluence(moonPhase.type),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
