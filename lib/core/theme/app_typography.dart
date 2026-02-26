import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 28;
  static const double xxxl = 36;

  static TextStyle title = const TextStyle(
    fontSize: xxl,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = const TextStyle(
    fontSize: md,
    color: AppColors.textSecondary,
  );

  static TextStyle sectionLabel = const TextStyle(
    fontSize: sm,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );
}

