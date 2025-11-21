import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

