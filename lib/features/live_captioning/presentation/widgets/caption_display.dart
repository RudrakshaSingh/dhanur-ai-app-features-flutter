import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CaptionDisplay extends HookWidget {
  const CaptionDisplay({
    required this.captions,
    required this.isListening,
    super.key,
  });

  final List<String> captions;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 800),
      lowerBound: 0,
      upperBound: 1,
      initialValue: 0,
    );

    useEffect(() {
      if (isListening) {
        pulseController.repeat(reverse: true);
      } else {
        pulseController.stop();
        pulseController.value = 0;
      }
      return null;
    }, [isListening]);

    final scale = 1 + (pulseController.value * 0.05);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) {
          return;
        }
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [captions.length]);

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: math.max(1, scale),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isListening ? AppColors.success : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isListening ? 'Listening...' : 'Captions',
                  style: AppTypography.sectionLabel.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.surfaceLight),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child:
                  captions.isEmpty
                      ? Center(
                        child: Text(
                          'Your speech will appear here...',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: AppTypography.md,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                      : ListView.separated(
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return Text(
                            captions[index],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: AppTypography.lg,
                              height: 1.4,
                            ),
                          );
                        },
                        separatorBuilder:
                            (context, index) =>
                                const SizedBox(height: AppSpacing.sm),
                        itemCount: captions.length,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

