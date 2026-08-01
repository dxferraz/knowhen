import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/theme.dart';

/// Layout compartilhado dos passos do onboarding.
///
/// Os três passos usam exatamente a mesma cadência (ilustração → título →
/// descrição) para que o `PageView` pareça um único objeto deslizando, e não
/// três telas diferentes.
class OnboardingStepLayout extends StatelessWidget {
  const OnboardingStepLayout({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.accent,
  });

  final Widget illustration;
  final String title;
  final String description;

  /// Cor do gradiente de destaque do passo — dá progressão visual ao fluxo.
  final Gradient? accent;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    // Em telas baixas a ilustração cede espaço primeiro; o texto nunca corta.
    final double artSize = context.isCompactHeight ? 180 : 240;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.medium,
        AppSpacing.screenGutter,
        AppSpacing.large,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassReveal(
            order: 0,
            child: GlassContainer(
              level: GlassLevel.regular,
              width: artSize,
              height: artSize,
              padding: const EdgeInsets.all(AppSpacing.large),
              borderRadius: BorderRadius.circular(AppRadius.huge),
              child: illustration,
            ),
          ),
          const SizedBox(height: AppSpacing.xLarge),
          GlassReveal(
            order: 1,
            child: AppText.display(
              title,
              align: TextAlign.center,
              gradient: accent ?? glass.brandGradient,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          GlassReveal(
            order: 2,
            child: AppText.bodyLarge(description, align: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
