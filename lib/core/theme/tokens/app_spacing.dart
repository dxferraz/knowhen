/// Escala de espaçamento — grid de 4pt.
///
/// Regra prática adotada no app:
/// - `xs/sm`  → espaço interno entre ícone e label, itens de uma mesma linha;
/// - `md`     → padding padrão de componentes;
/// - `lg`     → padding de tela (gutter) e respiro entre blocos irmãos;
/// - `xl+`    → separação entre seções semanticamente diferentes.
abstract final class AppSpacing {
  static const double none = 0.0;
  static const double xxSmall = 2.0;
  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double sMedium = 12.0;
  static const double medium = 16.0;
  static const double mLarge = 20.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
  static const double xxLarge = 40.0;
  static const double huge = 48.0;
  static const double xHuge = 64.0;
  static const double xxHuge = 80.0;

  /// Margem lateral padrão das telas.
  static const double screenGutter = mLarge;

  /// Altura reservada para a barra de ação inferior flutuante.
  static const double bottomBarHeight = 88.0;
}

/// Raios de canto.
///
/// Glassmorphism depende de raios generosos: cantos muito fechados fazem o
/// blur "vazar" nas quinas e o painel perde a leitura de vidro.
abstract final class AppRadius {
  static const double none = 0.0;
  static const double xSmall = 8.0;
  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 20.0;
  static const double xLarge = 24.0;
  static const double xxLarge = 32.0;
  static const double huge = 40.0;

  /// Cápsula (botões, chips, indicadores).
  static const double pill = 999.0;
}
