import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'app_text.dart';
import 'glass_reveal.dart';

/// Layout canônico de uma seção de tela cheia.
///
/// Padroniza a cadência vertical de todas as telas:
/// `overline → título → subtítulo → conteúdo → rodapé`, com o mesmo gutter,
/// o mesmo respiro e a mesma cascata de entrada.
///
/// Por padrão **não rola**: as seções do resumo vivem dentro de um `PageView`
/// vertical e um scroll aninhado roubaria o gesto de paginação. O conteúdo é
/// declarado como `Flexible`, então encolhe em telas baixas em vez de estourar.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.footer,
    this.padding,
    this.scrollable = false,
    this.animate = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final Widget child;
  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  /// Habilita rolagem. Use apenas fora de `PageView` vertical.
  final bool scrollable;

  final bool animate;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding = padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.large,
          AppSpacing.screenGutter,
          AppSpacing.bottomBarHeight,
        );

    int step = 0;
    Widget reveal(Widget widget) {
      if (!animate) return widget;
      return GlassReveal(order: step++, child: widget);
    }

    final List<Widget> header = [
      if (eyebrow != null)
        reveal(AppText.overline(eyebrow!, align: TextAlign.center)),
      if (eyebrow != null && title != null)
        const SizedBox(height: AppSpacing.small),
      if (title != null)
        reveal(AppText.headline(title!, align: TextAlign.center)),
      if (subtitle != null) ...[
        const SizedBox(height: AppSpacing.small),
        reveal(AppText.body(subtitle!, align: TextAlign.center)),
      ],
      if (eyebrow != null || title != null || subtitle != null)
        const SizedBox(height: AppSpacing.xLarge),
    ];

    final Widget body = reveal(child);
    final Widget? footerWidget = footer == null ? null : reveal(footer!);

    if (scrollable) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: resolvedPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...header,
                body,
                if (footerWidget != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  footerWidget,
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: resolvedPadding,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...header,
          Flexible(child: body),
          if (footerWidget != null) ...[
            const SizedBox(height: AppSpacing.large),
            footerWidget,
          ],
        ],
      ),
    );
  }
}
