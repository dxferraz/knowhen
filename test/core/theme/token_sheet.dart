import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/app_theme.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Folha de tokens do redesign: cores, espaçamentos, raios e as fontes empacotadas (família e peso).
///
/// Serve só ao golden `token_sheet_test.dart`. Cada amostra de fonte fixa `fontFamily` e `fontWeight`
/// explicitamente, de modo que uma fonte ausente, trocada ou com peso errado muda a imagem.
class TokenSheet extends StatelessWidget {
  const TokenSheet({super.key, required this.brightness});

  final Brightness brightness;

  static const size = Size(480, 780);

  static const _fonts = <(String, String, FontWeight)>[
    ('Inter 400', KnFonts.sans, FontWeight.w400),
    ('Inter 600', KnFonts.sans, FontWeight.w600),
    ('Inter 700', KnFonts.sans, FontWeight.w700),
    ('DM Serif Display 400', KnFonts.serif, FontWeight.w400),
    ('Yatra One 400', KnFonts.logo, FontWeight.w400),
    ('Poppins 400', KnFonts.legacyPoppins, FontWeight.w400),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = brightness == Brightness.dark;
    final c = dark ? KnColors.night : KnColors.dawn;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? darkTheme : lightTheme,
      home: Scaffold(
        body: SizedBox.fromSize(
          size: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.bgTop, c.bg],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(KnSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading(c, dark ? 'Noite' : 'Amanhecer'),
                  _section(c, 'CORES'),
                  _swatches(c),
                  _section(c, 'ESPAÇAMENTOS'),
                  _spacing(c),
                  _section(c, 'RAIOS'),
                  _radii(c),
                  _section(c, 'FONTES EMPACOTADAS'),
                  for (final f in _fonts) _fontSample(c, f.$1, f.$2, f.$3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(KnColors c, String name) {
    return Text(name, style: KnTextStyles.from(c).title);
  }

  Widget _section(KnColors c, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: KnSpace.lg, bottom: KnSpace.sm),
      child: Text(label, style: KnTextStyles.from(c).eyebrow),
    );
  }

  Widget _swatches(KnColors c) {
    final text = KnTextStyles.from(c);
    return Wrap(
      spacing: KnSpace.sm,
      runSpacing: KnSpace.sm,
      children: [
        for (final role in c.roles.entries)
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: role.value,
                    borderRadius: BorderRadius.circular(KnRadius.sm / 2),
                    border: Border.all(color: c.outline),
                  ),
                ),
                const SizedBox(height: 2),
                Text(role.key, style: text.caption.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.clip),
              ],
            ),
          ),
      ],
    );
  }

  Widget _spacing(KnColors c) {
    final text = KnTextStyles.from(c);
    const steps = {
      'xs': KnSpace.xs,
      'sm': KnSpace.sm,
      'md': KnSpace.md,
      'lg': KnSpace.lg,
      'xl': KnSpace.xl,
      'xxl': KnSpace.xxl,
      'xxxl': KnSpace.xxxl,
    };
    return Column(
      children: [
        for (final s in steps.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text('${s.key} ${s.value.toInt()}', style: text.caption.copyWith(fontSize: 11)),
                ),
                Container(width: s.value, height: 8, color: c.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _radii(KnColors c) {
    final text = KnTextStyles.from(c);
    const radii = {'sm 12': KnRadius.sm, 'md 20': KnRadius.md, 'lg 28': KnRadius.lg, 'pill': KnRadius.pill};
    return Row(
      children: [
        for (final r in radii.entries)
          Padding(
            padding: const EdgeInsets.only(right: KnSpace.lg),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.outline),
                    borderRadius: BorderRadius.circular(r.value),
                  ),
                ),
                const SizedBox(height: 2),
                Text(r.key, style: text.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _fontSample(KnColors c, String label, String family, FontWeight weight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KnSpace.xs),
      child: Text(
        '$label — Céu de Nascimento 0123',
        style: TextStyle(fontFamily: family, fontWeight: weight, fontSize: 20, height: 1.3, color: c.ink),
      ),
    );
  }
}
