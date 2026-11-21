import 'package:flutter/material.dart';

/// Cores do redesign "Céu de Nascimento" (DXF-9, seção 2.1).
///
/// Dois conjuntos: [night] (escuro, padrão) e [dawn] (claro). Os contrastes de
/// cada tema foram calculados separadamente e estão cobertos em
/// `test/core/theme/kn_colors_test.dart`.
@immutable
class KnColors extends ThemeExtension<KnColors> {
  const KnColors({
    required this.brightness,
    required this.bgTop,
    required this.bg,
    required this.surface,
    required this.surfaceHi,
    required this.outline,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.onPrimary,
    required this.accentText,
    required this.lavender,
    required this.moon,
    required this.moonShadow,
    required this.danger,
  });

  final Brightness brightness;

  /// Topo do gradiente de fundo; [bg] é a base.
  final Color bgTop;
  final Color bg;

  /// Cartões.
  final Color surface;

  /// Botão secundário, ícones, chips.
  final Color surfaceHi;

  /// Bordas de 1 px.
  final Color outline;

  /// Texto principal e secundário.
  final Color ink;
  final Color inkMuted;

  /// CTA principal e progresso.
  final Color primary;
  final Color onPrimary;

  /// Eyebrows, ícones e destaques em texto.
  final Color accentText;

  /// Foco, toggles, carregamento.
  final Color lavender;

  /// Lua (decorativo) e sua parte sombreada.
  final Color moon;
  final Color moonShadow;

  final Color danger;

  bool get isDark => brightness == Brightness.dark;

  /// Tema escuro (padrão): céu noturno.
  static const night = KnColors(
    brightness: Brightness.dark,
    bgTop: Color(0xFF1C2154),
    bg: Color(0xFF0B0F2A),
    surface: Color(0xFF151A3C),
    surfaceHi: Color(0xFF1F2550),
    outline: Color(0xFF2C3366),
    ink: Color(0xFFF5F1E8),
    inkMuted: Color(0xFFB3B7D4),
    primary: Color(0xFFF2C46D),
    onPrimary: Color(0xFF1B1405),
    accentText: Color(0xFFF2C46D),
    lavender: Color(0xFFB9B4FF),
    moon: Color(0xFFF6E7C1),
    moonShadow: Color(0xFF262C5C),
    danger: Color(0xFFFF8A8A),
  );

  /// Tema claro: amanhecer.
  static const dawn = KnColors(
    brightness: Brightness.light,
    bgTop: Color(0xFFEDE9FF),
    bg: Color(0xFFFBF8F3),
    surface: Color(0xFFFFFFFF),
    surfaceHi: Color(0xFFF3EFE7),
    outline: Color(0xFFE4DDD0),
    ink: Color(0xFF15172E),
    inkMuted: Color(0xFF535873),
    primary: Color(0xFF2E2A85),
    onPrimary: Color(0xFFFFFFFF),
    accentText: Color(0xFF8A5800),
    lavender: Color(0xFF4F48C7),
    moon: Color(0xFFE2B655),
    moonShadow: Color(0xFFDCD6EA),
    danger: Color(0xFFB42318),
  );

  static KnColors forBrightness(Brightness brightness) => brightness == Brightness.dark ? night : dawn;

  /// Cores do tema ativo. Sem a extensão registrada (ex.: um `MaterialApp`
  /// simples em teste), cai na paleta do brilho do tema.
  static KnColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<KnColors>() ?? forBrightness(theme.brightness);
  }

  /// Rótulo para ler a cor de um papel por nome (folha de tokens e testes).
  Map<String, Color> get roles => {
    'bgTop': bgTop,
    'bg': bg,
    'surface': surface,
    'surfaceHi': surfaceHi,
    'outline': outline,
    'ink': ink,
    'inkMuted': inkMuted,
    'primary': primary,
    'onPrimary': onPrimary,
    'accentText': accentText,
    'lavender': lavender,
    'moon': moon,
    'moonShadow': moonShadow,
    'danger': danger,
  };

  @override
  KnColors copyWith({
    Brightness? brightness,
    Color? bgTop,
    Color? bg,
    Color? surface,
    Color? surfaceHi,
    Color? outline,
    Color? ink,
    Color? inkMuted,
    Color? primary,
    Color? onPrimary,
    Color? accentText,
    Color? lavender,
    Color? moon,
    Color? moonShadow,
    Color? danger,
  }) {
    return KnColors(
      brightness: brightness ?? this.brightness,
      bgTop: bgTop ?? this.bgTop,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHi: surfaceHi ?? this.surfaceHi,
      outline: outline ?? this.outline,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accentText: accentText ?? this.accentText,
      lavender: lavender ?? this.lavender,
      moon: moon ?? this.moon,
      moonShadow: moonShadow ?? this.moonShadow,
      danger: danger ?? this.danger,
    );
  }

  @override
  KnColors lerp(ThemeExtension<KnColors>? other, double t) {
    if (other is! KnColors) return this;
    return KnColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHi: Color.lerp(surfaceHi, other.surfaceHi, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      moon: Color.lerp(moon, other.moon, t)!,
      moonShadow: Color.lerp(moonShadow, other.moonShadow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
