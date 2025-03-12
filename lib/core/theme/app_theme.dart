import 'package:flutter/material.dart';

class LightAppColors {
  static const primary = Color(0xFF007AFF);
  static const secondary = Color(0xFF34C759);
  static const tertiary = Color(0xFFFF9500);
  static const text = Color(0xFF1C1C1E);
  static const background = Color(0xFFF5F5F7);
  static const error = Color(0xFFFF3B30);
}

class DarkAppColors {
  static const primary = Color(0xFF0A84FF);
  static const secondary = Color(0xFF30D158);
  static const tertiary = Color(0xFFFF9F0A);
  static const text = Color(0xFFF2F2F7);
  static const background = Color(0xFF1C1C1E);
  static const error = Color(0xFFFF3B30);
}

const primaryColor = Color(0xFF007AFF);
const secondaryColor = Color(0xFF34C759);
const tertiaryColor = Color(0xFFFF9500);
const textColor = Color(0xFF1C1C1E);
const backgroundColor = Color(0xFFF5F5F7);
const errorColor = Color(0xFFFF3B30);

const ColorScheme customLightScheme = ColorScheme(
  brightness: Brightness.light,
  surface: Color(0xFFF5F5F7),
  onSurface: Color(0xFF1C1C1E),
  primary: Color(0xFF007AFF),
  onPrimary: Color(0xFFF5F5F7),
  secondary: Color(0xFF34C759),
  onSecondary: Color(0xFFF5F5F7),
  tertiary: Color(0xFFFF9500),
  onTertiary: Color(0xFFF5F5F7),
  error: Color(0xFFFF3B30),
  onError: Color(0xFFF5F5F7),
);

const ColorScheme customDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  surface: Color(0xFF1C1C1E),
  onSurface: Color(0xFFF2F2F7),
  primary: Color(0xFF0A84FF),
  onPrimary: Color(0xFFF5F5F7),
  secondary: Color(0xFF30D158),
  onSecondary: Color(0xFFF5F5F7),
  tertiary: Color(0xFFFF9F0A),
  onTertiary: Color(0xFFF5F5F7),
  error: Color(0xFFFF3B30),
  onError: Color(0xFFF5F5F7),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: customLightScheme,
  fontFamily: 'Inter',
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: customDarkScheme,
  fontFamily: 'Inter',
);
