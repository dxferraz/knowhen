import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowhen/core/theme/constants/app_colors.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:knowhen/i18n/app_localizations.dart';

class OnboardingStep3 extends StatelessWidget {
  const OnboardingStep3({super.key});

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
            text: l10n.onboarding3Title,
            style: AppTextStyles.headline1,
            color: isDark ? DarkAppColors.primary : LightAppColors.primary,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.network('https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/app-media%2Fonboarding_3.svg?alt=media&token=9064452e-af43-4b5f-9b04-0333db4629d9'),
          ),
          AppText(
            text: l10n.onboarding3Description,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
