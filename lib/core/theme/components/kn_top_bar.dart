import 'package:flutter/material.dart';

/// Barra superior: ação à esquerda (voltar ou fechar), título ou logo no centro e ação à direita (tema).
/// Cada lateral tem 56 dp de largura (ou [sideWidth]) e comporta um `KnIconButton`; a altura é de no mínimo 56 dp.
class KnTopBar extends StatelessWidget {
  const KnTopBar({super.key, this.leading, required this.center, this.trailing, this.sideWidth = height});

  final Widget? leading;
  final Widget center;
  final Widget? trailing;

  /// Largura de cada lateral (iguais, para o centro ficar centralizado). Cresce quando um lado leva mais de um botão.
  final double sideWidth;

  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: height),
      child: Row(
        children: [
          SizedBox(
            width: sideWidth,
            child: Center(heightFactor: 1, child: leading),
          ),
          Expanded(child: Align(heightFactor: 1, child: center)),
          SizedBox(
            width: sideWidth,
            child: Center(heightFactor: 1, child: trailing),
          ),
        ],
      ),
    );
  }
}
