import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../tokens/app_typography.dart';
import 'app_text.dart';

/// ---------------------------------------------------------------------------
/// Camada de compatibilidade.
///
/// Estes widgets existiam antes do design system e foram reescritos sobre a
/// nova escala tipográfica, para que telas antigas continuem compilando e já
/// herdem o visual novo.
///
/// **Em código novo use [AppText]** — ele expressa o papel do texto
/// (`AppText.headline`, `AppText.body`, …) em vez de um nível arbitrário.
/// ---------------------------------------------------------------------------

class PrimaryH1 extends StatelessWidget {
  const PrimaryH1(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.display(text, align: textAlign, color: color);
}

class PrimaryH2 extends StatelessWidget {
  const PrimaryH2(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.headline(text, align: textAlign, color: color);
}

class PrimaryH3 extends StatelessWidget {
  const PrimaryH3(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.headlineSmall(text, align: textAlign, color: color);
}

class PrimaryH4 extends StatelessWidget {
  const PrimaryH4(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.subtitle(text, align: textAlign, color: color);
}

class SecondaryH1 extends StatelessWidget {
  const SecondaryH1(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppText.display(text,
      align: textAlign, color: color ?? context.colors.secondary);
}

class SecondaryH2 extends StatelessWidget {
  const SecondaryH2(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppText.headline(text,
      align: textAlign, color: color ?? context.colors.secondary);
}

class SecondaryH3 extends StatelessWidget {
  const SecondaryH3(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppText.headlineSmall(text,
      align: textAlign, color: color ?? context.colors.secondary);
}

class SecondaryH4 extends StatelessWidget {
  const SecondaryH4(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppText.title(text,
      align: textAlign, color: color ?? context.colors.secondary);
}

class PrimaryParagraphL extends StatelessWidget {
  const PrimaryParagraphL(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.bodyLarge(text, align: textAlign, color: color);
}

class PrimaryParagraphM extends StatelessWidget {
  const PrimaryParagraphM(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.bodyLarge(text, align: textAlign, color: color);
}

class PrimaryParagraphS extends StatelessWidget {
  const PrimaryParagraphS(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.body(text, align: textAlign, color: color);
}

class SecondaryParagraphL extends StatelessWidget {
  const SecondaryParagraphL(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.bodyLarge(text, align: textAlign, color: color);
}

class PrimaryCaption extends StatelessWidget {
  const PrimaryCaption(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.subtitle(text, align: textAlign, color: color);
}

class SecondaryCaption extends StatelessWidget {
  const SecondaryCaption(this.text,
      {super.key, this.textAlign = TextAlign.start, this.color});

  final String text;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      AppText.caption(text, align: textAlign, color: color);
}

/// Trecho colorido de um texto rico.
class RichTextEntity {
  RichTextEntity(this.text, {required this.color});

  final String text;
  final Color color;
}

class PrimaryRichText extends StatelessWidget {
  const PrimaryRichText(this.text,
      {super.key, this.textAlign = TextAlign.start});

  final List<RichTextEntity> text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTypography.bodyLarge;
    return Text.rich(
      TextSpan(
        children: [
          for (final entity in text)
            TextSpan(text: entity.text, style: base.copyWith(color: entity.color)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

class SecondaryRichText extends StatelessWidget {
  const SecondaryRichText(this.text,
      {super.key, this.textAlign = TextAlign.start});

  final List<RichTextEntity> text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTypography.titleLarge;
    return Text.rich(
      TextSpan(
        children: [
          for (final entity in text)
            TextSpan(text: entity.text, style: base.copyWith(color: entity.color)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
