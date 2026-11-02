import 'package:flutter/material.dart';

class GuideCircle extends StatelessWidget {
  final double size;
  final Color color;

  const GuideCircle({
    super.key,
    this.size = 250,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
      ),
    );
  }
}
