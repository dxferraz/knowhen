import 'package:flutter/material.dart';

/// Barra superior: ação à esquerda (voltar ou fechar), título ou logo no centro e ação à direita (tema).
/// Cada lateral tem 56 dp de largura e comporta um `KnIconButton`; a altura é de no mínimo 56 dp.
class KnTopBar extends StatelessWidget {
  const KnTopBar({super.key, this.leading, required this.center, this.trailing});

  final Widget? leading;
  final Widget center;
  final Widget? trailing;

  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: height),
      child: Row(
        children: [
          SizedBox(
            width: height,
            child: Center(heightFactor: 1, child: leading),
          ),
          Expanded(child: Align(heightFactor: 1, child: center)),
          SizedBox(
            width: height,
            child: Center(heightFactor: 1, child: trailing),
          ),
        ],
      ),
    );
  }
}
