import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../app/config/api/api_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/patient_metadata.dart';
import '../../../data/models/prediction_response.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../../data/repositories/diagnosis_repository.dart';

class ResultController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final PdfService _pdfService = Get.find<PdfService>();
  DiagnosisRepository get _diagnosisRepo => Get.find<DiagnosisRepository>();
  LocalStorageProvider get _localStorage => Get.find<LocalStorageProvider>();

  String? imagePath;
  PatientMetadata? metadata;
  PredictionResponse? result;

  final showProbabilities = false.obs;
  final showHeatmap = false.obs;
  final isLoadingGradcam = false.obs;
  final resolvedGradcamUrl = RxnString(); // Toggle between Raw Dermoscopy and Grad-CAM++ Saliency Heatmap
  final isSubmittingFeedback = false.obs;
  final feedbackSubmitted = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get data from arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      imagePath = args['imagePath'];
      metadata = args['metadata'];
      result = args['result'];
    }

    if (result == null) {
      debugPrint('❌ No result data');
      Get.back();
      return;
    }

    debugPrint('✅ Result loaded: ${result!.predictedClass} | Risk: ${result!.riskLevel} | Analysis ID: ${result!.analysisId}');
  }

  void toggleProbabilities() {
    showProbabilities.value = !showProbabilities.value;
  }

  Future<void> toggleHeatmap() async {
    final targetState = !showHeatmap.value;
    showHeatmap.value = targetState;

    if (targetState &&
        resolvedGradcamUrl.value == null &&
        result?.gradcamHeatmapBase64 == null &&
        result?.analysisId != null &&
        _localStorage.isAuthenticated) {
      isLoadingGradcam.value = true;
      try {
        final api = Get.find<ApiProvider>();
        for (int attempt = 0; attempt < 3; attempt++) {
          final resp = await api.get(
            ApiConstants.analysisDetail(result!.analysisId!),
            requiresAuth: true,
          );
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body) as Map<String, dynamic>;
            final rawUrl = data['gradcam_url'] as String?;
            if (rawUrl != null && rawUrl.isNotEmpty) {
              resolvedGradcamUrl.value = rawUrl;
              break;
            }
          }
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch async Grad-CAM URL: $e');
      } finally {
        isLoadingGradcam.value = false;
      }
    }
  }

  Future<void> saveResult() async {
    try {
      final historyEntry = {
        'id': result!.analysisId ?? UniqueKey().toString(),
        'date': result!.timestamp.toIso8601String(),
        'imagePath': imagePath,
        'image_url': result!.imageUrl,
        'gradcam_url': result!.gradcamUrl,
        'diagnosis': result!.predictedClass,
        'confidence': result!.confidence,
        'riskLevel': result!.riskLevel,
        'metadata': metadata?.toJson(),
        'allProbabilities': result!.allProbabilities,
      };

      await _storageService.addDiagnosisToHistory(historyEntry);
      final existing = _localStorage.getOfflineAnalyses();
      final alreadySaved = existing.any((e) => e['id'] == historyEntry['id']);
      if (!alreadySaved) {
        await _localStorage.addOfflineAnalysis(historyEntry);
      }
      debugPrint('✅ Result saved to history and synchronized with offline analyses');

      Get.snackbar(
        'success'.tr,
        'Result saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      debugPrint('❌ Error saving result: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to save result',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportPdfReport() async {
    if (result == null || metadata == null) {
      Get.snackbar('error'.tr, 'Missing data to generate report', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _pdfService.generateAndShareReport(
        result: result!,
        metadata: metadata!,
        imagePath: imagePath,
      );

      Get.back(); // Close loading dialog
    } catch (e) {
      Get.back();
      debugPrint('❌ Error generating PDF: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to generate PDF report: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to Telemedicine Referral creation for this case
  void requestSpecialistReferral() {
    if (!_localStorage.isAuthenticated) {
      Get.snackbar(
        'Clinician Login Required',
        'Please sign in as a verified doctor to dispatch specialist referrals.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }

    Get.toNamed(
      AppRoutes.REFERRALS,
      arguments: {
        'action': 'create',
        'analysisId': result!.analysisId,
        'predictedClass': result!.predictedClass,
        'confidence': result!.confidence,
        'riskLevel': result!.riskLevel,
        'imageUrl': result!.imageUrl,
        'patientId': result!.patientId,
        'lesionTag': result!.lesionTag,
      },
    );
  }

  /// Submit Clinician Feedback (Doctor ground truth concordance)
  Future<void> submitConcordanceFeedback({
    required bool confirmed,
    String? diagnosis,
    bool? biopsyPerformed,
    String? biopsyResult,
  }) async {
    final aid = result!.analysisId;
    if (aid == null) {
      Get.snackbar('Guest Mode', 'Doctor feedback is available for authenticated analyses.');
      return;
    }

    isSubmittingFeedback.value = true;
    try {
      final success = await _diagnosisRepo.submitFeedback(
        analysisId: aid,
        doctorConfirmed: confirmed,
        doctorDiagnosis: diagnosis,
        biopsyPerformed: biopsyPerformed,
        biopsyResult: biopsyResult,
      );

      if (success) {
        feedbackSubmitted.value = true;
        Get.back(); // close bottom sheet
        Get.snackbar(
          'Feedback Recorded',
          'Clinical concordance feedback stored in registry.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to submit clinical feedback.');
      }
    } finally {
      isSubmittingFeedback.value = false;
    }
  }

  void startNewDiagnosis() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  void showDisclaimer() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: 12),
            Text('disclaimer_title'.tr),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            result!.riskExplanation.isNotEmpty ? result!.riskExplanation : 'disclaimer_text'.tr,
            style: Get.textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('disclaimer_understand'.tr),
          ),
        ],
      ),
    );
  }
}
