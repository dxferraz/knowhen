import 'package:flutter/material.dart';

import '../theme.dart';

/// Styleguide vivo do design system.
///
/// Não faz parte do fluxo do app: serve para inspecionar tokens e componentes
/// em ambos os temas antes de usá-los em uma tela nova. Para abrir, aponte
/// `home:` do `MaterialApp` para cá ou empurre a rota manualmente:
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const DesignSystemPage()),
/// );
/// ```
class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Design System',
        actions: const [ThemeButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.medium,
          AppSpacing.screenGutter,
          AppSpacing.xxLarge,
        ),
        children: const [
          _Group(title: 'Cor', child: _ColorSpecimen()),
          _Group(title: 'Tipografia', child: _TypeSpecimen()),
          _Group(title: 'Vidro', child: _GlassSpecimen()),
          _Group(title: 'Ações', child: _ButtonSpecimen()),
          _Group(title: 'Conteúdo', child: _ContentSpecimen()),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.overline(title),
          const SizedBox(height: AppSpacing.sMedium),
          child,
        ],
      ),
    );
  }
}

class _ColorSpecimen extends StatelessWidget {
  const _ColorSpecimen();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatches = <String, Color>{
      'primary': colors.primary,
      'secondary': colors.secondary,
      'tertiary': colors.tertiary,
      'accent': colors.accent,
      'success': colors.success,
      'danger': colors.danger,
      'text/1': colors.textPrimary,
      'text/2': colors.textSecondary,
      'text/3': colors.textTertiary,
    };

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (final entry in swatches.entries)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 44,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              AppText.caption(entry.key),
            ],
          ),
      ],
    );
  }
}

class _TypeSpecimen extends StatelessWidget {
  const _TypeSpecimen();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.displayLarge('44 display'),
          SizedBox(height: AppSpacing.small),
          AppText.headline('26 headline'),
          SizedBox(height: AppSpacing.small),
          AppText.title('18 title'),
          SizedBox(height: AppSpacing.small),
          AppText.body('15 body — texto corrido de leitura confortável '
              'sobre uma superfície translúcida.'),
          SizedBox(height: AppSpacing.small),
          AppText.caption('13 caption'),
          SizedBox(height: AppSpacing.small),
          AppText.overline('11 overline'),
        ],
      ),
    );
  }
}

class _GlassSpecimen extends StatelessWidget {
  const _GlassSpecimen();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final level in GlassLevel.values) ...[
          Expanded(
            child: GlassContainer(
              level: level,
              height: 96,
              alignment: Alignment.center,
              child: AppText.caption(level.name, align: TextAlign.center),
            ),
          ),
          if (level != GlassLevel.values.last)
            const SizedBox(width: AppSpacing.sMedium),
        ],
      ],
    );
  }
}

class _ButtonSpecimen extends StatelessWidget {
  const _ButtonSpecimen();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sMedium,
      runSpacing: AppSpacing.sMedium,
      children: [
        GlassButton(label: 'Primária', onPressed: () {}),
        GlassButton(
          label: 'Vidro',
          variant: AppButtonVariant.glass,
          onPressed: () {},
        ),
        GlassButton(
          label: 'Ghost',
          variant: AppButtonVariant.ghost,
          onPressed: () {},
        ),
        const GlassButton(label: 'Desabilitada'),
        GlassIconButton(icon: Icons.arrow_downward_rounded, onPressed: () {}),
        const GlassBadge(label: 'Selo', icon: Icons.auto_awesome),
      ],
    );
  }
}

class _ContentSpecimen extends StatelessWidget {
  const _ContentSpecimen();

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return GlassCard(
      eyebrow: 'Tempo de vida',
      title: 'Você já viveu',
      child: Row(
        children: [
          Expanded(
            child: GlassStatTile(
              value: '12.480',
              label: 'dias',
              gradient: glass.coolGradient,
              compact: true,
            ),
          ),
          Expanded(
            child: GlassStatTile(
              value: '410',
              label: 'meses',
              gradient: glass.brandGradient,
              compact: true,
            ),
          ),
          Expanded(
            child: GlassStatTile(
              value: '34',
              label: 'anos',
              gradient: glass.warmGradient,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}
