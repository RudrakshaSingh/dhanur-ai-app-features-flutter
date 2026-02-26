import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../features/live_captioning/presentation/live_captioning_screen.dart';
import '../features/mic_control/presentation/mic_control_screen.dart';
import '../features/player/presentation/overlay_player_screen.dart';

class AppShell extends HookWidget {
  const AppShell({
    super.key,
    this.screens,
    this.items,
  });

  final List<Widget>? screens;
  final List<BottomNavigationBarItem>? items;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    final tabScreens =
        screens ??
        const [
          LiveCaptioningScreen(),
          MicControlScreen(),
          OverlayPlayerScreen(),
        ];
    final tabItems =
        items ??
        const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.mic_outline),
            activeIcon: Icon(Ionicons.mic),
            label: 'Live Caption',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.radio_outline),
            activeIcon: Icon(Ionicons.radio),
            label: 'Mic Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.play_circle_outline),
            activeIcon: Icon(Ionicons.play_circle),
            label: 'Player',
          ),
        ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: selectedIndex.value,
        children: tabScreens,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.tabBar,
        ),
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex.value,
            onTap: (index) => selectedIndex.value = index,
            items: tabItems,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

