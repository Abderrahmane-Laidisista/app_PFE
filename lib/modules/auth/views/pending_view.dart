import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class PendingView extends StatelessWidget {
  const PendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Pending',
                style: Get.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your clinician account has been submitted for validation. An authorized administrator will verify your medical license against the national registry before granting diagnostic and telemedicine access.',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = await auth.fetchCurrentProfile();
                    if (user != null && user.isActive) {
                      Get.offAllNamed(AppRoutes.HOME);
                      Get.snackbar('Approved', 'Your account is active. Welcome!');
                    } else {
                      Get.snackbar('Status Check', 'Your account is still pending administrator approval.');
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Approval Status'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
