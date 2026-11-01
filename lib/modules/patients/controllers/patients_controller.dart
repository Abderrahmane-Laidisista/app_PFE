import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/patient_repository.dart';

class PatientsController extends GetxController {
  final PatientRepository _repo = Get.find<PatientRepository>();

  final patients = <PatientModel>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;
  final searchQuery = ''.obs;

  final selectedPatient = Rxn<PatientModel>();
  final isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
    debounce(searchQuery, (_) => loadPatients(), time: const Duration(milliseconds: 400));
  }

  Future<void> loadPatients() async {
    isLoading.value = true;
    try {
      final list = await _repo.getPatients(search: searchQuery.value);
      patients.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPatient({
    required String code,
    int? birthYear,
    required String sex,
    String? notes,
  }) async {
    isCreating.value = true;
    try {
      final req = PatientCreateRequest(
        patientCode: code.trim(),
        birthYear: birthYear,
        sex: sex,
        notes: notes,
      );

      final created = await _repo.createPatient(req);
      patients.insert(0, created);
      Get.back(); // close dialog
      Get.snackbar(
        'Patient Created',
        'Pseudonymous patient ${created.patientCode} registered.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> openPatientDetail(String patientId) async {
    isLoadingDetail.value = true;
    selectedPatient.value = null;
    try {
      final detail = await _repo.getPatientDetail(patientId);
      selectedPatient.value = detail;
    } finally {
      isLoadingDetail.value = false;
    }
  }
}
