import 'package:flutter/material.dart';

class QualityIndicator extends StatelessWidget {
  final double quality;

  const QualityIndicator({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    final isGood = quality >= 70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.withValues(alpha: 0.8) : Colors.amber.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Quality: ${quality.toInt()}%',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
