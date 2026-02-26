import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const List<Color> dark = [
    AppColors.background,
    AppColors.backgroundLight,
  ];
  static const List<Color> primary = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  static const List<Color> accent = [
    AppColors.accent,
    AppColors.primary,
  ];
  static const List<Color> success = [
    AppColors.success,
    Color(0xFF00C853),
  ];
  static const List<Color> recording = [
    AppColors.error,
    Color(0xFFFF1744),
  ];
}

