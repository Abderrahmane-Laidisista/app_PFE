import 'package:flutter/material.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No historical scans available.'),
    );
  }
}
