import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SpeedControl extends StatelessWidget {
  const SpeedControl({
    required this.currentSpeed,
    required this.onSpeedChange,
    super.key,
  });

  static const List<double> speedOptions = [0.5, 0.75, 1, 1.25, 1.5, 2];

  final double currentSpeed;
  final Future<void> Function(double speed) onSpeedChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppTypography.sm,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children:
                speedOptions.map((speed) {
                  final isActive = currentSpeed == speed;
                  final text = '${speed}x';
                  return GestureDetector(
                    key: Key('speed_button_$speed'),
                    onTap: () {
                      onSpeedChange(speed);
                    },
                    child:
                        isActive
                            ? DecoratedBox(
                              key: Key('speed_active_$speed'),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                gradient: const LinearGradient(
                                  colors: AppGradients.primary,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: AppTypography.sm,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            : Container(
                              key: Key('speed_inactive_$speed'),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppTypography.sm,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
