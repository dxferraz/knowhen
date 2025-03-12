import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knowhen/core/theme/app_theme.dart';

class PrimaryH1 extends StatelessWidget {
  const PrimaryH1({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryH2 extends StatelessWidget {
  const PrimaryH2({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryH3 extends StatelessWidget {
  const PrimaryH3({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryH4 extends StatelessWidget {
  const PrimaryH4({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class SecondaryH1 extends StatelessWidget {
  const SecondaryH1({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.poppins().fontFamily,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class SecondaryH2 extends StatelessWidget {
  const SecondaryH2({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.poppins().fontFamily,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class SecondaryH3 extends StatelessWidget {
  const SecondaryH3({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.firaCode().fontFamily,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class SecondaryH4 extends StatelessWidget {
  const SecondaryH4({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.firaCode().fontFamily,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryParagraphL extends StatelessWidget {
  const PrimaryParagraphL({super.key, required this.text, this.textAlign = TextAlign.start, this.color = textColor});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryParagraphM extends StatelessWidget {
  const PrimaryParagraphM({super.key, required this.text, this.textAlign = TextAlign.start, this.color = textColor});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryParagraphS extends StatelessWidget {
  const PrimaryParagraphS({super.key, required this.text, this.textAlign = TextAlign.start, this.color = textColor});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class SecondaryParagraphL extends StatelessWidget {
  const SecondaryParagraphL({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: GoogleFonts.firaCode().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class PrimaryCaption extends StatelessWidget {
  const PrimaryCaption({super.key, required this.text, this.textAlign = TextAlign.start, this.color = secondaryColor});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class SecondaryCaption extends StatelessWidget {
  const SecondaryCaption({super.key, required this.text, required this.textAlign, required this.color});

  final String text;
  final TextAlign textAlign;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.5,
      ),
    );
  }
}

class RichTextEntity {
  final String text;
  final Color color;

  RichTextEntity({required this.text, required this.color});
}

class PrimaryRichText extends StatelessWidget {
  final List<RichTextEntity> text;
  final TextAlign textAlign;

  const PrimaryRichText({super.key, required this.text, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    TextSpan buildTextSpan(String text, Color color) {
      return TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.5,
          wordSpacing: 1.5,
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: List.generate(text.length, (index) => buildTextSpan(text[index].text, text[index].color), growable: false),
      ),
    );
  }
}
