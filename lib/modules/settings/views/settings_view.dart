import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Debug Only: API Configuration ─────────────────
            if (kDebugMode) ...[
              _buildSectionHeader(Icons.cloud_sync, 'API Configuration (Debug Mode)'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Backend Server API URL', style: Get.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.apiController,
                      decoration: InputDecoration(
                        hintText: 'http://10.0.2.2:8000/api/v1',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save, color: AppColors.primary),
                          onPressed: controller.saveApiUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Emulator: 10.0.2.2:8000 | LAN: <IP>:8000 | Production: api.medassist.dz',
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Language ──────────────────────────────────────
            _buildSectionHeader(Icons.language, 'Language (اللغة)'),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Obx(() => RadioListTile<String>(
                        title: const Text('English (Default)'),
                        value: 'en',
                        groupValue: controller.currentLanguage.value,
                        onChanged: (val) => controller.changeLanguage(val!),
                      )),
                  const Divider(height: 1),
                  Obx(() => RadioListTile<String>(
                        title: const Text('Français'),
                        value: 'fr',
                        groupValue: controller.currentLanguage.value,
                        onChanged: (val) => controller.changeLanguage(val!),
                      )),
                  const Divider(height: 1),
                  Obx(() => RadioListTile<String>(
                        title: const Text('العربية (Arabic - RTL)'),
                        value: 'ar',
                        groupValue: controller.currentLanguage.value,
                        onChanged: (val) => controller.changeLanguage(val!),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Appearance / Dark Mode ────────────────────────
            _buildSectionHeader(Icons.palette_outlined, 'Appearance'),
            Container(
              decoration: _cardDecoration(),
              child: Obx(() => SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable low-light clinical theme'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleTheme,
                  )),
            ),

            const SizedBox(height: 24),

            // ── Data Management ───────────────────────────────
            _buildSectionHeader(Icons.storage, 'Data Management'),
            Container(
              decoration: _cardDecoration(),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Clear All Local Data', style: TextStyle(color: AppColors.error)),
                subtitle: const Text('Deletes offline cached analyses and reset preferences'),
                onTap: controller.clearAllData,
              ),
            ),

            // ── Clinician Account Session (Doctor Only) ────────
            Obx(() {
              if (controller.isAuthenticated) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.security, 'Clinician Session'),
                    Container(
                      decoration: _cardDecoration(),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: Text(
                          'Sign Out (${controller.doctorName ?? "Doctor"})',
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Ends authenticated session on this mobile device'),
                        onTap: controller.logout,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 36),

            // ── About ─────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text('app_name'.tr, style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Version 2.0.0 (Startup Thesis — Decree 1275)', style: Get.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
