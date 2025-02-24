import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrazilCuriositySection extends StatelessWidget {
  final String imageUrl;
  final String curiosity;

  const BrazilCuriositySection({super.key, required this.imageUrl, required this.curiosity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final curiosityParagraphs = curiosity.split('. ');

    return Column(
      children: [
        Text('Curiosidades do Brasil'),
        SizedBox(height: 20),
        Text(l10n.firstFactParagraph(curiosityParagraphs.first)),
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
            Text(l10n.aiGeneratedImage)
          ],
        ),
        SizedBox(height: 15),
        Text(l10n.lastFactParagraph(curiosityParagraphs.last)),
        SizedBox(height: 20),
      ],
    );
  }
}
