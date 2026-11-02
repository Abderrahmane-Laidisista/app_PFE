import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';

class MainLayoutController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final currentIndex = 0.obs;

  bool get isDoctor => _auth.isDoctor;
  String? get doctorName => _auth.doctorFullName;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
