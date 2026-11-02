import 'package:flutter/material.dart';
import '../app/config/theme/app_colores.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.heroGradient,
      ),
      child: child,
    );
  }
}
