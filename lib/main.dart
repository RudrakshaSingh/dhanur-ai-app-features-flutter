import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: DhanurAiApp()));
}

class DhanurAiApp extends StatelessWidget {
  const DhanurAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhanur AI',
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}

