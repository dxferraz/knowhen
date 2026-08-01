import 'package:flutter/material.dart';

import 'glass_theme.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_palette.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

export 'context_extensions.dart';
export 'glass_theme.dart';
export 'tokens/app_colors.dart';
export 'tokens/app_gradients.dart';
export 'tokens/app_motion.dart';
export 'tokens/app_palette.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_typography.dart';

/// Monta o `ThemeData` a partir dos design tokens.
///
/// Nada de valor literal aqui: este arquivo só **compõe**. Cor vem de
/// [AppColors], texto de [AppTypography], vidro de [GlassTheme].
ThemeData buildAppTheme(Brightness brightness) {
  final AppColors colors = AppColors.of(brightness);
  final ColorScheme scheme = colors.toColorScheme();
  final TextTheme textTheme = AppTypography.textTheme(colors);
  final GlassTheme glass = GlassTheme.of(brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    fontFamily: AppTypography.bodyFamily,
    extensions: <ThemeExtension<dynamic>>[glass],

    // A cor sólida existe como fallback: a cena real é a aurora
    // (ver `GlassScaffold`), pintada atrás do Scaffold transparente.
    scaffoldBackgroundColor: colors.canvas,
    canvasColor: colors.canvas,
    splashColor: colors.primary.withValues(alpha: 0.08),
    highlightColor: colors.primary.withValues(alpha: 0.06),
    dividerColor: glass.dividerColor,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
    ),

    iconTheme: IconThemeData(color: colors.textSecondary, size: 22),

    dividerTheme: DividerThemeData(
      color: glass.dividerColor,
      thickness: 0.5,
      space: AppSpacing.large,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxLarge),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xLarge),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colors.textInverse,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.medium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      circularTrackColor: colors.primary.withValues(alpha: 0.15),
      linearTrackColor: colors.primary.withValues(alpha: 0.15),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      textStyle: textTheme.labelMedium?.copyWith(color: colors.textInverse),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: AppTypography.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        textStyle: AppTypography.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    ),

    timePickerTheme: TimePickerThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xLarge),
      ),
      dayPeriodColor: colors.primary,
      dayPeriodTextColor: colors.onPrimary,
      dayPeriodBorderSide: BorderSide(color: colors.outline),
      hourMinuteColor: colors.primarySoft,
      hourMinuteTextColor: colors.onPrimarySoft,
      hourMinuteTextStyle: AppTypography.numericMedium.copyWith(fontSize: 32),
      dialBackgroundColor: scheme.surfaceContainerHighest,
      dialHandColor: colors.primary,
      dialTextColor: colors.textPrimary,
      entryModeIconColor: colors.textSecondary,
      helpTextStyle: textTheme.titleMedium,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.textSecondary,
        textStyle: AppTypography.labelLarge,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: AppTypography.labelLarge,
      ),
      timeSelectorSeparatorColor:
          WidgetStatePropertyAll<Color>(colors.textPrimary),
    ),
  );
}

ThemeData lightTheme = buildAppTheme(Brightness.light);
ThemeData darkTheme = buildAppTheme(Brightness.dark);

// ---------------------------------------------------------------------------
// Compatibilidade com o tema anterior.
//
// Mantido para não quebrar imports existentes. Em código novo use
// `context.colors` / `context.glass`.
// ---------------------------------------------------------------------------

const primaryColor = AppPalette.iris500;
const accentColor = AppPalette.aqua500;
const secondaryColor = AppPalette.aqua500;
const tertiaryColor = AppPalette.solar500;
const complementaryColor = AppPalette.nebula500;
const textColor = AppPalette.ink900;
const backgroundColor = AppPalette.dawnAlt;
const errorColor = AppPalette.danger500;

class LightAppColors {
  static const primary = AppPalette.iris500;
  static const onPrimary = AppPalette.white;
  static const primaryContainer = AppPalette.iris100;
  static const onPrimaryContainer = AppPalette.iris800;
  static const secondary = AppPalette.aqua600;
  static const onSecondary = AppPalette.white;
  static const secondaryContainer = AppPalette.aqua100;
  static const onSecondaryContainer = AppPalette.aqua800;
  static const tertiary = AppPalette.solar600;
  static const onTertiary = AppPalette.white;
  static const tertiaryContainer = AppPalette.solar100;
  static const onTertiaryContainer = AppPalette.solar800;
  static const text = AppPalette.ink900;
  static const textMuted = AppPalette.ink600;
  static const background = AppPalette.dawnAlt;
  static const error = AppPalette.danger500;
}

class DarkAppColors {
  static const primary = AppPalette.iris300;
  static const onPrimary = AppPalette.ink950;
  static const primaryContainer = AppPalette.iris900;
  static const onPrimaryContainer = AppPalette.iris100;
  static const secondary = AppPalette.aqua300;
  static const onSecondary = AppPalette.aqua900;
  static const secondaryContainer = AppPalette.aqua900;
  static const onSecondaryContainer = AppPalette.aqua100;
  static const tertiary = AppPalette.solar300;
  static const onTertiary = AppPalette.solar900;
  static const tertiaryContainer = AppPalette.solar900;
  static const onTertiaryContainer = AppPalette.solar100;
  static const text = Color(0xFFF4F3FF);
  static const textMuted = Color(0xFFA9A5C9);
  static const background = AppPalette.night;
  static const error = AppPalette.danger400;
}
