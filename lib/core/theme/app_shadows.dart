import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 3.84,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 4.65,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: AppColors.primary,
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> tabBar = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 8,
      offset: Offset(0, -4),
    ),
  ];
}

