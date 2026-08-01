import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Um "orbe" da cena de aurora: mancha radial de cor que fica **atrás** do
/// vidro e dá o que refratar. Sem isso, glassmorphism vira apenas um card
/// cinza translúcido.
@immutable
class AuroraOrb {
  const AuroraOrb({
    required this.color,
    required this.alignment,
    required this.diameterFactor,
    this.opacity = 0.4,
  });

  final Color color;

  /// Posição do centro do orbe em coordenadas de alinhamento (-1..1).
  final Alignment alignment;

  /// Diâmetro relativo ao **maior** lado da tela.
  final double diameterFactor;

  final double opacity;

  AuroraOrb copyWith({
    Color? color,
    Alignment? alignment,
    double? diameterFactor,
    double? opacity,
  }) {
    return AuroraOrb(
      color: color ?? this.color,
      alignment: alignment ?? this.alignment,
      diameterFactor: diameterFactor ?? this.diameterFactor,
      opacity: opacity ?? this.opacity,
    );
  }

  static AuroraOrb lerp(AuroraOrb a, AuroraOrb b, double t) {
    return AuroraOrb(
      color: Color.lerp(a.color, b.color, t) ?? b.color,
      alignment: Alignment.lerp(a.alignment, b.alignment, t) ?? b.alignment,
      diameterFactor: a.diameterFactor + (b.diameterFactor - a.diameterFactor) * t,
      opacity: a.opacity + (b.opacity - a.opacity) * t,
    );
  }

  static List<AuroraOrb> lerpList(
    List<AuroraOrb> a,
    List<AuroraOrb> b,
    double t,
  ) {
    if (a.length != b.length) return t < 0.5 ? a : b;
    return List<AuroraOrb>.generate(
      a.length,
      (i) => AuroraOrb.lerp(a[i], b[i], t),
      growable: false,
    );
  }
}

/// Gradientes de cena e de marca.
abstract final class AppGradients {
  // -------------------------------------------------------------------
  // Fundo (camada 0)
  // -------------------------------------------------------------------
  static const LinearGradient canvasDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppPalette.night, AppPalette.nightAlt, AppPalette.nightDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient canvasLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppPalette.dawn, AppPalette.dawnAlt, AppPalette.dawnDeep],
    stops: [0.0, 0.55, 1.0],
  );

  // -------------------------------------------------------------------
  // Orbes de aurora (camada 1) — 4 manchas, uma por família de cor.
  // No escuro usamos cores saturadas com alpha baixo; no claro, pastéis com
  // alpha alto, senão a cena fica lavada.
  // -------------------------------------------------------------------
  static const List<AuroraOrb> auroraDark = [
    AuroraOrb(
      color: AppPalette.iris500,
      alignment: Alignment(-0.85, -0.75),
      diameterFactor: 1.15,
      opacity: 0.38,
    ),
    AuroraOrb(
      color: AppPalette.nebula500,
      alignment: Alignment(0.95, -0.35),
      diameterFactor: 0.85,
      opacity: 0.22,
    ),
    AuroraOrb(
      color: AppPalette.aqua400,
      alignment: Alignment(-0.6, 0.85),
      diameterFactor: 0.95,
      opacity: 0.2,
    ),
    AuroraOrb(
      color: AppPalette.solar400,
      alignment: Alignment(0.85, 1.0),
      diameterFactor: 0.7,
      opacity: 0.14,
    ),
  ];

  static const List<AuroraOrb> auroraLight = [
    AuroraOrb(
      color: AppPalette.iris200,
      alignment: Alignment(-0.85, -0.75),
      diameterFactor: 1.15,
      opacity: 0.75,
    ),
    AuroraOrb(
      color: AppPalette.nebula200,
      alignment: Alignment(0.95, -0.35),
      diameterFactor: 0.85,
      opacity: 0.5,
    ),
    AuroraOrb(
      color: AppPalette.aqua200,
      alignment: Alignment(-0.6, 0.85),
      diameterFactor: 0.95,
      opacity: 0.5,
    ),
    AuroraOrb(
      color: AppPalette.solar200,
      alignment: Alignment(0.85, 1.0),
      diameterFactor: 0.7,
      opacity: 0.45,
    ),
  ];

  // -------------------------------------------------------------------
  // Marca / CTA
  // -------------------------------------------------------------------
  static const LinearGradient brandDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.iris400, AppPalette.nebula400],
  );

  static const LinearGradient brandLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.iris600, AppPalette.nebula600],
  );

  /// Gradiente frio, usado em dados/tempo (relógio da vida).
  static const LinearGradient coolDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.aqua300, AppPalette.iris300],
  );

  static const LinearGradient coolLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.aqua600, AppPalette.iris600],
  );

  /// Gradiente quente, usado em destaques celestes (lua, sol).
  static const LinearGradient warmDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.solar300, AppPalette.nebula300],
  );

  static const LinearGradient warmLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.solar600, AppPalette.nebula600],
  );
}
