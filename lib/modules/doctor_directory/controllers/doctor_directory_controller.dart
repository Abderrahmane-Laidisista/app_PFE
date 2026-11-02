import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/public_doctor.dart';
import '../../../data/repositories/referral_repository.dart';

class DoctorDirectoryController extends GetxController {
  final ReferralRepository _repo = Get.find<ReferralRepository>();

  final doctors = <PublicDoctor>[].obs;
  final isLoading = false.obs;
  final selectedType = RxnString();
  final selectedWilaya = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    isLoading.value = true;
    try {
      final list = await _repo.getPublicDoctors(
        wilaya: selectedWilaya.value,
        doctorType: selectedType.value,
      );
      doctors.value = list;
    } catch (e) {
      debugPrint('❌ Error loading directory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByType(String? type) {
    selectedType.value = type;
    loadDoctors();
  }

  void filterByWilaya(String? w) {
    selectedWilaya.value = w;
    loadDoctors();
  }
}
