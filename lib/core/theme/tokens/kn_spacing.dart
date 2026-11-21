/// Grade de 4 pt (DXF-9, seção 2.3). Margem lateral, espaço entre blocos e
/// padding de cartão: [xl].
class KnSpace {
  const KnSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Raios: 12 (campos, ícones), 20 (cartões), pílula (botões).
class KnRadius {
  const KnRadius._();

  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999;
}

/// Tamanhos mínimos de toque.
class KnSize {
  const KnSize._();

  /// Alvo de toque mínimo (WCAG 2.5.5 / Material).
  static const double touchTarget = 48;

  /// Altura dos botões principais.
  static const double button = 56;
}
