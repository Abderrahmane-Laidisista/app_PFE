import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MedAssist AI V2',
              style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Multimodal Clinical Decision Support & Tele-Dermatology',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  'Version ${controller.appVersion.value} (Build ${controller.buildNumber.value})',
                  style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                )),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Academic & Regulatory Framework', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _buildBullet(
                      'Master 2 GLAA',
                      'Génie Logiciel et Applications Avancées (Software Engineering)',
                    ),
                    const SizedBox(height: 12),
                    _buildBullet(
                      'Ministerial Decree 1275',
                      'Diplôme - Startup / Diplôme - Brevet d’Invention (Algerian Ministry of Higher Education & Scientific Research)',
                    ),
                    const SizedBox(height: 12),
                    _buildBullet(
                      'AI Architecture',
                      'PyTorch Multimodal Cross-Attention Network (ResNet-50 Dermoscopy Feature Extractor + Tabular Metadata MLP)',
                    ),
                    const SizedBox(height: 12),
                    _buildBullet(
                      'Benchmark Evaluation',
                      'Trained and evaluated on ISIC 2019, HAM10000, and PAD-UFES-20 Clinical Datasets (6 diagnostic classes).',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 MedAssist AI Project. All rights reserved.',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
