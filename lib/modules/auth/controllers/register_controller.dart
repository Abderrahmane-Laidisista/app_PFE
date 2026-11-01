import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final currentStep = 0.obs;
  final isLoading = false.obs;

  // Step 1: Account
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final isPasswordVisible = false.obs;

  // Step 2: Professional Credentials
  final doctorType = 'general_practitioner'.obs;
  final specializationController = TextEditingController(text: 'General Medicine');
  final licenseNumberController = TextEditingController();
  final institutionNameController = TextEditingController();
  final phoneController = TextEditingController();
  final wilaya = '16'.obs; // 16 = Alger default

  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();

  // 58 Algerian Wilayas
  final List<Map<String, String>> wilayas = [
    {'code': '01', 'name': '01 - Adrar'},
    {'code': '02', 'name': '02 - Chlef'},
    {'code': '03', 'name': '03 - Laghouat'},
    {'code': '04', 'name': '04 - Oum El Bouaghi'},
    {'code': '05', 'name': '05 - Batna'},
    {'code': '06', 'name': '06 - Béjaïa'},
    {'code': '07', 'name': '07 - Biskra'},
    {'code': '08', 'name': '08 - Béchar'},
    {'code': '09', 'name': '09 - Blida'},
    {'code': '10', 'name': '10 - Bouira'},
    {'code': '11', 'name': '11 - Tamanrasset'},
    {'code': '12', 'name': '12 - Tébessa'},
    {'code': '13', 'name': '13 - Tlemcen'},
    {'code': '14', 'name': '14 - Tiaret'},
    {'code': '15', 'name': '15 - Tizi Ouzou'},
    {'code': '16', 'name': '16 - Alger'},
    {'code': '17', 'name': '17 - Djelfa'},
    {'code': '18', 'name': '18 - Jijel'},
    {'code': '19', 'name': '19 - Sétif'},
    {'code': '20', 'name': '20 - Saïda'},
    {'code': '21', 'name': '21 - Skikda'},
    {'code': '22', 'name': '22 - Sidi Bel Abbès'},
    {'code': '23', 'name': '23 - Annaba'},
    {'code': '24', 'name': '24 - Guelma'},
    {'code': '25', 'name': '25 - Constantine'},
    {'code': '26', 'name': '26 - Médéa'},
    {'code': '27', 'name': '27 - Mostaganem'},
    {'code': '28', 'name': '28 - M\'Sila'},
    {'code': '29', 'name': '29 - Mascara'},
    {'code': '30', 'name': '30 - Ouargla'},
    {'code': '31', 'name': '31 - Oran'},
    {'code': '32', 'name': '32 - El Bayadh'},
    {'code': '33', 'name': '33 - Illizi'},
    {'code': '34', 'name': '34 - Bordj Bou Arréridj'},
    {'code': '35', 'name': '35 - Boumerdès'},
    {'code': '36', 'name': '36 - El Tarf'},
    {'code': '37', 'name': '37 - Tindouf'},
    {'code': '38', 'name': '38 - Tissemsilt'},
    {'code': '39', 'name': '39 - El Oued'},
    {'code': '40', 'name': '40 - Khenchela'},
    {'code': '41', 'name': '41 - Souk Ahras'},
    {'code': '42', 'name': '42 - Tipaza'},
    {'code': '43', 'name': '43 - Mila'},
    {'code': '44', 'name': '44 - Aïn Defla'},
    {'code': '45', 'name': '45 - Naâma'},
    {'code': '46', 'name': '46 - Aïn Témouchent'},
    {'code': '47', 'name': '47 - Ghardaïa'},
    {'code': '48', 'name': '48 - Relizane'},
    {'code': '49', 'name': '49 - Timimoun'},
    {'code': '50', 'name': '50 - Bordj Badji Mokhtar'},
    {'code': '51', 'name': '51 - Ouled Djellal'},
    {'code': '52', 'name': '52 - Béni Abbès'},
    {'code': '53', 'name': '53 - In Salah'},
    {'code': '54', 'name': '54 - In Guezzam'},
    {'code': '55', 'name': '55 - Touggourt'},
    {'code': '56', 'name': '56 - Djanet'},
    {'code': '57', 'name': '57 - El M\'Ghair'},
    {'code': '58', 'name': '58 - El Meniaa'},
  ];

  void nextStep() {
    if (currentStep.value == 0) {
      if (!step1Key.currentState!.validate()) return;
      currentStep.value = 1;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void setDoctorType(String type) {
    doctorType.value = type;
    if (type == 'specialist_dermatologist') {
      specializationController.text = 'Dermatology & Venereology';
    } else {
      specializationController.text = 'General Medicine';
    }
  }

  Future<void> submitRegistration() async {
    if (!step2Key.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        doctorType: doctorType.value,
        specialization: specializationController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
        institutionName: institutionNameController.text.trim(),
        phone: phoneController.text.trim(),
        wilaya: wilaya.value,
      );

      Get.offAllNamed(AppRoutes.PENDING_VERIFICATION);
      Get.snackbar(
        'Registration Submitted',
        'Your clinician account has been registered and is pending admin approval.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    specializationController.dispose();
    licenseNumberController.dispose();
    institutionNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
