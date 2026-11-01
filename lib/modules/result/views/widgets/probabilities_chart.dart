import 'package:flutter/material.dart';

class ProbabilitiesChart extends StatelessWidget {
  final Map<String, double> probabilities;

  const ProbabilitiesChart({super.key, required this.probabilities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: probabilities.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 50, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                child: LinearProgressIndicator(value: e.value, minHeight: 8),
              ),
              const SizedBox(width: 8),
              Text('${(e.value * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
