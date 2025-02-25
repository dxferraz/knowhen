import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowhen/core/theme/constants/app_colors.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

class OnboardingStep1 extends StatelessWidget {
  const OnboardingStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: l10n.onboarding1Title,
            style: AppTextStyles.headline1,
            color: isDark ? DarkAppColors.primary : LightAppColors.primary,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.network('https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/app-media%2Fonboarding_1.svg?alt=media&token=dab8a9b6-d77c-4b50-9101-f91cf5379173'),
          ),
          AppText(
            text: l10n.onboarding1Description,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
