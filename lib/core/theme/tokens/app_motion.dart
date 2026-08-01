import 'package:flutter/animation.dart';

/// Tokens de movimento.
///
/// Glassmorphism é um estilo "físico": as transições precisam parecer que
/// materiais estão deslizando, não que pixels estão trocando de estado.
/// Por isso todas as curvas padrão são *decelerate* (saída lenta).
abstract final class AppMotion {
  /// Micro-feedback: press, hover, troca de ícone.
  static const Duration fast = Duration(milliseconds: 140);

  /// Padrão para mudanças de estado de componentes.
  static const Duration normal = Duration(milliseconds: 240);

  /// Entradas de conteúdo, expansões.
  static const Duration slow = Duration(milliseconds: 420);

  /// Transições de página / PageView.
  static const Duration page = Duration(milliseconds: 520);

  /// Deriva do fundo de aurora (quando animado).
  static const Duration ambient = Duration(seconds: 28);

  /// Curva padrão do sistema.
  static const Curve standard = Curves.easeOutCubic;

  /// Movimentos com mais personalidade (entradas de card, CTA).
  static const Curve emphasized = Curves.easeOutQuart;

  /// Saídas / colapsos.
  static const Curve exit = Curves.easeInCubic;

  /// Deslocamento vertical inicial das animações de entrada.
  static const double revealOffset = 18.0;

  /// Atraso entre elementos de uma mesma cascata (stagger).
  static const Duration stagger = Duration(milliseconds: 70);
}
