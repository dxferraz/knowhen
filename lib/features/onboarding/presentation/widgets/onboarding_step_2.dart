import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowhen/core/theme/constants/app_colors.dart';
import 'package:knowhen/core/theme/widgets/text_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingStep2 extends StatelessWidget {
  const OnboardingStep2({super.key});

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
            text: l10n.onboarding2Title,
            style: AppTextStyles.headline1,
            color: isDark ? DarkAppColors.primary : LightAppColors.primary,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.network('https://firebasestorage.googleapis.com/v0/b/knowhen.firebasestorage.app/o/app-media%2Fonboarding_2.svg?alt=media&token=f949eda6-4d15-4ad3-8793-23ad12bcf087'),
          ),
          AppText(
            text: l10n.onboarding2Description,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
