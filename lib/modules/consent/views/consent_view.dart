import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/consent_controller.dart';

class ConsentView extends GetView<ConsentController> {
  const ConsentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Informed Consent'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.imagePath != null && File(controller.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(controller.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Patient Data Protection & AI Assist Notice',
                    style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Multimodal AI Diagnostic Support:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This dermoscopy image and associated clinical variables will be processed by MedAssist AI deep neural networks (PyTorch ResNet-50) solely to provide clinical decision support and risk stratification.',
                    style: Get.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '2. Confidentiality & Pseudonymization:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Identifiable personal health data is never shared publicly. Records are identified only by pseudonymous codes (DZ-XX-PXXXX) compliant with national healthcare regulations.',
                    style: Get.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '3. Diagnostic Responsibility:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The AI analysis does not replace formal histopathology or a certified dermatologist physical examination. The licensed physician maintains final diagnostic responsibility.',
                    style: Get.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.hasConsented.value,
                  onChanged: (val) => controller.hasConsented.value = val ?? false,
                  title: const Text(
                    'Patient (or clinician on patient’s behalf) provides informed consent for digital dermoscopy analysis and encrypted tele-expertise referral.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: controller.hasConsented.value ? controller.proceedToForm : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Agree & Fill Clinical Features', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                )),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.cancel,
              child: const Text('Cancel & Retake Image'),
            ),
          ],
        ),
      ),
    );
  }
}
