import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/components/kn_background.dart';
import 'package:knowhen/core/theme/components/kn_button.dart';
import 'package:knowhen/core/theme/components/kn_card.dart';
import 'package:knowhen/core/theme/components/kn_icon_button.dart';
import 'package:knowhen/core/theme/components/kn_moon.dart';
import 'package:knowhen/core/theme/components/kn_stat.dart';
import 'package:knowhen/core/theme/components/kn_story_progress.dart';
import 'package:knowhen/core/theme/components/kn_top_bar.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Folha com todos os componentes do redesign, para os goldens de `components_sheet_test.dart`.
class ComponentsSheet extends StatelessWidget {
  const ComponentsSheet({super.key, required this.brightness});

  final Brightness brightness;

  static const size = Size(400, 900);

  /// Fases de uma lunação: nova, crescente, quarto crescente, gibosa, cheia, gibosa, quarto minguante, minguante.
  static const phases = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];

  @override
  Widget build(BuildContext context) {
    final dark = brightness == Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? darkTheme : lightTheme,
      home: Scaffold(
        body: SizedBox.fromSize(
          size: size,
          child: KnBackground(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl, vertical: KnSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KnTopBar(
                    leading: KnIconButton(icon: Icons.close, label: 'Fechar resumo', onPressed: () {}),
                    center: Builder(builder: (context) => Text('Knowhen', style: context.knText.headline)),
                    trailing: KnIconButton(
                      icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      label: 'Mudar o tema',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: KnSpace.md),
                  const KnStoryProgress(count: 5, current: 1, semanticsLabel: 'Cartão 2 de 5'),
                  const SizedBox(height: KnSpace.xl),
                  KnButton(label: 'Descobrir meu céu', icon: Icons.arrow_forward, onPressed: () {}),
                  const SizedBox(height: KnSpace.md),
                  KnButton(label: 'Compartilhar', kind: KnButtonKind.secondary, onPressed: () {}),
                  const SizedBox(height: KnSpace.md),
                  KnButton(label: 'Agora não', kind: KnButtonKind.ghost, onPressed: () {}),
                  const SizedBox(height: KnSpace.md),
                  const KnButton(label: 'Indisponível', onPressed: null),
                  const SizedBox(height: KnSpace.xl),
                  KnCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const KnEyebrow('Tempo de vida'),
                        const SizedBox(height: KnSpace.md),
                        const Row(
                          children: [
                            Expanded(
                              child: KnStat(value: '35', label: 'anos'),
                            ),
                            Expanded(
                              child: KnStat(value: '12.784', label: 'dias'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KnSpace.xl),
                  Wrap(
                    spacing: KnSpace.sm,
                    runSpacing: KnSpace.sm,
                    children: [for (final phase in phases) KnMoon(phase: phase, size: 72)],
                  ),
                  const SizedBox(height: KnSpace.md),
                  const Center(child: KnMoon(phase: 0.4, size: 160)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
