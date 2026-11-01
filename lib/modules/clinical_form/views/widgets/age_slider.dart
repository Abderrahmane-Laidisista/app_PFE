import 'package:flutter/material.dart';

class AgeSlider extends StatelessWidget {
  final double age;
  final ValueChanged<double> onChanged;

  const AgeSlider({super.key, required this.age, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: age,
      min: 0,
      max: 120,
      divisions: 120,
      label: age.toInt().toString(),
      onChanged: onChanged,
    );
  }
}
