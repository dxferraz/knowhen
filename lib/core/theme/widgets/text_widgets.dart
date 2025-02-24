import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle headline1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).textTheme.displayLarge?.color,
    );
  }

  static TextStyle headline2(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).textTheme.displayMedium?.color,
    );
  }

  static TextStyle subtitle1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).textTheme.titleMedium?.color,
    );
  }

  static TextStyle bodyText1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).textTheme.bodySmall?.color,
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final TextStyle Function(BuildContext, {Color? color}) style;
  final Color? color;
  final TextAlign? textAlign;

  const AppText({
    super.key,
    required this.text,
    required this.style,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style(context, color: color),
      textAlign: textAlign,
    );
  }
}
