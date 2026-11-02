import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../main_layout/controllers/main_layout_controller.dart';

class HomeController extends GetxController {
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final AuthService _auth = Get.find<AuthService>();
  final LocalStorageProvider _storage = Get.find<LocalStorageProvider>();
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;

  final RxBool isAuthenticated = false.obs;
  final RxBool isDoctor = false.obs;
  final RxnString clinicianName = RxnString();

  @override
  void onInit() {
    super.onInit();
    _syncAuthState();
    ever(_auth.currentUser, (_) => _syncAuthState());
    _checkConnectivity();
  }

  @override
  void onReady() {
    super.onReady();
    _syncAuthState();
  }

  void _syncAuthState() {
    isAuthenticated.value = _storage.isAuthenticated || _auth.currentUser.value != null;
    isDoctor.value = _auth.isDoctor;
    clinicianName.value = _auth.doctorFullName;
  }

  void _checkConnectivity() {
    if (!_connectivityService.isOnline.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Offline Mode",
          "You are offline. Diagnostic histories will load from local cache.",
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  // Navigate to Camera Screen
  Future<void> takePhoto() async {
    try {
      Get.toNamed(AppRoutes.CAMERA);
    } catch (e) {
      debugPrint('Error navigating to camera: $e');
      Get.snackbar('error'.tr, 'error_camera_permission'.tr);
    }
  }

  // Upload from Gallery
  Future<void> uploadFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        // Route through Consent before Clinical Form
        Get.toNamed(
          AppRoutes.CONSENT,
          arguments: {'imagePath': image.path},
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('error'.tr, 'error_invalid_image'.tr);
    }
  }

  void viewHistory() {
    Get.toNamed(AppRoutes.HISTORY);
  }

  void openSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  void openEducation() {
    Get.toNamed(AppRoutes.EDUCATION);
  }

  void openAbout() {
    Get.toNamed(AppRoutes.ABOUT);
  }

  void openLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }

  void openProfile() {
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changeTab(3);
    } else {
      Get.toNamed(AppRoutes.PROFILE);
    }
  }

  void openPatients() {
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changeTab(1);
    } else {
      Get.toNamed(AppRoutes.PATIENTS);
    }
  }

  void openReferrals() {
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changeTab(2);
    } else {
      Get.toNamed(AppRoutes.REFERRALS);
    }
  }

  void openDoctorDirectory() {
    Get.toNamed(AppRoutes.DOCTOR_DIRECTORY);
  }

  void openQRFollowUp() {
    Get.toNamed(AppRoutes.QR_FOLLOWUP);
  }
}
