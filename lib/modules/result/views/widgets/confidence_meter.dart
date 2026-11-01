import 'package:flutter/material.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;

  const ConfidenceMeter({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: confidence,
      minHeight: 10,
      borderRadius: BorderRadius.circular(5),
    );
  }
}
