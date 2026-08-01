import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/theme.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_1.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_2.dart';
import 'package:knowhen/features/onboarding/presentation/widgets/onboarding_step_3.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _stepCount = 3;

  late final PageController _controller;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    AnalyticsService.instance.logOnboardingStarted();
    AnalyticsService.instance.logOnboardingStepViewed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
  }

  void _goToBirthdate() {
    markOnboardingCompleted();
    AnalyticsService.instance.logOnboardingCompleted();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const BirthdatePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassScaffold(
      appBar: const GlassAppBar(
        titleWidget: AppLogo(),
        automaticallyImplyLeading: false,
        bottomDivider: false,
        actions: [ThemeButton()],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => isLastPage = index == _stepCount - 1);
          AnalyticsService.instance.logOnboardingStepViewed(index);
        },
        children: const [
          OnboardingStep1(),
          OnboardingStep2(),
          OnboardingStep3(),
        ],
      ),
      bottomBar: GlassBottomBar(
        child: Row(
          children: [
            // Os `Expanded` iguais nas pontas mantêm o indicador centrado
            // mesmo quando os rótulos dos botões mudam de largura.
            //
            // `heightFactor: 1` é obrigatório: sem ele o `Align` se expande
            // até a altura máxima permitida pela `Row` — que aqui é a tela
            // inteira — e a barra deixa de ser uma barra.
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: isLastPage
                    ? const SizedBox.shrink()
                    : GlassButton(
                        label: l10n.skip,
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                        onPressed: () {
                          final currentPage = _controller.hasClients
                              ? _controller.page?.round() ?? 0
                              : 0;
                          AnalyticsService.instance
                              .logOnboardingSkipped(currentPage);
                          _controller.animateToPage(
                            _stepCount - 1,
                            duration: AppMotion.page,
                            curve: AppMotion.standard,
                          );
                        },
                      ),
              ),
            ),
            AppPageIndicator(controller: _controller, count: _stepCount),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: GlassButton(
                  label: isLastPage ? l10n.start : l10n.next,
                  size: AppButtonSize.small,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (isLastPage) {
                      _goToBirthdate();
                    } else {
                      _controller.nextPage(
                        duration: AppMotion.page,
                        curve: AppMotion.standard,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
