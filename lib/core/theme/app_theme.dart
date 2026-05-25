import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/widgets_theme.dart';

const primaryColor = Color(0xFF3B82F6);
const accentColor = Color(0xFF10B981);
const secondaryColor = Color(0xFF10B981);
const tertiaryColor = Color(0xFFF59E0B);
const complementaryColor = Color(0xFFF59E0B);
const textColor = Color(0xFF0F172A);
const backgroundColor = Color(0xFFF8FAFC);
const errorColor = Color(0xFFEF4444);

class LightAppColors {
  static const primary = Color(0xFF3B82F6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE0F2FE);
  static const onPrimaryContainer = Color(0xFF0369A1);
  
  static const secondary = Color(0xFF10B981);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD1FAE5);
  static const onSecondaryContainer = Color(0xFF065F46);

  static const tertiary = Color(0xFFF59E0B);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFFEF3C7);
  static const onTertiaryContainer = Color(0xFF78350F);

  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF475569);
  static const background = Color(0xFFF8FAFC);
  static const error = Color(0xFFEF4444);
}

class DarkAppColors {
  static const primary = Color(0xFF60A5FA);
  static const onPrimary = Color(0xFF0F172A);
  static const primaryContainer = Color(0xFF1E293B);
  static const onPrimaryContainer = Color(0xFFE2E8F0);

  static const secondary = Color(0xFF34D399);
  static const onSecondary = Color(0xFF064E3B);
  static const secondaryContainer = Color(0xFF064E3B);
  static const onSecondaryContainer = Color(0xFFA7F3D0);

  static const tertiary = Color(0xFFFBBF24);
  static const onTertiary = Color(0xFF78350F);
  static const tertiaryContainer = Color(0xFF78350F);
  static const onTertiaryContainer = Color(0xFFFDE68A);

  static const text = Color(0xFFF8FAFC);
  static const textMuted = Color(0xFF94A3B8);
  static const background = Color(0xFF0F172A);
  static const error = Color(0xFFF87171);
}

const ColorScheme customLightScheme = ColorScheme(
  brightness: Brightness.light,
  surface: LightAppColors.background,
  onSurface: LightAppColors.text,
  onSurfaceVariant: LightAppColors.textMuted,
  primary: LightAppColors.primary,
  onPrimary: LightAppColors.onPrimary,
  primaryContainer: LightAppColors.primaryContainer,
  onPrimaryContainer: LightAppColors.onPrimaryContainer,
  secondary: LightAppColors.secondary,
  onSecondary: LightAppColors.onSecondary,
  secondaryContainer: LightAppColors.secondaryContainer,
  onSecondaryContainer: LightAppColors.onSecondaryContainer,
  tertiary: LightAppColors.tertiary,
  onTertiary: LightAppColors.onTertiary,
  tertiaryContainer: LightAppColors.tertiaryContainer,
  onTertiaryContainer: LightAppColors.onTertiaryContainer,
  error: LightAppColors.error,
  onError: LightAppColors.onPrimary,
);

const ColorScheme customDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  surface: DarkAppColors.background,
  onSurface: DarkAppColors.text,
  onSurfaceVariant: DarkAppColors.textMuted,
  primary: DarkAppColors.primary,
  onPrimary: DarkAppColors.onPrimary,
  primaryContainer: DarkAppColors.primaryContainer,
  onPrimaryContainer: DarkAppColors.onPrimaryContainer,
  secondary: DarkAppColors.secondary,
  onSecondary: DarkAppColors.onSecondary,
  secondaryContainer: DarkAppColors.secondaryContainer,
  onSecondaryContainer: DarkAppColors.onSecondaryContainer,
  tertiary: DarkAppColors.tertiary,
  onTertiary: DarkAppColors.onTertiary,
  tertiaryContainer: DarkAppColors.tertiaryContainer,
  onTertiaryContainer: DarkAppColors.onTertiaryContainer,
  error: DarkAppColors.error,
  onError: DarkAppColors.onPrimary,
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: customLightScheme,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: customLightScheme.surface,
  appBarTheme: CustomAppBarTheme.lightTheme(),
  bottomSheetTheme: BottomSheetTheme.lightTheme(),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: LightAppColors.background,
    dayPeriodColor: LightAppColors.primary,
    dayPeriodTextColor: LightAppColors.onPrimary,
    hourMinuteColor: LightAppColors.primaryContainer,
    hourMinuteTextColor: LightAppColors.onPrimaryContainer,
    dialHandColor: LightAppColors.primary,
    cancelButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: LightAppColors.text,
    ),
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: LightAppColors.secondary,
      foregroundColor: LightAppColors.onSecondary,
    ),
    helpTextStyle: const TextStyle(
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
  scaffoldBackgroundColor: customDarkScheme.surface,
  appBarTheme: CustomAppBarTheme.darkTheme(),
  bottomSheetTheme: BottomSheetTheme.darkTheme(),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: DarkAppColors.background,
    dayPeriodColor: DarkAppColors.primary,
    dayPeriodTextColor: DarkAppColors.onPrimary,
    hourMinuteColor: DarkAppColors.primaryContainer,
    hourMinuteTextColor: DarkAppColors.onPrimaryContainer,
    dialHandColor: DarkAppColors.primary,
    cancelButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: DarkAppColors.text,
    ),
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: DarkAppColors.secondary,
      foregroundColor: DarkAppColors.onSecondary,
    ),
    helpTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    timeSelectorSeparatorColor: WidgetStatePropertyAll(DarkAppColors.text),
  ),
);
