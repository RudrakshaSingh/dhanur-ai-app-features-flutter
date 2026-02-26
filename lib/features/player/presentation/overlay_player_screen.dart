import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/time_formatters.dart';
import '../../../core/widgets/gradient_screen.dart';
import '../application/player_controller.dart';
import '../presentation/widgets/speed_control.dart';

class OverlayPlayerScreen extends HookConsumerWidget {
  const OverlayPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final videoService = ref.watch(videoPlaybackServiceProvider);
    final videoController = videoService.controller;
    final maxPosition = math.max(1, state.duration.inMilliseconds);

    return GradientScreen(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _Header(),
            Align(
              alignment:
                  state.isMiniPlayer ? Alignment.centerRight : Alignment.center,
              child: Container(
                width:
                    state.isMiniPlayer
                        ? MediaQuery.sizeOf(context).width * 0.5
                        : null,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (videoController != null &&
                          videoController.value.isInitialized)
                        VideoPlayer(videoController)
                      else
                        const SizedBox.shrink(),
                      if (state.isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Ionicons.reload,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppTypography.sm,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: IconButton(
                            onPressed: controller.toggleMiniPlayer,
                            icon: Icon(
                              state.isMiniPlayer
                                  ? Ionicons.expand
                                  : Ionicons.contract,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        formatDuration(state.position),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: AppTypography.xs,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value:
                              state.position.inMilliseconds
                                  .clamp(0, maxPosition)
                                  .toDouble(),
                          min: 0,
                          max: maxPosition.toDouble(),
                          onChanged: (value) {
                            controller.seekTo(
                              Duration(milliseconds: value.round()),
                            );
                          },
                        ),
                      ),
                      Text(
                        formatDuration(state.duration),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: AppTypography.xs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: controller.skipBackward,
                        child: const Column(
                          children: [
                            Icon(
                              Ionicons.play_back,
                              size: 28,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '10s',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: AppTypography.xs,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      GestureDetector(
                        onTap: controller.togglePlayPause,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: AppGradients.primary,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.primary,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child: _PlayPauseIcon(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      TextButton(
                        onPressed: controller.skipForward,
                        child: const Column(
                          children: [
                            Icon(
                              Ionicons.play_forward,
                              size: 28,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '10s',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: AppTypography.xs,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SpeedControl(
              currentSpeed: state.playbackSpeed,
              onSpeedChange: controller.setSpeed,
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Ionicons.speedometer,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Current Speed: ${state.playbackSpeed}x',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.md,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Ionicons.information_circle,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Use the speed controls to adjust playback from 0.5x to 2x',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.sm,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Ionicons.resize, size: 20, color: AppColors.accent),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Tap the resize button for mini player mode',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.sm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.error != null && state.error!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  state.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AppTypography.sm,
                  ),
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
            'Overlay Player',
            style: TextStyle(
              fontSize: AppTypography.xxl,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Media playback with speed control',
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

class _PlayPauseIcon extends ConsumerWidget {
  const _PlayPauseIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playerControllerProvider).isPlaying;
    return Icon(
      isPlaying ? Ionicons.pause : Ionicons.play,
      size: 36,
      color: AppColors.textPrimary,
    );
  }
}

