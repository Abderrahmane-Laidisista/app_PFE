import 'package:get/get.dart';
import '../../../data/repositories/patient_repository.dart';
import '../controllers/patients_controller.dart';

class PatientsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PatientRepository>()) {
      Get.lazyPut<PatientRepository>(() => PatientRepository());
    }
    Get.lazyPut<PatientsController>(() => PatientsController());
  }
}
