import 'package:flutter/material.dart';

class RecommendationsList extends StatelessWidget {
  final List<String> recommendations;

  const RecommendationsList({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.check, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(r)),
          ],
        ),
      )).toList(),
    );
  }
}
