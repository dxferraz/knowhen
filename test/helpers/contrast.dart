import 'dart:math' as math;

import 'package:flutter/painting.dart';

double _channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// Luminância relativa (WCAG 2.1).
double relativeLuminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// Razão de contraste (WCAG 2.1) entre duas cores opacas, de 1 a 21.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Mínimos do AA: texto normal, texto grande (≥ 24 dp, ou 18,66 dp em negrito) e ícones/UI.
const double aaText = 4.5;
const double aaLargeText = 3.0;
const double aaUi = 3.0;
