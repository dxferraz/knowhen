import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme.dart';

class BrazilCuriositySection extends StatelessWidget {
  const BrazilCuriositySection({
    super.key,
    required this.imageUrl,
    required this.curiosity,
  });

  final String imageUrl;
  final String curiosity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> paragraphs = curiosity.split('. ');

    return AppSection(
      eyebrow: 'Brasil',
      title: l10n.historicalFact,
      child: GlassCard(
        level: GlassLevel.regular,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.body(
              l10n.firstFactParagraph(paragraphs.first),
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            Flexible(
              child: _FactImage(
                imageUrl: imageUrl,
                emptyLabel: l10n.noImageForFact,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            GlassBadge(
              icon: Icons.auto_awesome_rounded,
              label: l10n.aiGeneratedImage,
              color: context.colors.accent,
            ),
            if (paragraphs.length > 1) ...[
              const SizedBox(height: AppSpacing.medium),
              AppText.body(
                l10n.lastFactParagraph(paragraphs.last),
                align: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactImage extends StatelessWidget {
  const _FactImage({required this.imageUrl, required this.emptyLabel});

  final String imageUrl;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _Placeholder(label: emptyLabel);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  ),
                ),
          errorBuilder: (context, error, stack) =>
              _Placeholder(label: emptyLabel),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      level: GlassLevel.subtle,
      padding: const EdgeInsets.all(AppSpacing.large),
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: context.colors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.small),
          AppText.caption(label, align: TextAlign.center),
        ],
      ),
    );
  }
}
