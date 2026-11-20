// Protótipo da direção visual "Céu de Nascimento" (DXF-9).
//
// Tokens e componentes de referência para o Engenheiro. Não é código de
// produção: vive em test/ e só é usado pelos capturadores de mockup.
import 'dart:math' as math;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Tokens
// ---------------------------------------------------------------------------

class KnPalette {
  final bool dark;
  final Color bgTop;
  final Color bg;
  final Color surface;
  final Color surfaceHi;
  final Color outline;
  final Color ink;
  final Color inkMuted;
  final Color primary;
  final Color onPrimary;
  final Color accentText;
  final Color moon;
  final Color moonShadow;
  final Color lavender;
  final Color danger;

  const KnPalette({
    required this.dark,
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
    required this.moon,
    required this.moonShadow,
    required this.lavender,
    required this.danger,
  });
}

/// Tema escuro (padrão): céu noturno.
const knNight = KnPalette(
  dark: true,
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
  moon: Color(0xFFF6E7C1),
  moonShadow: Color(0xFF262C5C),
  lavender: Color(0xFFB9B4FF),
  danger: Color(0xFFFF8A8A),
);

/// Tema claro: amanhecer.
const knDawn = KnPalette(
  dark: false,
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
  moon: Color(0xFFE2B655),
  moonShadow: Color(0xFFDCD6EA),
  lavender: Color(0xFF4F48C7),
  danger: Color(0xFFB42318),
);

class KnSpace {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48;
}

class KnRadius {
  static const double sm = 12, md = 20, lg = 28, pill = 999;
}

const String knSans = 'KnInter';
const String knSerif = 'KnSerif';

class KnText {
  static TextStyle display(KnPalette p) =>
      TextStyle(fontFamily: knSerif, fontSize: 44, height: 1.1, color: p.ink, letterSpacing: -0.5);
  static TextStyle title(KnPalette p) => TextStyle(fontFamily: knSerif, fontSize: 30, height: 1.2, color: p.ink);
  static TextStyle headline(KnPalette p) =>
      TextStyle(fontFamily: knSans, fontSize: 20, height: 1.3, fontWeight: FontWeight.w600, color: p.ink);
  static TextStyle body(KnPalette p) => TextStyle(fontFamily: knSans, fontSize: 16, height: 1.5, color: p.ink);
  static TextStyle bodyMuted(KnPalette p) =>
      TextStyle(fontFamily: knSans, fontSize: 16, height: 1.5, color: p.inkMuted);
  static TextStyle label(KnPalette p) =>
      TextStyle(fontFamily: knSans, fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, color: p.ink);
  static TextStyle caption(KnPalette p) => TextStyle(fontFamily: knSans, fontSize: 13, height: 1.4, color: p.inkMuted);
  static TextStyle eyebrow(KnPalette p) => TextStyle(
    fontFamily: knSans,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: p.accentText,
  );
  static TextStyle stat(KnPalette p) => TextStyle(fontFamily: knSerif, fontSize: 28, height: 1.1, color: p.ink);
}

// ---------------------------------------------------------------------------
// Componentes
// ---------------------------------------------------------------------------

/// Fundo com gradiente vertical e, no escuro, um campo de estrelas estático.
class KnBackground extends StatelessWidget {
  final KnPalette p;
  final Widget child;
  const KnBackground({super.key, required this.p, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.bgTop, p.bg],
          stops: const [0, 0.55],
        ),
      ),
      child: CustomPaint(painter: p.dark ? _StarsPainter() : null, child: child),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 70; i++) {
      final o = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.6);
      paint.color = Colors.white.withValues(alpha: 0.15 + rnd.nextDouble() * 0.45);
      canvas.drawCircle(o, 0.5 + rnd.nextDouble() * 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KnLogo extends StatelessWidget {
  final KnPalette p;
  final double size;
  const KnLogo({super.key, required this.p, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: 'YatraOne', fontSize: size, color: p.ink, height: 1);
    return Semantics(
      label: 'Knowhen',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'Kno'),
            TextSpan(
              text: 'w',
              style: TextStyle(color: p.dark ? p.primary : p.accentText),
            ),
            const TextSpan(text: 'hen'),
          ],
        ),
      ),
    );
  }
}

/// Botão de ícone com área de toque de 48dp e rótulo para leitor de tela.
class KnIconButton extends StatelessWidget {
  final KnPalette p;
  final IconData icon;
  final String label;
  const KnIconButton({super.key, required this.p, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.surfaceHi,
              shape: BoxShape.circle,
              border: Border.all(color: p.outline),
            ),
            child: Icon(icon, size: 20, color: p.ink),
          ),
        ),
      ),
    );
  }
}

class KnTopBar extends StatelessWidget {
  final KnPalette p;
  final Widget? leading;
  final Widget center;
  const KnTopBar({super.key, required this.p, this.leading, required this.center});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(width: 56, child: leading),
          Expanded(child: Center(child: center)),
          SizedBox(
            width: 56,
            child: KnIconButton(
              p: p,
              icon: p.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              label: p.dark ? 'Mudar para tema claro' : 'Mudar para tema escuro',
            ),
          ),
        ],
      ),
    );
  }
}

