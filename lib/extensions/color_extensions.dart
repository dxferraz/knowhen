import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  String toHex() {
    return '#${toARGB32().toRadixString(16).substring(2, 8)}';
  }
}
