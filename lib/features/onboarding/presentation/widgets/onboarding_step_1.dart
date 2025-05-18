import 'package:flutter/material.dart';
import 'package:knowhen/assets/svg/widgets/birthday_svg.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

class OnboardingStep1 extends StatelessWidget {
  const OnboardingStep1({super.key});

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
            text: l10n.onboarding1Title,
            color: Theme.of(context).colorScheme.secondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: BirthdaySVG(),
          ),
          PrimaryParagraphM(
            text: l10n.onboarding1Description,
            color: Theme.of(context).colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
