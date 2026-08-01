import 'package:flutter/material.dart';
import 'package:knowhen/core/assets/svg/widgets/report_svg.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_layout.dart';

class OnboardingStep2 extends StatelessWidget {
  const OnboardingStep2({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingStepLayout(
      illustration: const ReportSvg(),
      title: l10n.onboarding2Title,
      description: l10n.onboarding2Description,
      accent: context.glass.coolGradient,
    );
  }
}
