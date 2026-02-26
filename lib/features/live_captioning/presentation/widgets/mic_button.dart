import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';

class MicButton extends HookWidget {
  const MicButton({
    required this.isRecording,
    required this.onPressed,
    required this.disabled,
    super.key,
  });

  final bool isRecording;
  final VoidCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    useEffect(() {
      if (isRecording) {
        pulseController.repeat(reverse: true);
      } else {
        pulseController.stop();
        pulseController.value = 0;
      }
      return null;
    }, [isRecording]);

    final pulseScale = 1 + (pulseController.value * 0.3);
    final pulseOpacity = 0.6 - (pulseController.value * 0.6);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => pressed.value = true,
      onTapCancel: disabled ? null : () => pressed.value = false,
      onTapUp: disabled ? null : (_) => pressed.value = false,
      onTap: disabled ? null : onPressed,
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isRecording)
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: math.max(0, pulseOpacity),
                    child: Transform.scale(scale: pulseScale, child: child),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: pressed.value ? 0.92 : 1,
              child: Opacity(
                opacity: disabled ? 0.5 : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isRecording
                              ? AppGradients.recording
                              : AppGradients.primary,
                    ),
                    boxShadow: AppShadows.glowPrimary,
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Icon(
                        isRecording ? Ionicons.stop : Ionicons.mic,
                        size: 40,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
