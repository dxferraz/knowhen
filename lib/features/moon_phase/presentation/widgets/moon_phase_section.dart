import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/theme/theme.dart';

class MoonPhaseSection extends StatelessWidget {
  const MoonPhaseSection({super.key, required this.moonPhase});

  final MoonPhase moonPhase;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return AppSection(
      eyebrow: 'Céu da sua noite',
      title: 'Você nasceu na',
      child: GlassCard(
        level: GlassLevel.regular,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.display(
              moonPhase.phaseName,
              align: TextAlign.center,
              gradient: glass.warmGradient,
            ),
            const SizedBox(height: AppSpacing.large),
            // A lua ganha um halo próprio: é o único elemento pictórico da
            // seção e precisa se destacar do vidro sem virar um card dentro
            // de outro card.
            Flexible(child: _MoonArtwork(imageUrl: moonPhase.imageUrl)),
            const SizedBox(height: AppSpacing.large),
            AppText.body(moonPhase.description, align: TextAlign.center),
            const SizedBox(height: AppSpacing.small),
            AppText.caption(moonPhase.influence, align: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MoonArtwork extends StatelessWidget {
  const _MoonArtwork({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final double size = context.isCompactHeight ? 120 : 156;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colors.tertiary.withValues(alpha: 0.26),
            blurRadius: 48,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.tertiary,
                  ),
                ),
              ),
        errorBuilder: (context, error, stack) => Icon(
          Icons.nightlight_round,
          size: size * 0.6,
          color: context.colors.tertiary,
        ),
      ),
    );
  }
}
