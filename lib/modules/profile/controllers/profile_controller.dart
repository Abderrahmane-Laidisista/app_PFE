import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final user = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser.value;
    refreshProfile();
  }

  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      final updated = await _auth.fetchCurrentProfile();
      if (updated != null) {
        user.value = updated;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
  }
}
