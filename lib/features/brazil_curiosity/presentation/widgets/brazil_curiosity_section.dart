import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

class BrazilCuriositySection extends StatelessWidget {
  final String imageUrl;
  final String curiosity;
  const BrazilCuriositySection({super.key, required this.imageUrl, required this.curiosity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final factParagraphs = curiosity.split('. ');

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SecondaryH1(
              text: l10n.historicalFact,
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
                  PrimaryParagraphS(
                    text: l10n.firstFactParagraph(factParagraphs.first),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  SizedBox(height: 15),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        clipBehavior: Clip.hardEdge,
                        width: 250,
                        child: imageUrl.isNotEmpty ? Image.network(imageUrl) : Text(l10n.noImageForFact),
                      ),
                      SizedBox(height: 5),
                      PrimaryCaption(
                        text: l10n.aiGeneratedImage,
                        textAlign: TextAlign.center,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  PrimaryParagraphS(
                    text: l10n.lastFactParagraph(factParagraphs.last),
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.surface,
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
