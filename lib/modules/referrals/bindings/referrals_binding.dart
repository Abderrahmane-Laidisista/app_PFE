import 'package:get/get.dart';
import '../../../data/repositories/referral_repository.dart';
import '../controllers/referrals_controller.dart';

class ReferralsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReferralRepository>()) {
      Get.lazyPut<ReferralRepository>(() => ReferralRepository());
    }
    Get.lazyPut<ReferralsController>(() => ReferralsController());
  }
}
