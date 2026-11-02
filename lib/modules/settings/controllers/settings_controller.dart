import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/local_storage_provider.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  AuthService get _auth => Get.find<AuthService>();

  final apiController = TextEditingController();
  final currentLanguage = 'en'.obs;
  final isDarkMode = false.obs;

  bool get isAuthenticated => _localStorage.isAuthenticated;
  String? get doctorName => _auth.doctorFullName;

  @override
  void onInit() {
    super.onInit();
    apiController.text = _storageService.apiUrl;
    currentLanguage.value = _storageService.language;
    isDarkMode.value = _storageService.themeMode == 'dark';
  }

  void saveApiUrl() {
    final url = apiController.text.trim();
    if (url.isNotEmpty && url.startsWith('http')) {
      _storageService.setApiUrl(url);
      _localStorage.setApiUrl(url);
      Get.snackbar(
        'success'.tr,
        'API URL updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'error'.tr,
        'Please enter a valid URL starting with http/https',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeLanguage(String langCode) {
    currentLanguage.value = langCode;
    _storageService.setLanguage(langCode);
    _localStorage.setLanguage(langCode);
    Get.updateLocale(Locale(langCode));
  }

  void toggleTheme(bool val) {
    isDarkMode.value = val;
    final mode = val ? 'dark' : 'light';
    _storageService.setThemeMode(mode);
    _localStorage.setThemeMode(mode);
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  Future<void> clearAllData() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('delete_confirmation'.tr),
        content: const Text('This will delete all history, offline cache, and preferences. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Get.theme.colorScheme.error),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.clearAll();
      await _localStorage.clearOfflineAnalyses();
      Get.snackbar('success'.tr, 'All local data cleared successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    apiController.dispose();
    super.onClose();
  }
}
