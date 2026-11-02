import 'package:flutter/material.dart';

class ProgressAnimation extends StatelessWidget {
  final double value;

  const ProgressAnimation({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }
}
