import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../app/config/api/api_constants.dart';
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';
import '../models/qr_followup_model.dart';
import '../providers/api_provider.dart';
import '../providers/local_storage_provider.dart';

/// Repository handling multimodal prediction, clinical concordance feedback, and QR follow-ups.
class DiagnosisRepository extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();
  final LocalStorageProvider _storage = Get.find<LocalStorageProvider>();

  /// Execute multipart inference call to POST /predict
  Future<PredictionResponse> predict(PredictionRequest request) async {
    try {
      final fields = request.toFormData();

      // Read image bytes (works on mobile and web using XFile)
      final xFile = XFile(request.imagePath);
      final bytes = await xFile.readAsBytes();
      final filename = xFile.name.isNotEmpty ? xFile.name : 'lesion.jpg';

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      );

      final hasToken = _storage.isAuthenticated;
      debugPrint('🚀 Sending inference request | Auth: $hasToken | Image: $filename (${bytes.length} bytes)');

      final response = await _api.multipartPost(
        ApiConstants.predict,
        fields: fields,
        files: [multipartFile],
        requiresAuth: hasToken,
        timeout: ApiConstants.inferenceTimeout,
      );

      debugPrint('📥 Inference response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);
        final prediction = PredictionResponse.fromJson(jsonBody);

        // Cache locally for offline consults
        await _cachePredictionLocally(request, prediction);

        return prediction;
      } else {
        String errorMsg = 'Failed to analyze lesion: [${response.statusCode}]';
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['detail'] != null) {
            errorMsg = errJson['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Prediction failure: $e');
      rethrow;
    }
  }

  /// Submit clinical doctor feedback (concordance ground truth)
  Future<bool> submitFeedback({
    required String analysisId,
    required bool doctorConfirmed,
    String? doctorDiagnosis,
    bool? biopsyPerformed,
    String? biopsyResult,
    String? nextFollowupDate,
  }) async {
    try {
      final body = {
        'doctor_confirmed': doctorConfirmed,
        if (doctorDiagnosis != null) 'doctor_diagnosis': doctorDiagnosis,
        if (biopsyPerformed != null) 'biopsy_performed': biopsyPerformed,
        if (biopsyResult != null) 'biopsy_result': biopsyResult,
        if (nextFollowupDate != null) 'next_followup_date': nextFollowupDate,
      };

      final response = await _api.put(
        ApiConstants.analysisFeedback(analysisId),
        body: body,
        requiresAuth: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Feedback submission failed: $e');
      return false;
    }
  }

  /// Fetch patient follow-up summary via scanned QR code token (unauthenticated public access)
  Future<PatientQRFollowUpModel?> getPatientQRFollowUp(String token) async {
    try {
      final response = await _api.get(
        ApiConstants.qrFollowUp(token),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PatientQRFollowUpModel.fromJson(data);
      } else {
        debugPrint('⚠️ QR Follow-up query returned: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ QR Follow-up retrieval failed: $e');
      return null;
    }
  }

  Future<void> _cachePredictionLocally(
    PredictionRequest request,
    PredictionResponse prediction,
  ) async {
    try {
      final item = {
        'id': prediction.analysisId ?? UniqueKey().toString(),
        'date': prediction.timestamp.toIso8601String(),
        'imagePath': request.imagePath,
        'image_url': prediction.imageUrl,
        'gradcam_url': prediction.gradcamUrl,
        'diagnosis': prediction.predictedClass,
        'confidence': prediction.confidence,
        'risk_level': prediction.riskLevel,
        'patient_id': prediction.patientId ?? request.patientId,
        'lesion_tag': prediction.lesionTag ?? request.lesionTag,
        'allProbabilities': prediction.allProbabilities,
        'metadata': {
          'age': request.age,
          'sex': request.sex,
          'region': request.localization,
          'diameter': request.diameter1,
          'grew': request.grew,
          'bleed': request.bleed,
          'elevation': request.elevation,
          'skin_cancer_history': request.skinCancerHistory,
        },
      };

      await _storage.addOfflineAnalysis(item);
    } catch (e) {
      debugPrint('⚠️ Failed to cache prediction locally: $e');
    }
  }
}
