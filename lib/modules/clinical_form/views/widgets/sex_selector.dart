import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SexSelector extends StatelessWidget {
  final String selectedSex;
  final ValueChanged<String> onChanged;

  const SexSelector({super.key, required this.selectedSex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text('male'.tr),
            selected: selectedSex == 'M',
            onSelected: (_) => onChanged('M'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: Text('female'.tr),
            selected: selectedSex == 'F',
            onSelected: (_) => onChanged('F'),
          ),
        ),
      ],
    );
  }
}
