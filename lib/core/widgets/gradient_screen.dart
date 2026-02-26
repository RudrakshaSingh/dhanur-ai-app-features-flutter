import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';

class GradientScreen extends StatelessWidget {
  const GradientScreen({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppGradients.dark,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

