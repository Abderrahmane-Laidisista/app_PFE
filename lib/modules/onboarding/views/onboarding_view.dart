import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  TextButton(
                    onPressed: controller.finishOnboarding,
                    child: Text(
                      'skip'.tr,
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.totalPages,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(controller.pages[index]);
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.totalPages,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Actions
                  Obx(() {
                    final isLastPage = controller.currentPage.value == controller.totalPages - 1;

                    if (isLastPage) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.goToRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Register Clinician Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: controller.goToLogin,
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: const Text('Sign In'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextButton(
                                  onPressed: controller.finishOnboarding,
                                  child: const Text('Browse as Guest'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        if (controller.currentPage.value > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.previousPage,
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: Text('previous'.tr),
                            ),
                          ),
                        if (controller.currentPage.value > 0) const SizedBox(width: 16),
                        Expanded(
                          flex: controller.currentPage.value > 0 ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: controller.nextPage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text('next'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 88,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.isRawText ? page.title : page.title.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.isRawText ? page.description : page.description.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Obx(() {
      final isActive = controller.currentPage.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.grey300,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }
}
