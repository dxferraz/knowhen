import 'package:flutter/material.dart';
import 'package:knowhen/core/functions/date_text.dart';
import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Tela de espera do resumo (DXF-9, 4.3): "Olhando o céu de…" com a lua crescendo até a fase do nascimento e
/// três passos marcados conforme ficam prontos. Os dois primeiros são locais e se marcam sozinhos; o do fato
/// histórico (rede) fica pendente até o resumo abrir. O anúncio não aparece aqui.
class SummaryReveal extends StatefulWidget {
  const SummaryReveal({super.key, required this.birthDate});

  final DateTime birthDate;

  static const Duration duration = Duration(milliseconds: 1400);

  @override
  State<SummaryReveal> createState() => _SummaryRevealState();
}

class _SummaryRevealState extends State<SummaryReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: SummaryReveal.duration);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Com movimento reduzido a lua já aparece na fase final e os passos locais já nascem marcados.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.kn;
    final text = context.knText;
    final target = getMoonPhaseFraction(widget.birthDate);

    return Scaffold(
      backgroundColor: c.bg,
      body: KnBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(KnSpace.xl),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, _) => KnMoon(
                          phase: target * Curves.easeOutCubic.transform(_controller.value),
                          size: 140,
                          southernHemisphere: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: KnSpace.xxl),
                    Text(l10n.revealTitle(DateText.dayMonthYear(widget.birthDate)), style: text.title),
                    const SizedBox(height: KnSpace.xl),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Step(label: l10n.revealStepLife, done: _controller.value >= 0.4),
                          _Step(label: l10n.revealStepMoon, done: _controller.value >= 0.8),
                          _Step(label: l10n.revealStepFact, done: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.kn;
    // O indicador girando não respeita `disableAnimations`; com movimento reduzido o passo pendente é um ícone parado.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KnSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: 24,
            child: done
                ? Icon(Icons.check_circle_rounded, color: c.accentText, size: 24)
                : reduceMotion
                ? Icon(Icons.more_horiz_rounded, color: c.lavender, size: 24)
                : Padding(
                    padding: const EdgeInsets.all(3),
                    child: CircularProgressIndicator(strokeWidth: 2, color: c.lavender),
                  ),
          ),
          const SizedBox(width: KnSpace.md),
          Expanded(child: Text(label, style: done ? context.knText.body : context.knText.bodyMuted)),
        ],
      ),
    );
  }
}
