import 'package:flutter/material.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/services/analytics_service.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';
import 'package:knowhen/core/theme/widgets/app_logo.dart';
import 'package:knowhen/core/theme/widgets/theme_button.dart';
import 'package:knowhen/features/birthdate/presentation/pages/birthdate_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Primeira abertura: uma tela só, com as quatro revelações que o usuário vai receber (DXF-9, 4.1).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  /// Lua crescente fina: já sugere o céu sem cravar uma fase.
  static const double _moonPhase = 0.18;

  @override
  void initState() {
    super.initState();
    final analytics = context.read<AnalyticsService>();
    analytics.logOnboardingStarted();
    analytics.logOnboardingStepViewed(0);
  }

  Future<void> _start() async {
    final analytics = context.read<AnalyticsService>();
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    analytics.logOnboardingCompleted();
    navigator.push(MaterialPageRoute(builder: (_) => const BirthdatePage()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final text = context.knText;
    // Em telas baixas (celulares pequenos) a lua encolhe para caberem mais revelações sem rolar.
    final compact = MediaQuery.sizeOf(context).height < 700;

    final reveals = [
      (Icons.hourglass_bottom_rounded, l10n.onboardingRevealLife),
      (Icons.favorite_border_rounded, l10n.onboardingRevealConception),
      (Icons.nightlight_round, l10n.onboardingRevealMoon),
      (Icons.history_edu_rounded, l10n.onboardingRevealFact),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: KnBackground(
        child: SafeArea(
          child: Column(
            children: [
              KnTopBar(center: const AppLogo(), trailing: const ThemeButton()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: compact ? KnSpace.md : KnSpace.xl),
                      Center(
                        child: KnMoon(
                          phase: _moonPhase,
                          size: compact ? 88 : 132,
                        ),
                      ),
                      SizedBox(height: compact ? KnSpace.lg : KnSpace.xl),
                      Semantics(
                        header: true,
                        child: Text(l10n.onboardingTitle, style: text.title),
                      ),
                      const SizedBox(height: KnSpace.md),
                      Text(l10n.onboardingIntro, style: text.bodyMuted),
                      const SizedBox(height: KnSpace.lg),
                      for (final (icon, label) in reveals)
                        _RevealRow(icon: icon, label: label),
                      const SizedBox(height: KnSpace.lg),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KnSpace.xl,
                  KnSpace.sm,
                  KnSpace.xl,
                  KnSpace.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KnButton(
                      label: l10n.start,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _start,
                    ),
                    const SizedBox(height: KnSpace.sm),
                    Text(
                      l10n.onboardingTakesLess,
                      style: text.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealRow extends StatelessWidget {
  const _RevealRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KnSpace.sm),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.surfaceHi,
                  borderRadius: BorderRadius.circular(KnRadius.sm),
                ),
                child: Icon(icon, size: 20, color: c.accentText),
              ),
            ),
            const SizedBox(width: KnSpace.md),
            Expanded(child: Text(label, style: context.knText.label)),
          ],
        ),
      ),
    );
  }
}
