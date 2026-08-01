import 'package:flutter/material.dart';
import 'package:knowhen/core/assets/svg/widgets/date_svg.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_layout.dart';

class OnboardingStep3 extends StatelessWidget {
  const OnboardingStep3({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingStepLayout(
      illustration: const DateSvg(),
      title: l10n.onboarding3Title,
      description: l10n.onboarding3Description,
      accent: context.glass.warmGradient,
    );
  }
}
