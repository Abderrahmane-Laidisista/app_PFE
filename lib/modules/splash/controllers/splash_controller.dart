import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/providers/local_storage_provider.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      final storage = Get.find<LocalStorageProvider>();
      final auth = Get.find<AuthService>();

      // Check first time flag
      if (storage.isFirstTime) {
        debugPrint('🎯 Splash: First time user -> Onboarding');
        Get.offAllNamed(AppRoutes.ONBOARDING);
        return;
      }

      // Check authentication
      if (storage.isAuthenticated) {
        final user = await auth.fetchCurrentProfile();
        if (user != null) {
          if (user.isPending) {
            Get.offAllNamed(AppRoutes.PENDING_VERIFICATION);
            return;
          }
          if (user.mustChangePassword) {
            Get.offAllNamed(AppRoutes.FORCE_CHANGE_PASSWORD);
            return;
          }
          // Authenticated & active -> Doctor Main Shell
          Get.offAllNamed(AppRoutes.MAIN_LAYOUT);
          return;
        }
      }

      // Default navigate to Home (adaptive for Guest)
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      debugPrint('❌ Splash Error: $e');
      Get.offAllNamed(AppRoutes.HOME);
    }
  }
}
