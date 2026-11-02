import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegionDropdown extends StatelessWidget {
  final String? value;
  final List<String> regions;
  final ValueChanged<String?> onChanged;

  const RegionDropdown({
    super.key,
    this.value,
    required this.regions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: 'select_location'.tr,
        prefixIcon: const Icon(Icons.place),
      ),
      items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r.tr))).toList(),
      onChanged: onChanged,
    );
  }
}
