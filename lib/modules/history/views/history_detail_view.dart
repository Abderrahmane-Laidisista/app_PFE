import 'package:flutter/material.dart';
import '../../../data/models/diagnosis_history.dart';

class HistoryDetailView extends StatelessWidget {
  final DiagnosisHistoryItem item;

  const HistoryDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan: ${item.diagnosis}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnosis: ${item.diagnosis}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Risk Level: ${item.riskLevel}'),
          ],
        ),
      ),
    );
  }
}
