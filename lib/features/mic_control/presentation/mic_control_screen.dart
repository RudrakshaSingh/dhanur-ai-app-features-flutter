import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/types/permission_state.dart';
import '../../../core/widgets/gradient_screen.dart';
import '../application/mic_control_controller.dart';

class MicControlScreen extends HookConsumerWidget {
  const MicControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(micControlControllerProvider);
    final controller = ref.read(micControlControllerProvider.notifier);

    return GradientScreen(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _Header(),
            _PermissionCard(
              permission: state.micPermission,
              message: state.permissionMessage,
              onRequestPermission: controller.requestPermission,
            ),
            _MicrophoneSection(
              isEnabled: state.isMicEnabled,
              inputLevel: state.inputLevel,
              onToggleMic: controller.toggleMicrophone,
            ),
            _QuickActionsCard(
              isMicEnabled: state.isMicEnabled,
              onRefresh: controller.refreshPermissionStatus,
              onRelease: controller.releaseMicrophone,
            ),
            if (state.error != null && state.error!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AppTypography.sm,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Microphone Control',
            style: TextStyle(
              fontSize: AppTypography.xxl,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Manage microphone permissions & input',
            style: TextStyle(
              fontSize: AppTypography.md,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.permission,
    required this.message,
    required this.onRequestPermission,
  });

  final PermissionState permission;
  final String message;
  final Future<void> Function() onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final isGranted = permission == PermissionState.granted;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.shield_checkmark, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Permission Status',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                _iconForPermission(permission),
                size: 20,
                color: _colorForPermission(permission),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: AppTypography.md,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (!isGranted)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    gradient: const LinearGradient(
                      colors: AppGradients.primary,
                    ),
                  ),
                  child: TextButton(
                    key: const Key('mic_request_permission_button'),
                    onPressed: () {
                      onRequestPermission();
                    },
                    child: const Text(
                      'Request Permission',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconForPermission(PermissionState permission) {
    switch (permission) {
      case PermissionState.granted:
        return Ionicons.checkmark_circle;
      case PermissionState.denied:
      case PermissionState.permanentlyDenied:
      case PermissionState.restricted:
      case PermissionState.unavailable:
        return Ionicons.close_circle;
      case PermissionState.checking:
        return Ionicons.help_circle;
    }
  }

  static Color _colorForPermission(PermissionState permission) {
    switch (permission) {
      case PermissionState.granted:
        return AppColors.success;
      case PermissionState.denied:
      case PermissionState.permanentlyDenied:
      case PermissionState.restricted:
      case PermissionState.unavailable:
        return AppColors.error;
      case PermissionState.checking:
        return AppColors.textMuted;
    }
  }
}

class _MicrophoneSection extends StatelessWidget {
  const _MicrophoneSection({
    required this.isEnabled,
    required this.inputLevel,
    required this.onToggleMic,
  });

  final bool isEnabled;
  final double inputLevel;
  final Future<void> Function() onToggleMic;

  @override
  Widget build(BuildContext context) {
    final normalizedScale = isEnabled ? 1 + (inputLevel / 200) : 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Text(
            'Microphone Input',
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  scale: normalizedScale,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isEnabled
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.surfaceLight,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          isEnabled ? AppGradients.success : AppGradients.primary,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 48,
                    color: AppColors.textPrimary,
                    onPressed: () {
                      onToggleMic();
                    },
                    icon: Icon(isEnabled ? Ionicons.mic : Ionicons.mic_off),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isEnabled ? 'Microphone Active' : 'Microphone Disabled',
            style: const TextStyle(
              fontSize: AppTypography.lg,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isEnabled)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: Column(
                  children: [
                    const Text(
                      'Input Level',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        height: 8,
                        color: AppColors.surfaceLight,
                        child: FractionallySizedBox(
                          widthFactor: (inputLevel / 100).clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(color: AppColors.success),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.isMicEnabled,
    required this.onRefresh,
    required this.onRelease,
  });

  final bool isMicEnabled;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRelease;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Ionicons.flash, color: AppColors.accent, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  onRefresh();
                },
                icon: const Icon(
                  Ionicons.refresh,
                  color: AppColors.textPrimary,
                ),
                label: const Text(
                  'Refresh Status',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              TextButton.icon(
                onPressed:
                    isMicEnabled
                        ? () {
                          onRelease();
                        }
                        : null,
                icon: Icon(
                  Ionicons.power,
                  color: isMicEnabled ? AppColors.error : AppColors.textMuted,
                ),
                label: Text(
                  'Release Mic',
                  style: TextStyle(
                    color:
                        isMicEnabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
