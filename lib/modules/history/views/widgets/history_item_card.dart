import 'package:flutter/material.dart';
import '../../../../data/models/diagnosis_history.dart';

class HistoryItemCard extends StatelessWidget {
  final DiagnosisHistoryItem item;
  final VoidCallback? onTap;

  const HistoryItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.diagnosis),
        subtitle: Text('Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%'),
        onTap: onTap,
      ),
    );
  }
}
