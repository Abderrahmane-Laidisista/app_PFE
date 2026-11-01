import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/public_doctor.dart';
import '../../../data/models/referral_model.dart';
import '../../../data/repositories/referral_repository.dart';

class ReferralsController extends GetxController {
  final ReferralRepository _repo = Get.find<ReferralRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final sentReferrals = <ReferralModel>[].obs;
  final receivedReferrals = <ReferralModel>[].obs;
  final specialists = <PublicDoctor>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  bool get isDoctor => _auth.isDoctor;

  // New referral form state
  final analysisId = ''.obs;
  final selectedSpecialistId = RxnString();
  final referralNoteController = TextEditingController();
  final predictedClass = ''.obs;
  final confidence = 0.0.obs;
  final riskLevel = ''.obs;
  final imageUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['analysisId'] != null) {
        analysisId.value = args['analysisId'].toString();
      }
      if (args['predictedClass'] != null) {
        predictedClass.value = args['predictedClass'].toString();
      }
      if (args['confidence'] != null) {
        confidence.value = (args['confidence'] as num).toDouble();
      }
      if (args['riskLevel'] != null) {
        riskLevel.value = args['riskLevel'].toString();
      }
      if (args['imageUrl'] != null) {
        imageUrl.value = args['imageUrl'].toString();
      }
    }

    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadSentReferrals(),
        loadReceivedReferrals(),
        loadSpecialists(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSentReferrals() async {
    try {
      final list = await _repo.getSentReferrals();
      sentReferrals.value = list;
    } catch (e) {
      debugPrint('❌ Error loading sent referrals: $e');
    }
  }

  Future<void> loadReceivedReferrals() async {
    try {
      final list = await _repo.getReceivedReferrals();
      receivedReferrals.value = list;
    } catch (e) {
      debugPrint('❌ Error loading received referrals: $e');
    }
  }

  Future<void> loadSpecialists() async {
    try {
      final list = await _repo.getPublicDoctors(doctorType: 'specialist_dermatologist');
      specialists.value = list;
    } catch (e) {
      debugPrint('❌ Error loading specialists: $e');
    }
  }

  Future<void> submitReferral() async {
    if (analysisId.value.isEmpty) {
      Get.snackbar('Error', 'Missing analysis reference to refer.');
      return;
    }
    if (referralNoteController.text.trim().isEmpty) {
      Get.snackbar('Note Required', 'Please enter a clinical referral note for the specialist.');
      return;
    }

    isSubmitting.value = true;
    try {
      final req = ReferralCreateRequest(
        analysisId: analysisId.value,
        specialistId: selectedSpecialistId.value,
        referralNote: referralNoteController.text.trim(),
      );

      final created = await _repo.createReferral(req);
      sentReferrals.insert(0, created);
      referralNoteController.clear();

      Get.snackbar(
        'Referral Dispatched',
        'Tele-expertise case successfully dispatched to specialist dermatologist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Referral Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> respondToReferral({
    required String referralId,
    required String responseText,
    String status = 'completed',
  }) async {
    isSubmitting.value = true;
    try {
      final req = ReferralRespondRequest(
        status: status,
        specialistResponse: responseText,
      );

      final updated = await _repo.respondReferral(referralId, req);

      final idx = receivedReferrals.indexWhere((r) => r.id == referralId);
      if (idx != -1) {
        receivedReferrals[idx] = updated;
      }

      Get.back(); // close modal
      Get.snackbar(
        'Response Submitted',
        'Specialist opinion successfully saved and transmitted to referring GP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit response: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    referralNoteController.dispose();
    super.onClose();
  }
}
