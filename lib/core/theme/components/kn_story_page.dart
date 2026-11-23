import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowhen/core/theme/components/kn_entrance.dart';
import 'package:knowhen/core/theme/components/kn_stat.dart';
import 'package:knowhen/core/theme/tokens/kn_spacing.dart';
import 'package:knowhen/core/theme/tokens/kn_text.dart';

/// Página de um cartão do resumo (DXF-9, 4.4): eyebrow com a categoria, título em serifa e o conteúdo, tudo
/// entrando em sequência. Dimensiona-se pelo espaço que recebe (sem `MediaQuery.size`) e rola na vertical quando
/// o conteúdo não cabe, como com fonte a 200% ou em telas baixas.
class KnStoryPage extends StatelessWidget {
  const KnStoryPage({super.key, this.eyebrow, this.title, this.centered = false, required this.children});

  final String? eyebrow;
  final String? title;

  /// Centraliza o conteúdo na vertical quando sobra espaço.
  final bool centered;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final eyebrow = this.eyebrow;
    final title = this.title;
    var order = 0;
    Widget entrance(Widget child) => KnEntrance(order: order++, child: child);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: KnSpace.lg,
      children: [
        if (eyebrow != null || title != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: KnSpace.md,
            children: [
              if (eyebrow != null) entrance(KnEyebrow(eyebrow)),
              if (title != null) entrance(Semantics(header: true, child: Text(title, style: context.knText.title))),
            ],
          ),
        for (final child in children) entrance(child),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(KnSpace.xl, KnSpace.md, KnSpace.xl, KnSpace.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: math.max(0, constraints.maxHeight - KnSpace.md - KnSpace.xl)),
          child: centered ? Align(alignment: Alignment.center, child: content) : content,
        ),
      ),
    );
  }
}
