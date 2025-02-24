import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/widgets_theme.dart';
import 'package:knowhen/core/theme/constants/app_colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  bottomSheetTheme: BottomSheetTheme.lightTheme(),
    appBarTheme: CustomAppBarTheme.lightTheme(),
    scaffoldBackgroundColor: LightAppColors.background,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF2D3436)),
    ),
    datePickerTheme: DatePickerThemeData(
      dividerColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
    ),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF6C5CE7),
    secondary: Color(0xFFA29BFE),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSurface: Color(0xFF2D3436),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  bottomSheetTheme: BottomSheetTheme.darkTheme(),
    appBarTheme: CustomAppBarTheme.darkTheme(),
    scaffoldBackgroundColor: DarkAppColors.background,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
    ),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFF4C9EFF),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSurface: Color(0xFFE0E0E0),
  ),
);
