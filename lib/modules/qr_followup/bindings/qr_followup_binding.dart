import 'package:get/get.dart';
import '../controllers/qr_followup_controller.dart';

class QRFollowUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRFollowUpController>(() => QRFollowUpController());
  }
}
