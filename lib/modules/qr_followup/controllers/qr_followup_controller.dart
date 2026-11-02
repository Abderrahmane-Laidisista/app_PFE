import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/qr_followup_model.dart';
import '../../../data/repositories/diagnosis_repository.dart';

class QRFollowUpController extends GetxController {
  final DiagnosisRepository _repo = Get.find<DiagnosisRepository>();

  final tokenController = TextEditingController();
  final isLoading = false.obs;
  final followUpData = Rxn<PatientQRFollowUpModel>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['token'] != null) {
      tokenController.text = args['token'].toString();
      fetchFollowUp();
    }
  }

  Future<void> fetchFollowUp() async {
    final token = tokenController.text.trim();
    if (token.isEmpty) {
      Get.snackbar(
        'Token Required',
        'Please enter or scan a valid QR follow-up token',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    followUpData.value = null;

    try {
      final res = await _repo.getPatientQRFollowUp(token);
      if (res != null) {
        followUpData.value = res;
      } else {
        errorMessage.value = 'Invalid or expired QR token. Please consult your physician.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load follow-up details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    tokenController.clear();
    followUpData.value = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    tokenController.dispose();
    super.onClose();
  }
}
