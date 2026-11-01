import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/local_storage_provider.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final PageController pageController = PageController();

  final currentPage = 0.obs;
  final totalPages = 4;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'onboarding_title_1',
      description: 'onboarding_desc_1',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF2196F3),
    ),
    OnboardingPage(
      title: 'onboarding_title_2',
      description: 'onboarding_desc_2',
      icon: Icons.camera_alt_rounded,
      color: const Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'onboarding_title_3',
      description: 'onboarding_desc_3',
      icon: Icons.security_rounded,
      color: const Color(0xFFFF9800),
    ),
    OnboardingPage(
      title: 'Clinician Registration',
      description: 'Register your medical license to unlock PostgreSQL persistence and dispatch Tele-expertise referrals to specialists.',
      icon: Icons.medical_services_rounded,
      color: const Color(0xFF7C3AED),
      isRawText: true,
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> goToRegister() async {
    await _markFirstTimeDone();
    Get.offAllNamed(AppRoutes.REGISTER);
  }

  Future<void> goToLogin() async {
    await _markFirstTimeDone();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  Future<void> finishOnboarding() async {
    await _markFirstTimeDone();
    Get.offAllNamed(AppRoutes.HOME);
  }

  Future<void> _markFirstTimeDone() async {
    await _storageService.setFirstTime(false);
    await _localStorage.setFirstTime(false);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isRawText;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isRawText = false,
  });
}
