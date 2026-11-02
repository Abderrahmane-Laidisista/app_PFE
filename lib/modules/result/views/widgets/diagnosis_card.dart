import 'package:flutter/material.dart';

class DiagnosisCardWidget extends StatelessWidget {
  final String predictedClass;
  final double confidence;

  const DiagnosisCardWidget({
    super.key,
    required this.predictedClass,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(predictedClass, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Confidence: ${(confidence * 100).toStringAsFixed(1)}%'),
      ),
    );
  }
}
