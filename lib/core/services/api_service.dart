import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/patient_metadata.dart';
import '../../data/models/prediction_request.dart';
import '../../data/models/prediction_response.dart';
import '../../data/repositories/diagnosis_repository.dart';
import '../services/storage_service.dart';

/// Legacy Service adapter delegating to the modern DiagnosisRepository and ApiProvider.
class ApiService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  DiagnosisRepository get _repository => Get.find<DiagnosisRepository>();

  String get baseUrl => _storageService.apiUrl;

  /// Multimodal prediction adapter
  Future<PredictionResponse> predict(
    String imagePath,
    PatientMetadata metadata, {
    String? patientId,
    String? lesionTag,
    bool useTta = false,
  }) async {
    final req = PredictionRequest.fromMetadata(
      imagePath: imagePath,
      metadata: metadata,
      patientId: patientId,
      lesionTag: lesionTag,
      useTta: useTta,
    );

    return await _repository.predict(req);
  }
}
