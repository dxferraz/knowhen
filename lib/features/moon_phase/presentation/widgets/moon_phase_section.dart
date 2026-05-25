import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';

class MoonPhaseSection extends StatelessWidget {
  final MoonPhase moonPhase;
  const MoonPhaseSection({super.key, required this.moonPhase});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            SecondaryH2(
              'Você nasceu na:',
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
                    moonPhase.phaseName,
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
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  const SizedBox(height: 10),
                  PrimaryParagraphS(
                    moonPhase.description,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  PrimaryParagraphS(
                    moonPhase.influence,
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
