import 'package:flutter/material.dart';

import '../glass_theme.dart';
import '../tokens/app_gradients.dart';
import '../tokens/app_spacing.dart';
import 'aurora_background.dart';
import 'glass_container.dart';

/// Scaffold padrão do app.
///
/// Garante as três invariantes do estilo:
/// 1. a cena de aurora ocupa a tela inteira, **atrás** de app bar e bottom bar;
/// 2. o `Scaffold` é transparente, para o vidro ter o que refratar;
/// 3. o conteúdo respeita as áreas seguras sem cortar o fundo.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.orbs,
    this.animatedBackground,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.resizeToAvoidBottomInset,
    this.padBodyForAppBar = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  /// Barra inferior flutuante (não é `bottomSheet`: fica sobre o conteúdo).
  final Widget? bottomBar;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Cena alternativa de aurora para esta tela.
  final List<AuroraOrb>? orbs;

  final bool? animatedBackground;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool? resizeToAvoidBottomInset;

  /// Como o corpo passa **atrás** da app bar, ele recebe por padrão um
  /// respiro do tamanho da barra. Desligue em telas que rolam sob ela.
  final bool padBodyForAppBar;

  @override
  Widget build(BuildContext context) {
    final Widget content = appBar != null && padBodyForAppBar
        ? Padding(
            padding: EdgeInsets.only(top: appBar!.preferredSize.height),
            child: body,
          )
        : body;

    return Stack(
      children: [
        Positioned.fill(
          child: AuroraBackground(orbs: orbs, animated: animatedBackground),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          body: SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            child: content,
          ),
          bottomNavigationBar: bottomBar == null
              ? null
              : SafeArea(top: false, child: bottomBar!),
        ),
      ],
    );
  }
}

/// Barra de ação inferior flutuante.
///
/// Fica destacada das bordas (não encosta na tela) para reforçar a leitura
/// de "camada de vidro sobre a cena", em vez de rodapé colado.
///
/// A barra tem a altura do próprio conteúdo — o `Scaffold` permite até a tela
/// inteira. Por isso, ao usar `Align`/`Center` dentro da `Row` do filho,
/// passe `heightFactor: 1`: sem isso eles se esticam até o limite e a barra
/// cobre a tela.
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.sMedium,
    ),
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.screenGutter,
      AppSpacing.small,
      AppSpacing.screenGutter,
      AppSpacing.medium,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      level: GlassLevel.elevated,
      margin: margin,
      padding: padding,
      borderRadius: BorderRadius.circular(AppRadius.xxLarge),
      child: child,
    );
  }
}
