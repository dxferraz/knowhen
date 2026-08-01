import 'package:flutter/material.dart';
import 'package:knowhen/core/assets/svg/widgets/birthday_svg.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_layout.dart';

class OnboardingStep1 extends StatelessWidget {
  const OnboardingStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingStepLayout(
      illustration: const BirthdaySVG(),
      title: l10n.onboarding1Title,
      description: l10n.onboarding1Description,
      accent: context.glass.brandGradient,
    );
  }
}
