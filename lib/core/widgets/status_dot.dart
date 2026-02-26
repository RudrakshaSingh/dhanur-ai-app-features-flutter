import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusDot extends StatelessWidget {
  const StatusDot({
    required this.active,
    super.key,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.success : AppColors.textMuted,
      ),
    );
  }
}

