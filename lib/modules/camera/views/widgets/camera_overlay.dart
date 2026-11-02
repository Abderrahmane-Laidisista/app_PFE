import 'package:flutter/material.dart';
import 'guide_circle.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        GuideCircle(),
      ],
    );
  }
}
