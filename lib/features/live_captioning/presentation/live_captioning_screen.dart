import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/types/permission_state.dart';
import '../../../core/widgets/gradient_screen.dart';
import '../../../core/widgets/status_dot.dart';
import '../application/live_captioning_controller.dart';
import '../domain/live_captioning_state.dart';
import 'widgets/caption_display.dart';
import 'widgets/mic_button.dart';

class LiveCaptioningScreen extends HookConsumerWidget {
  const LiveCaptioningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveCaptioningControllerProvider);
    final controller = ref.read(liveCaptioningControllerProvider.notifier);

    final captions = [
      ...state.finalized.map((line) => line.text),
      if (state.interim.trim().isNotEmpty) state.interim,
    ];

    final isMicDisabled =
        !state.isAvailable ||
        state.micPermission == PermissionState.denied ||
        state.micPermission == PermissionState.permanentlyDenied ||
        state.micPermission == PermissionState.restricted ||
        state.micPermission == PermissionState.unavailable;

    return GradientScreen(
      child: Column(
        children: [
          const _Header(),
          if (state.error != null && state.error!.isNotEmpty)
            _ErrorBanner(message: state.error!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: CaptionDisplay(
                captions: captions,
                isListening: state.isListening,
              ),
            ),
          ),
          _Controls(
            state: state,
            isMicDisabled: isMicDisabled,
            onMicPressed: controller.toggleListening,
            onClearPressed: controller.clearCaptions,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatusBar(state: state),
          const SizedBox(height: AppSpacing.lg),
        ],
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
          Text('Live Captioning', style: TextStyle(fontSize: AppTypography.xxl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Real-time speech to text',
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border(
          left: BorderSide(color: AppColors.error, width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Ionicons.warning, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: AppTypography.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.isMicDisabled,
    required this.onMicPressed,
    required this.onClearPressed,
  });

  final LiveCaptioningState state;
  final bool isMicDisabled;
  final Future<void> Function() onMicPressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          MicButton(
            isRecording: state.isListening,
            onPressed: () {
              onMicPressed();
            },
            disabled: isMicDisabled,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            key: const Key('live_caption_clear_button'),
            onPressed: state.hasTranscript ? onClearPressed : null,
            icon: Icon(
              Ionicons.trash_outline,
              color:
                  state.hasTranscript
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
            ),
            label: Text(
              'Clear',
              style: TextStyle(
                color:
                    state.hasTranscript
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state});

  final LiveCaptioningState state;

  @override
  Widget build(BuildContext context) {
    String message;
    if (!state.isAvailable) {
      message = 'Live captioning unavailable on this device';
    } else if (state.isListening) {
      message = 'Listening... speak now';
    } else {
      message = 'Tap microphone to start';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatusDot(active: state.isListening),
        const SizedBox(width: AppSpacing.sm),
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppTypography.sm,
          ),
        ),
      ],
    );
  }
}
