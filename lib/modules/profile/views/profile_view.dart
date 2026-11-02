import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshProfile,
          ),
        ],
      ),
      body: Obx(() {
        final u = controller.user.value;
        final p = u?.profile;

        if (controller.isLoading.value && u == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Name Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        p?.fullName.isNotEmpty == true ? p!.fullName : (u?.email ?? 'Clinician'),
                        style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p?.doctorType == 'specialist_dermatologist'
                            ? 'Specialist Dermatologist & Venereologist'
                            : 'General Practitioner (Frontline Clinician)',
                        style: TextStyle(
                          color: p?.doctorType == 'specialist_dermatologist' ? const Color(0xFF7C3AED) : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'STATUS: ${u?.status.toUpperCase() ?? "ACTIVE"}',
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Institutional & Licensing Details
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Licensing & Healthcare Structure',
                        style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.badge_outlined, 'Order License #', p?.licenseNumber ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.medical_services_outlined, 'Specialization', p?.specialization ?? 'General Practice'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.local_hospital_outlined, 'Healthcare Facility', p?.institutionName ?? 'Hospital Center'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.map_outlined, 'Wilaya Code', p?.wilaya != null ? 'Wilaya ${p!.wilaya}' : 'National'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.email_outlined, 'Email', u?.email ?? ''),
                      if (p?.phone != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.phone_outlined, 'Phone', p!.phone!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out from Platform', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
