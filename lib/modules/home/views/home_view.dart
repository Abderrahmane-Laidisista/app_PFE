import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero App Bar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 230,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: Stack(
                    children: [
                      // Main hero content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'app_name'.tr,
                              style: Get.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              if (controller.isAuthenticated.value) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Dr. ${controller.clinicianName.value ?? "Clinician"} (Active)',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                );
                              }
                              return Text(
                                'home_subtitle'.tr,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'app_name'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              actions: [
                Obx(() {
                  if (controller.isAuthenticated.value) {
                    return IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.white),
                      tooltip: 'Clinician Profile',
                      onPressed: controller.openProfile,
                    );
                  }
                  return TextButton(
                    onPressed: controller.openLogin,
                    child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: controller.openSettings,
                ),
              ],
            ),

            // ── Scrollable Body Content ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Notice (if unauthenticated)
                    Obx(() {
                      if (!controller.isAuthenticated.value) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_open_rounded, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Guest Mode active. Sign in with your clinician account to enable PostgreSQL persistence and Tele-expertise referrals.',
                                  style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                              TextButton(
                                onPressed: controller.openLogin,
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Section: Clinical Diagnosis
                    Text(
                      'Multimodal Skin Lesion Analysis',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Primary Action Cards (Camera + Gallery)
                    _buildActionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'take_photo'.tr,
                      subtitle: 'Direct dermoscopy camera capture with guidance circle',
                      gradient: AppColors.primaryGradient,
                      onTap: controller.takePhoto,
                    ),

                    const SizedBox(height: 14),

                    _buildActionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'upload_photo'.tr,
                      subtitle: 'Import high-resolution clinical photo from gallery',
                      gradient: AppColors.secondaryGradient,
                      onTap: controller.uploadFromGallery,
                    ),

                    const SizedBox(height: 28),

                    // Section: Telemedicine & Practice Management
                    Text(
                      'Tele-Dermatology & Clinical Modules',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4-Card Practice Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.45,
                      children: [
                        _buildModuleTile(
                          icon: Icons.folder_shared_outlined,
                          title: 'Patient Registry',
                          subtitle: 'Pseudonymous files & lesion timelines',
                          color: AppColors.primary,
                          onTap: controller.openPatients,
                        ),
                        _buildModuleTile(
                          icon: Icons.connect_without_contact_rounded,
                          title: 'Tele-expertise',
                          subtitle: 'GP -> Specialist referrals',
                          color: const Color(0xFF7C3AED),
                          onTap: controller.openReferrals,
                        ),
                        _buildModuleTile(
                          icon: Icons.local_hospital_outlined,
                          title: 'Doctor Directory',
                          subtitle: 'Verified dermatologists pool',
                          color: AppColors.secondary,
                          onTap: controller.openDoctorDirectory,
                        ),
                        _buildModuleTile(
                          icon: Icons.history_rounded,
                          title: 'view_history'.tr,
                          subtitle: 'Past analyses & offline cache',
                          color: AppColors.accent,
                          onTap: controller.viewHistory,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Utility Row (Learn ABCDE & About Thesis)
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            icon: Icons.school_outlined,
                            title: 'Learn ABCDE Rule',
                            iconColor: AppColors.secondary,
                            bgColor: AppColors.secondary.withValues(alpha: 0.1),
                            onTap: controller.openEducation,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            icon: Icons.info_outline_rounded,
                            title: 'About PFE Thesis',
                            iconColor: AppColors.primary,
                            bgColor: AppColors.primary.withValues(alpha: 0.1),
                            onTap: controller.openAbout,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Patient QR Follow-up (Checkup & Token)',
                      iconColor: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      onTap: controller.openQRFollowUp,
                    ),

                    const SizedBox(height: 24),

                    // Clinical Disclaimer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'disclaimer_text'.tr,
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
