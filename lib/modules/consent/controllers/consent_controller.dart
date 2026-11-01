import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class ConsentController extends GetxController {
  String? imagePath;
  final hasConsented = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['imagePath'] != null) {
      imagePath = args['imagePath'].toString();
    }
  }

  void proceedToForm() {
    if (!hasConsented.value) {
      Get.snackbar(
        'Consent Required',
        'Patient or clinician consent must be acknowledged before proceeding.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.CLINICAL_FORM,
      arguments: {'imagePath': imagePath},
    );
  }

  void cancel() {
    Get.back();
  }
}
