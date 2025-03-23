import 'package:flutter/material.dart';

const primaryColor = Color(0xFF9ac1f0);
const accentColor = Color(0xFF72fa93);
const secondaryColor = Color(0xFFa0e548);
const tertiaryColor = Color(0xFFE45F2B);
const complementaryColor = Color(0xFFf6c445);
const textColor = Color(0xFF14142b);
const backgroundColor = Color(0xFFebf3fc);
const errorColor = Color(0xFFFF3B30);

class LightAppColors {
  static const primary = Color(0xFF72A9F0);
  static const accent = Color(0xFF72fa93);
  static const secondary = Color(0xFFa0e548);
  static const tertiary = Color(0xFFE45F2B);
  static const complementary = Color(0xFFf6c445);
  static const text = Color(0xFF14142b);
  static const background = Color(0xFFD6E8FC);
  static const error = Color(0xFFFF3B30);
}

class DarkAppColors {
  static const primary = Color(0xFF9ac1f0);
  static const accent = Color(0xFF72fa93);
  static const secondary = Color(0xFFa0e548);
  static const tertiary = Color(0xFFE45F2B);
  static const complementary = Color(0xFFf6c445);
  static const text = Color(0xFFebf3fc);
  static const background = Color(0xFF14142b);
  static const error = Color(0xFFFF3B30);
}

const ColorScheme customLightScheme = ColorScheme(
  brightness: Brightness.light,
  surface: LightAppColors.background,
  onSurface: LightAppColors.text,
  onSurfaceVariant: LightAppColors.secondary,
  primary: LightAppColors.primary,
  onPrimary: LightAppColors.text,
  secondary: LightAppColors.tertiary,
  onSecondary: LightAppColors.background,
  tertiary: LightAppColors.complementary,
  onTertiary: LightAppColors.text,
  error: LightAppColors.error,
  onError: LightAppColors.background,
);

const ColorScheme customDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  surface: DarkAppColors.background,
  onSurface: DarkAppColors.text,
  onSurfaceVariant: DarkAppColors.complementary,
  primary: DarkAppColors.primary,
  onPrimary: DarkAppColors.background,
  secondary: DarkAppColors.secondary,
  onSecondary: DarkAppColors.background,
  tertiary: DarkAppColors.tertiary,
  onTertiary: DarkAppColors.background,
  error: DarkAppColors.error,
  onError: DarkAppColors.background,
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: customLightScheme,
  fontFamily: 'Inter',
  timePickerTheme: TimePickerThemeData(
    backgroundColor: LightAppColors.background,
    dayPeriodColor: LightAppColors.tertiary,
    dayPeriodTextColor: LightAppColors.background,
    hourMinuteColor: LightAppColors.tertiary,
    hourMinuteTextColor: LightAppColors.background,
    dialHandColor: LightAppColors.tertiary,
    cancelButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: LightAppColors.text,
    ),
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: LightAppColors.secondary,
      foregroundColor: LightAppColors.text,
    ),
    helpTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    timeSelectorSeparatorColor: WidgetStatePropertyAll(LightAppColors.text),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: customDarkScheme,
  fontFamily: 'Inter',
  timePickerTheme: TimePickerThemeData(
    backgroundColor: DarkAppColors.background,
    dayPeriodColor: DarkAppColors.secondary,
    dayPeriodTextColor: DarkAppColors.background,
    hourMinuteColor: DarkAppColors.secondary,
    hourMinuteTextColor: DarkAppColors.background,
    dialHandColor: DarkAppColors.secondary,
    cancelButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: DarkAppColors.text,
    ),
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: DarkAppColors.complementary,
      foregroundColor: DarkAppColors.background,
    ),
    helpTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    timeSelectorSeparatorColor: WidgetStatePropertyAll(DarkAppColors.text),
  ),
);
