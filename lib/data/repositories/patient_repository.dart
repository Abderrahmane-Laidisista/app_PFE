import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../app/config/api/api_constants.dart';
import '../models/patient_model.dart';
import '../providers/api_provider.dart';

/// Repository for patient management and longitudinal lesion timeline tracking.
class PatientRepository extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();

  /// Fetch paginated patients
  Future<List<PatientModel>> getPatients({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _api.get(
        ApiConstants.patients,
        queryParameters: query,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = data['items'] as List? ?? [];
        return list
            .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching patients: $e');
      return [];
    }
  }

  /// Create new pseudonymous patient
  Future<PatientModel> createPatient(PatientCreateRequest request) async {
    final response = await _api.post(
      ApiConstants.patients,
      body: request.toJson(),
      requiresAuth: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PatientModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      String msg = 'Failed to create patient: [${response.statusCode}]';
      try {
        final err = jsonDecode(response.body);
        if (err['detail'] != null) msg = err['detail'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// Get patient file with full lesion timeline
  Future<PatientModel?> getPatientDetail(String patientId) async {
    try {
      final response = await _api.get(
        ApiConstants.patientDetail(patientId),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PatientModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching patient detail: $e');
      return null;
    }
  }
}
