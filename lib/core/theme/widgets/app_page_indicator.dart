import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../context_extensions.dart';
import '../tokens/app_motion.dart';

/// Indicador de página padronizado (horizontal ou vertical).
///
/// Centraliza cores e tamanhos para que onboarding e resumo usem exatamente
/// o mesmo elemento.
class AppPageIndicator extends StatelessWidget {
  const AppPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.axis = Axis.horizontal,
    this.onDotClicked,
    this.activeColor,
    this.dotSize = 8,
  });

  final PageController controller;
  final int count;
  final Axis axis;
  final ValueChanged<int>? onDotClicked;
  final Color? activeColor;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final Color active = activeColor ?? context.colors.primary;

    return SmoothPageIndicator(
      controller: controller,
      count: count,
      axisDirection: axis,
      effect: ExpandingDotsEffect(
        dotHeight: dotSize,
        dotWidth: dotSize,
        expansionFactor: 3.2,
        spacing: dotSize,
        dotColor: context.colors.textPrimary.withValues(alpha: 0.22),
        activeDotColor: active,
      ),
      onDotClicked: onDotClicked ??
          (index) => controller.animateToPage(
                index,
                duration: AppMotion.page,
                curve: AppMotion.standard,
              ),
    );
  }
}
