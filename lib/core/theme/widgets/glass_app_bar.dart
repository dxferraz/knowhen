import 'package:flutter/material.dart';

import '../context_extensions.dart';
import '../glass_theme.dart';
import '../tokens/app_glass.dart';
import '../tokens/app_spacing.dart';
import 'app_text.dart';

/// AppBar de vidro.
///
/// Fica sobre o conteúdo (`extendBodyBehindAppBar`) e o desfoca ao rolar,
/// mantendo a leitura do título sem cortar a cena de aurora em duas.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.blurred = true,
    this.centerTitle = true,
    this.bottomDivider = true,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// Desliga o desfoque quando a barra fica sobre uma área já translúcida.
  final bool blurred;

  final bool centerTitle;
  final bool bottomDivider;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final style = glass.styleFor(GlassLevel.subtle);
    final bool useBlur = blurred && AppGlassConfig.enableBlur;

    return AppBar(
      title: titleWidget ??
          (title == null
              ? null
              : AppText.subtitle(
                  title!,
                  align: TextAlign.center,
                  maxLines: 1,
                )),
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions == null
          ? null
          : [
              ...actions!,
              const SizedBox(width: AppSpacing.small),
            ],
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: _AppBarSurface(
        useBlur: useBlur,
        sigma: style.blurSigma,
        saturation: style.saturation,
        fill: style.fill,
        dividerColor: bottomDivider
            ? glass.dividerColor.withValues(alpha: 0.25)
            : null,
      ),
    );
  }
}

class _AppBarSurface extends StatelessWidget {
  const _AppBarSurface({
    required this.useBlur,
    required this.sigma,
    required this.saturation,
    required this.fill,
    required this.dividerColor,
  });

  final bool useBlur;
  final double sigma;
  final double saturation;
  final Gradient fill;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        gradient: useBlur ? fill : null,
        border: dividerColor == null
            ? null
            : Border(bottom: BorderSide(color: dividerColor!, width: 0.5)),
      ),
      child: const SizedBox.expand(),
    );

    if (!useBlur) return surface;

    return ClipRect(
      child: BackdropFilter(
        filter: buildGlassFilter(sigma: sigma, saturation: saturation),
        child: surface,
      ),
    );
  }
}
