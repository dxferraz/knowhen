import 'dart:ui' as ui;

/// Parâmetros globais do material "vidro".
///
/// Estes são os botões de ajuste do estilo inteiro: mexer aqui muda todos os
/// painéis do app de uma vez. Os valores foram calibrados para que o vidro
/// leia como vidro (fundo ainda visível e colorido) sem comprometer o
/// contraste do texto por cima.
abstract final class AppGlassTokens {
  // ---------------------------------------------------------------
  // Desfoque (sigma do backdrop)
  // ---------------------------------------------------------------
  /// Barras e sobreposições finas.
  static const double blurSubtle = 8.0;

  /// Padrão de cards e painéis.
  static const double blurRegular = 18.0;

  /// Modais, sheets, elementos em primeiro plano.
  static const double blurStrong = 30.0;

  // ---------------------------------------------------------------
  // Saturação do backdrop
  //
  // Vidro real satura o que está atrás. Sem esse boost, o blur "lava" a
  // aurora e o painel fica cinza. Só é aplicado quando != 1.0.
  // ---------------------------------------------------------------
  static const double saturationDark = 1.35;
  static const double saturationLight = 1.18;

  // ---------------------------------------------------------------
  // Preenchimento (tint) — gradiente diagonal, mais claro no canto de luz.
  //
  // No tema escuro o tint é branco de baixa opacidade (vidro fumê).
  // No claro precisa ser bem mais opaco, senão o texto perde contraste.
  // ---------------------------------------------------------------
  static const double fillDarkTop = 0.14;
  static const double fillDarkBottom = 0.05;
  static const double fillLightTop = 0.72;
  static const double fillLightBottom = 0.44;

  /// Multiplicadores por nível de elevação do vidro.
  static const double levelSubtleFactor = 0.65;
  static const double levelRegularFactor = 1.0;
  static const double levelElevatedFactor = 1.25;

  // ---------------------------------------------------------------
  // Traço (a "quina de luz" do vidro)
  //
  // O brilho decai do canto superior-esquerdo para o inferior-direito,
  // simulando uma fonte de luz única e fixa na cena.
  // ---------------------------------------------------------------
  static const double strokeWidth = 1.0;
  static const double strokeDarkTop = 0.32;
  static const double strokeDarkBottom = 0.06;
  static const double strokeLightTop = 0.95;
  static const double strokeLightBottom = 0.25;

  // ---------------------------------------------------------------
  // Sombra
  //
  // Sempre projetada apenas para **fora** do painel (ver GlassContainer):
  // se a sombra ficasse sob o vidro translúcido, ele encardiria.
  // ---------------------------------------------------------------
  static const double shadowBlurDark = 40.0;
  static const double shadowBlurLight = 30.0;
  static const double shadowOpacityDark = 0.55;
  static const double shadowOpacityLight = 0.10;

  /// Halo colorido que "vaza" da cor primária sob o painel.
  static const double glowOpacityDark = 0.20;
  static const double glowOpacityLight = 0.10;
}

/// Chaves de performance/acessibilidade avaliadas em tempo de execução.
///
/// `BackdropFilter` é caro em Android de entrada. Desligar [enableBlur]
/// converte todo o sistema para superfícies opacas equivalentes sem quebrar
/// layout — é o "modo econômico" do design system.
class AppGlassConfig {
  AppGlassConfig._();

  /// Liga/desliga o desfoque real em todo o app.
  static bool enableBlur = true;

  /// Deriva lenta dos orbes de aurora.
  ///
  /// Desligado por padrão: qualquer animação atrás de um `BackdropFilter`
  /// obriga o blur a ser recalculado a cada frame na tela inteira.
  static bool animatedAurora = false;

  /// Teto de sigma aplicado globalmente (útil para perfis de baixo custo).
  static double maxBlurSigma = 30.0;

  static double clampSigma(double sigma) =>
      sigma > maxBlurSigma ? maxBlurSigma : sigma;
}

/// Matriz 4x5 de saturação para `ColorFilter.matrix`.
///
/// Coeficientes de luminância ITU-R BT.709 — os mesmos usados pelo WCAG,
/// então a percepção de brilho do fundo não muda, só a pureza da cor.
List<double> saturationMatrix(double s) {
  const double lumR = 0.2126;
  const double lumG = 0.7152;
  const double lumB = 0.0722;
  final double sr = (1 - s) * lumR;
  final double sg = (1 - s) * lumG;
  final double sb = (1 - s) * lumB;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// Monta o filtro de backdrop (desfoque + saturação, quando aplicável).
ui.ImageFilter buildGlassFilter({
  required double sigma,
  double saturation = 1.0,
}) {
  final double clamped = AppGlassConfig.clampSigma(sigma);
  final ui.ImageFilter blur = ui.ImageFilter.blur(
    sigmaX: clamped,
    sigmaY: clamped,
    tileMode: ui.TileMode.clamp,
  );
  if (saturation == 1.0) return blur;
  return ui.ImageFilter.compose(
    outer: ui.ColorFilter.matrix(saturationMatrix(saturation)),
    inner: blur,
  );
}
