import 'package:get/get.dart';
import '../../../data/repositories/referral_repository.dart';
import '../controllers/doctor_directory_controller.dart';

class DoctorDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReferralRepository>()) {
      Get.lazyPut<ReferralRepository>(() => ReferralRepository());
    }
    Get.lazyPut<DoctorDirectoryController>(() => DoctorDirectoryController());
  }
}
