import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../patients/controllers/patients_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../referrals/controllers/referrals_controller.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PatientsController>(() => PatientsController());
    Get.lazyPut<ReferralsController>(() => ReferralsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
