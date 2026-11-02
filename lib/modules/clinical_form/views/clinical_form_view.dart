import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/clinical_form_controller.dart';
import 'widgets/yes_no_selector.dart';

class ClinicalFormView extends GetView<ClinicalFormController> {
  const ClinicalFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('clinical_form_title'.tr),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Load Benchmark Sample',
            onPressed: () => _showBenchmarkPicker(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview (reactive)
            Obx(() {
              final path = controller.currentImagePath.value.isNotEmpty
                  ? controller.currentImagePath.value
                  : controller.imagePath;

              if (path == null || path.isEmpty) return const SizedBox.shrink();

              return Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),

            // Quick Benchmark bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Benchmark Cases (PAD-UFES-20):',
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    children: ['MEL', 'BCC', 'SCC', 'NEV', 'SEK', 'ACK'].map((cls) {
                      return InkWell(
                        onTap: () => controller.loadBenchmarkSample(cls),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            cls,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'clinical_form_subtitle'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Age Slider
                    _buildSectionTitle('patient_age'.tr),
                    const SizedBox(height: 12),
                    Obx(() => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${controller.age.value.toInt()} ${'years'.tr}',
                                  style: Get.textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: controller.age.value,
                              min: 0,
                              max: 120,
                              divisions: 120,
                              label: controller.age.value.toInt().toString(),
                              onChanged: (value) => controller.age.value = value,
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),

                    // Sex Selection
                    _buildSectionTitle('patient_sex'.tr),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildChoiceChip(
                                label: 'male'.tr,
                                icon: Icons.male,
                                isSelected: controller.sex.value == 'M',
                                onSelected: (_) => controller.setSex('M'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildChoiceChip(
                                label: 'female'.tr,
                                icon: Icons.female,
                                isSelected: controller.sex.value == 'F',
                                onSelected: (_) => controller.setSex('F'),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),

                    // Region Dropdown
                    _buildSectionTitle('lesion_location'.tr),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.region.value.isEmpty ? null : controller.region.value,
                          decoration: InputDecoration(
                            hintText: 'select_location'.tr,
                            prefixIcon: const Icon(Icons.place),
                          ),
                          items: controller.regions.map((region) {
                            return DropdownMenuItem(
                              value: region,
                              child: Text(region.tr),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setRegion(value);
                            }
                          },
                        )),
                    const SizedBox(height: 24),

                    // Diameter Input
                    _buildSectionTitle('lesion_diameter'.tr),
                    const SizedBox(height: 12),
                    Obx(() => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${controller.diameter.value.toStringAsFixed(1)} mm',
                                  style: Get.textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: controller.diameter.value,
                              min: 0.5,
                              max: 100,
                              divisions: 199,
                              label: controller.diameter.value.toStringAsFixed(1),
                              onChanged: (value) => controller.diameter.value = value,
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),

                    // Palpable / Elevation Question (New in V2 / V6.0)
                    _buildSectionTitle('lesion_elevation'.tr),
                    const SizedBox(height: 12),
                    Obx(() => YesNoSelector(
                          value: controller.elevation.value,
                          onChanged: controller.setElevation,
                        )),
                    const SizedBox(height: 24),

                    // Growth Question
                    _buildSectionTitle('lesion_growth'.tr),
                    const SizedBox(height: 12),
                    Obx(() => YesNoSelector(
                          value: controller.grew.value,
                          onChanged: controller.setGrew,
                        )),
                    const SizedBox(height: 24),

                    // Bleeding Question
                    _buildSectionTitle('lesion_bleeding'.tr),
                    const SizedBox(height: 12),
                    Obx(() => YesNoSelector(
                          value: controller.bleed.value,
                          onChanged: controller.setBleed,
                        )),
                    const SizedBox(height: 24),

                    // Cancer History Question
                    _buildSectionTitle('cancer_history'.tr),
                    const SizedBox(height: 12),
                    Obx(() => YesNoSelector(
                          value: controller.skinCancerHistory.value,
                          onChanged: controller.setSkinCancerHistory,
                        )),
                    const SizedBox(height: 24),

                    // Optional Patient Identifier & Lesion Tag
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Optional Tracking Metadata',
                        style: Get.textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: controller.patientId.value,
                          decoration: const InputDecoration(
                            labelText: 'Patient Code (e.g. DZ-16-P0102)',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          onChanged: (v) => controller.patientId.value = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: controller.lesionTag.value,
                          decoration: const InputDecoration(
                            labelText: 'Lesion Clinical Tag (e.g. Right shoulder)',
                            prefixIcon: Icon(Icons.label_outline),
                          ),
                          onChanged: (v) => controller.lesionTag.value = v,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isFormValid.value ? controller.submitForm : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'submit'.tr,
                              style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return InkWell(
      onTap: () => onSelected(true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Get.textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBenchmarkPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Benchmark Sample (PAD-UFES-20)',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Preloaded authentic cases for instant clinical demo without camera uploads.',
              style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...['MEL', 'BCC', 'SCC', 'NEV', 'SEK', 'ACK'].map((cls) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(cls, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                title: Text('$cls Benchmark Lesion'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  controller.loadBenchmarkSample(cls);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
