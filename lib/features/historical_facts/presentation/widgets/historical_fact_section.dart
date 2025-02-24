import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HistoricalFactSection extends StatelessWidget {
  final String imageUrl;
  final String fact;
  const HistoricalFactSection({super.key, required this.imageUrl, required this.fact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final factParagraphs = fact.split('. ');

    return Column(
      children: [
        Text(l10n.historicalFact),
        SizedBox(height: 20),
        Text(l10n.firstFactParagraph(factParagraphs.first)),
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
        Text(l10n.lastFactParagraph(factParagraphs.last)),
        SizedBox(height: 20),
      ],
    );
  }
}
