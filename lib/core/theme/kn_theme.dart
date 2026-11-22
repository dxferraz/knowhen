import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowhen/core/theme/tokens/kn_colors.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Monta o [ThemeData] completo do "Céu de Nascimento" a partir de [colors].
ThemeData buildKnTheme(KnColors colors) {
  final c = colors;
  final text = KnTextStyles.from(c);
  final dark = c.isDark;
  final onDanger = dark ? c.bg : c.surface;

  final scheme = ColorScheme(
    brightness: c.brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.surfaceHi,
    onPrimaryContainer: c.ink,
    secondary: c.lavender,
    onSecondary: dark ? c.bg : c.surface,
    secondaryContainer: c.surfaceHi,
    onSecondaryContainer: c.ink,
    tertiary: c.accentText,
    onTertiary: dark ? c.onPrimary : c.surface,
    tertiaryContainer: c.surfaceHi,
    onTertiaryContainer: c.accentText,
    error: c.danger,
    onError: onDanger,
    surface: c.bg,
    onSurface: c.ink,
    onSurfaceVariant: c.inkMuted,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface,
    surfaceContainerHighest: c.surfaceHi,
    outline: c.inkMuted,
    outlineVariant: c.outline,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: c.ink,
    onInverseSurface: c.bg,
    inversePrimary: dark ? c.surfaceHi : c.primary,
    surfaceTint: Colors.transparent,
  );

  const pill = StadiumBorder();
  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(KnRadius.md),
    side: BorderSide(color: c.outline),
  );
  final fieldRadius = BorderRadius.circular(KnRadius.sm);
  final buttonSize = WidgetStatePropertyAll(const Size(KnSize.touchTarget, KnSize.button));
  const buttonPadding = WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: KnSpace.xl));

  Color pickerFg(Set<WidgetState> s) =>
      s.contains(WidgetState.selected) ? c.onPrimary : (s.contains(WidgetState.disabled) ? c.inkMuted : c.ink);
  Color? pickerBg(Set<WidgetState> s) => s.contains(WidgetState.selected) ? c.primary : null;
  final pickerButton = TextButton.styleFrom(
    foregroundColor: c.lavender,
    minimumSize: const Size(KnSize.touchTarget, KnSize.touchTarget),
    textStyle: text.label,
  );
  final inputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: c.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: KnSpace.lg, vertical: KnSpace.lg),
    hintStyle: text.bodyMuted,
    labelStyle: text.caption,
    floatingLabelStyle: text.caption.copyWith(color: c.lavender),
    helperStyle: text.caption,
    errorStyle: text.caption.copyWith(color: c.danger),
    border: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.inkMuted),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.inkMuted),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.lavender, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.danger, width: 2),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    fontFamily: KnFonts.sans,
    textTheme: text.toTextTheme(),
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    focusColor: c.lavender.withValues(alpha: 0.24),
    extensions: [c, text],
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: c.ink,
      titleTextStyle: text.headline,
      iconTheme: IconThemeData(color: c.ink),
      systemOverlayStyle: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.bg,
      ),
    ),
    // A sombra índigo do tema claro (seção 2.3: 6%, blur 24) fica para o PR de componentes, que desenha os cartões.
    cardTheme: CardThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.surfaceHi,
        disabledForegroundColor: c.inkMuted,
        textStyle: text.label.copyWith(fontSize: 16),
        shape: pill,
      ).copyWith(minimumSize: buttonSize, padding: buttonPadding),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.surfaceHi,
        disabledForegroundColor: c.inkMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: text.label.copyWith(fontSize: 16),
        shape: pill,
      ).copyWith(minimumSize: buttonSize, padding: buttonPadding),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        disabledForegroundColor: c.inkMuted,
        side: BorderSide(color: c.outline),
        textStyle: text.label.copyWith(fontSize: 16),
        shape: pill,
      ).copyWith(minimumSize: buttonSize, padding: buttonPadding),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.lavender,
        disabledForegroundColor: c.inkMuted,
        textStyle: text.label.copyWith(fontSize: 16),
        shape: pill,
        minimumSize: const Size(KnSize.touchTarget, KnSize.touchTarget),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.ink,
        disabledForegroundColor: c.inkMuted,
        minimumSize: const Size(KnSize.touchTarget, KnSize.touchTarget),
      ),
    ),
    iconTheme: IconThemeData(color: c.ink),
    inputDecorationTheme: inputDecoration,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.lavender,
      selectionColor: c.lavender.withValues(alpha: 0.4),
      selectionHandleColor: c.lavender,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.lavender,
      linearTrackColor: c.surfaceHi,
      circularTrackColor: Colors.transparent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? (dark ? c.bg : c.surface) : c.inkMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.lavender : c.surfaceHi),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.lavender : c.inkMuted,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: cardShape,
      titleTextStyle: text.headline,
      contentTextStyle: text.body,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalBackgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(KnRadius.lg)),
        side: BorderSide(color: c.outline),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: text.body.copyWith(color: c.bg),
      // O fundo do SnackBar é `ink` (invertido em relação ao tema), então a ação usa o lavender do tema oposto.
      actionTextColor: dark ? KnColors.dawn.lavender : KnColors.night.lavender,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KnRadius.sm)),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: text.caption.copyWith(color: c.bg),
      decoration: BoxDecoration(color: c.ink, borderRadius: BorderRadius.circular(KnRadius.sm)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: cardShape,
      headerBackgroundColor: c.surfaceHi,
      headerForegroundColor: c.ink,
      headerHeadlineStyle: text.title,
      headerHelpStyle: text.eyebrow,
      weekdayStyle: text.caption,
      dayStyle: text.body,
      yearStyle: text.body,
      dayForegroundColor: WidgetStateColor.resolveWith(pickerFg),
      dayBackgroundColor: WidgetStateColor.resolveWith((s) => pickerBg(s) ?? Colors.transparent),
      dayOverlayColor: WidgetStatePropertyAll(c.lavender.withValues(alpha: 0.16)),
      todayForegroundColor: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.accentText,
      ),
      todayBackgroundColor: WidgetStateColor.resolveWith((s) => pickerBg(s) ?? Colors.transparent),
      todayBorder: BorderSide(color: c.accentText),
      yearForegroundColor: WidgetStateColor.resolveWith(pickerFg),
      yearBackgroundColor: WidgetStateColor.resolveWith((s) => pickerBg(s) ?? Colors.transparent),
      yearOverlayColor: WidgetStatePropertyAll(c.lavender.withValues(alpha: 0.16)),
      cancelButtonStyle: pickerButton,
      confirmButtonStyle: pickerButton,
      inputDecorationTheme: inputDecoration,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: c.surface,
      elevation: 0,
      shape: cardShape,
      dialBackgroundColor: c.surfaceHi,
      dialHandColor: c.primary,
      dialTextColor: WidgetStateColor.resolveWith(pickerFg),
      dialTextStyle: text.body,
      hourMinuteColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceHi),
      hourMinuteTextColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? c.onPrimary : c.ink),
      hourMinuteTextStyle: text.display.copyWith(fontSize: 48),
      hourMinuteShape: RoundedRectangleBorder(borderRadius: fieldRadius),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : Colors.transparent,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? c.onPrimary : c.ink),
      dayPeriodTextStyle: text.label,
      dayPeriodBorderSide: BorderSide(color: c.outline),
      dayPeriodShape: RoundedRectangleBorder(borderRadius: fieldRadius),
      entryModeIconColor: c.lavender,
      helpTextStyle: text.eyebrow,
      timeSelectorSeparatorColor: WidgetStatePropertyAll(c.ink),
      timeSelectorSeparatorTextStyle: WidgetStatePropertyAll(text.display.copyWith(fontSize: 48)),
      cancelButtonStyle: pickerButton,
      confirmButtonStyle: pickerButton,
      inputDecorationTheme: inputDecoration,
    ),
  );
}