enum KnButtonKind { primary, secondary, ghost }

class KnButton extends StatelessWidget {
  final KnPalette p;
  final String text;
  final IconData? icon;
  final KnButtonKind kind;
  final bool expand;
  const KnButton({
    super.key,
    required this.p,
    required this.text,
    this.icon,
    this.kind = KnButtonKind.primary,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = switch (kind) {
      KnButtonKind.primary => p.primary,
      KnButtonKind.secondary => p.surfaceHi,
      KnButtonKind.ghost => Colors.transparent,
    };
    final fg = kind == KnButtonKind.primary ? p.onPrimary : p.ink;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: knSans, fontSize: 16, fontWeight: FontWeight.w600, color: fg),
          ),
        ),
        if (icon != null) ...[const SizedBox(width: KnSpace.sm), Icon(icon, size: 20, color: fg)],
      ],
    );
    return Semantics(
      button: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: KnSpace.xl, vertical: KnSpace.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KnRadius.pill),
          border: kind == KnButtonKind.secondary ? Border.all(color: p.outline) : null,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

class KnCard extends StatelessWidget {
  final KnPalette p;
  final Widget child;
  final EdgeInsets padding;
  const KnCard({super.key, required this.p, required this.child, this.padding = const EdgeInsets.all(KnSpace.xl)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.dark ? 0.85 : 1),
        borderRadius: BorderRadius.circular(KnRadius.md),
        border: Border.all(color: p.outline),
        boxShadow: p.dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF2E2A85).withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}

/// Barra de progresso em segmentos (padrão "stories").
class KnStoryProgress extends StatelessWidget {
  final KnPalette p;
  final int count;
  final int current;
  const KnStoryProgress({super.key, required this.p, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cartão ${current + 1} de $count',
      excludeSemantics: true,
      child: Row(
        children: [
          for (int i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: KnSpace.xs + 2),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= current ? p.primary : p.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lua desenhada localmente: substitui a imagem baixada do Firebase Storage.
/// [phase] em [0, 1): 0 = nova, 0.25 = quarto crescente, 0.5 = cheia.
class KnMoon extends StatelessWidget {
  final KnPalette p;
  final double phase;
  final double size;
  final bool glow;
  const KnMoon({super.key, required this.p, required this.phase, this.size = 160, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MoonPainter(p, phase, glow)),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final KnPalette p;
  final double phase;
  final bool glow;
  _MoonPainter(this.p, this.phase, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    if (glow) {
      canvas.drawCircle(
        c,
        r * 1.0,
        Paint()
          ..color = p.moon.withValues(alpha: p.dark ? 0.18 : 0.25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25),
      );
    }
    final rect = Rect.fromCircle(center: c, radius: r * 0.82);
    final rr = rect.width / 2;
    canvas.drawCircle(c, rr, Paint()..color = p.moonShadow);
    canvas.drawCircle(
      c,
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = p.moon.withValues(alpha: 0.35),
    );

    final waxing = phase < 0.5;
    final k = math.cos(2 * math.pi * phase); // 1 = nova, -1 = cheia
    if (k > 0.999) return;
    canvas.save();
    if (!waxing) {
      canvas.translate(c.dx * 2, 0);
      canvas.scale(-1, 1);
    }
    final top = Offset(c.dx, c.dy - rr);
    final bottom = Offset(c.dx, c.dy + rr);
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(bottom, radius: Radius.circular(rr), clockwise: true)
      ..arcToPoint(top, radius: Radius.elliptical(math.max(rr * k.abs(), 0.01), rr), clockwise: k < 0);
    canvas.drawPath(path, Paint()..color = p.moon);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) => old.phase != phase || old.p != p;
}

class KnEyebrow extends StatelessWidget {
  final KnPalette p;
  final String text;
  const KnEyebrow(this.text, {super.key, required this.p});

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: KnText.eyebrow(p));
}

/// Número grande + rótulo, para estatísticas.
class KnStat extends StatelessWidget {
  final KnPalette p;
  final String value;
  final String label;
  const KnStat({super.key, required this.p, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Com fonte grande o número encolhe em vez de encostar no vizinho.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: KnSpace.md),
              child: Text(value, style: KnText.stat(p)),
            ),
          ),
          const SizedBox(height: KnSpace.xs),
          Text(label, style: KnText.caption(p)),
        ],
      ),
    );
  }
}

/// Moldura padrão das telas do protótipo.
class KnScreen extends StatelessWidget {
  final KnPalette p;
  final Widget? topBar;
  final Widget body;
  final Widget? bottom;
  const KnScreen({super.key, required this.p, this.topBar, required this.body, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: p.bg,
      body: KnBackground(
        p: p,
        child: SafeArea(
          child: Column(
            children: [
              if (topBar != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KnSpace.sm),
                  child: topBar,
                ),
              Expanded(child: body),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(KnSpace.xl, KnSpace.md, KnSpace.xl, KnSpace.xl),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
