import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void fillDemoCredentials(String role) {
    if (role == 'specialist') {
      emailController.text = 'dr.benali@chu-oran.dz';
      passwordController.text = 'DoctorPass123!';
    } else if (role == 'gp') {
      emailController.text = 'doctor.amara@medassist.dz';
      passwordController.text = 'DoctorPass123!';
    } else {
      emailController.text = 'admin@medassist.dz';
      passwordController.text = 'Admin@MedAssist2026!';
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final authResp = await _auth.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = authResp.user;
      if (user != null && user.isPending) {
        Get.offAllNamed(AppRoutes.PENDING_VERIFICATION);
      } else if (user != null && user.mustChangePassword) {
        Get.offAllNamed(AppRoutes.FORCE_CHANGE_PASSWORD);
      } else {
        Get.offAllNamed(AppRoutes.MAIN_LAYOUT);
      }

      Get.snackbar(
        'Welcome',
        user?.profile?.fullName.isNotEmpty == true
            ? 'Logged in as ${user!.profile!.fullName}'
            : 'Welcome back, Doctor',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void continueAsGuest() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
