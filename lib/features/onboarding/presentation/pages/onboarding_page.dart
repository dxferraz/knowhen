import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/widgets/custom_button.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_1.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_2.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:knowhen/l10n/generated/app_localizations.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _controller;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [ThemeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          children: const [
            OnboardingStep1(),
            OnboardingStep2(),
            OnboardingStep3(),
          ],
        ),
      ),
      bottomSheet: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isLastPage
                ? Container(width: 85)
                : CustomButton(
                    onPressed: () {
                      _controller.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.ease,
                      );
                    },
                    backgroundColor: Colors.transparent,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    text: l10n.skip,
                  ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                dotHeight: 14,
                dotWidth: 14,
                dotColor: backgroundColor.withAlpha(150),
                activeDotColor: isLastPage ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.secondary,
              ),
              onDotClicked: (index) => _controller.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease),
            ),
            if (isLastPage)
              CustomButton(
                onPressed: () {
                  markOnboardingCompleted();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BirthdatePage(),
                  ));
                },
                text: l10n.start,
                backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            else
              CustomButton(
                onPressed: () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                text: l10n.next,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
          ],
        ),
      ),
    );
  }
}
