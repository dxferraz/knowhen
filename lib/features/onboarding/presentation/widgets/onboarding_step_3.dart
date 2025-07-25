import 'package:flutter/material.dart';
import 'package:knowhen/core/assets/svg/widgets/date_svg.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

class OnboardingStep3 extends StatelessWidget {
  const OnboardingStep3({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PrimaryH1(
            l10n.onboarding3Title,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: DateSvg(),
          ),
          PrimaryParagraphM(
            l10n.onboarding3Description,
            color: Theme.of(context).colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
