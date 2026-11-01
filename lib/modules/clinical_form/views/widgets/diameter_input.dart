import 'package:flutter/material.dart';

class DiameterInput extends StatelessWidget {
  final double diameter;
  final ValueChanged<double> onChanged;

  const DiameterInput({super.key, required this.diameter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: diameter,
      min: 0.5,
      max: 100,
      divisions: 199,
      label: '${diameter.toStringAsFixed(1)} mm',
      onChanged: onChanged,
    );
  }
}
