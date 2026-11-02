import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/patient_metadata.dart';
import '../../../data/models/prediction_response.dart';

class AnalysisController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  String? imagePath;
  PatientMetadata? metadata;
  String? patientId;
  String? lesionTag;
  bool useTta = false;

  final isAnalyzing = true.obs;
  final analysisProgress = 0.0.obs;
  final currentStep = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get data from arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      imagePath = args['imagePath'];
      metadata = args['metadata'];
      patientId = args['patientId'];
      lesionTag = args['lesionTag'];
      useTta = args['useTta'] as bool? ?? false;
    }

    if (imagePath == null || metadata == null) {
      debugPrint('❌ Missing image path or metadata');
      Get.back();
      return;
    }

    debugPrint('✅ Starting multimodal analysis...');
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      // Step 1: Preparing connection
      currentStep.value = 'Preparing connection...';
      analysisProgress.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Uploading image and metadata
      currentStep.value = 'Uploading image & metadata...';
      analysisProgress.value = 0.5;
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Multimodal inference
      currentStep.value = 'Analyzing with Multimodal EfficientNet-B3...';
      analysisProgress.value = 0.8;

      // REST API call to FastAPI backend
      final response = await _apiService.predict(
        imagePath!,
        metadata!,
        patientId: patientId,
        lesionTag: lesionTag,
        useTta: useTta,
      );

      analysisProgress.value = 1.0;
      currentStep.value = 'Analysis complete!';
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to results
      Get.offNamed(
        AppRoutes.RESULT,
        arguments: {
          'imagePath': imagePath,
          'metadata': metadata,
          'result': response,
        },
      );
    } catch (e) {
      debugPrint('❌ Analysis error: $e');
      isAnalyzing.value = false;

      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );

      // Go back after error
      await Future.delayed(const Duration(seconds: 3));
      Get.back();
    }
  }
}
