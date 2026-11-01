import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/patient_metadata.dart';

class ClinicalFormController extends GetxController {
  // Get image path from previous screen
  String? imagePath;
  final RxString currentImagePath = ''.obs;

  // Form fields
  final age = 30.0.obs;
  final sex = 'M'.obs;
  final region = ''.obs;
  final grew = false.obs;
  final bleed = false.obs;
  final diameter = 5.0.obs;
  final skinCancerHistory = false.obs;
  final elevation = false.obs; // Palpable/raised lesion (New in V2 / V6.0)
  final patientId = ''.obs;
  final lesionTag = ''.obs;
  final useTta = false.obs;

  // Form validation
  final formKey = GlobalKey<FormState>();
  final isFormValid = false.obs;

  // Regions list
  final List<String> regions = [
    'location_head',
    'location_neck',
    'location_chest',
    'location_back',
    'location_arm_left',
    'location_arm_right',
    'location_hand_left',
    'location_hand_right',
    'location_abdomen',
    'location_leg_left',
    'location_leg_right',
    'location_foot_left',
    'location_foot_right',
  ];

  @override
  void onInit() {
    super.onInit();

    // Get image path from arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      imagePath = args['imagePath'];
      if (imagePath != null) {
        currentImagePath.value = imagePath!;
      }
      if (args['patientId'] != null) {
        patientId.value = args['patientId'].toString();
      }
    }

    if (imagePath == null) {
      debugPrint('❌ No image path provided');
      Get.back();
      return;
    }

    debugPrint('✅ Image path received: $imagePath');

    // Listen to form changes
    ever(age, (_) => validateForm());
    ever(sex, (_) => validateForm());
    ever(region, (_) => validateForm());
    ever(diameter, (_) => validateForm());
    ever(elevation, (_) => validateForm());
  }

  void validateForm() {
    isFormValid.value = region.value.isNotEmpty && age.value > 0 && diameter.value > 0;
  }

  void setSex(String value) {
    sex.value = value;
  }

  void setRegion(String value) {
    region.value = value;
  }

  void setGrew(bool? value) {
    grew.value = value ?? false;
  }

  void setBleed(bool? value) {
    bleed.value = value ?? false;
  }

  void setSkinCancerHistory(bool? value) {
    skinCancerHistory.value = value ?? false;
  }

  void setElevation(bool? value) {
    elevation.value = value ?? false;
  }

  /// Load authentic benchmark lesion sample from PAD-UFES-20 assets
  Future<void> loadBenchmarkSample(String classKey) async {
    try {
      final manifestRaw = await rootBundle.loadString('assets/samples/pad_ufes_20/samples_manifest.json');
      final Map<String, dynamic> manifest = jsonDecode(manifestRaw);

      if (!manifest.containsKey(classKey)) {
        Get.snackbar('Sample Error', 'Benchmark sample $classKey not found');
        return;
      }

      final sample = manifest[classKey] as Map<String, dynamic>;
      final filename = sample['filename'] as String;

      // Copy asset to temp directory so Image.file and XFile can access it
      final byteData = await rootBundle.load('assets/samples/pad_ufes_20/$filename');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$filename');
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // Populate form
      imagePath = tempFile.path;
      currentImagePath.value = tempFile.path;
      age.value = (sample['age'] as num).toDouble();
      sex.value = (sample['sex'] == 'male') ? 'M' : 'F';
      diameter.value = (sample['diameter_1'] as num).toDouble();
      grew.value = sample['grew'] as bool? ?? false;
      bleed.value = sample['bleed'] as bool? ?? false;
      elevation.value = sample['elevation'] as bool? ?? false;
      patientId.value = sample['patient_id'] as String? ?? '';
      lesionTag.value = sample['lesion_tag'] as String? ?? '';

      // Map localization to region dropdown
      final loc = sample['localization'] as String? ?? '';
      if (loc == 'back') {
        region.value = 'location_back';
      } else if (loc == 'face' || loc == 'head') {
        region.value = 'location_head';
      } else if (loc == 'scalp' || loc == 'neck') {
        region.value = 'location_neck';
      } else if (loc == 'hand') {
        region.value = 'location_hand_left';
      } else {
        region.value = 'location_back';
      }

      validateForm();

      Get.snackbar(
        'Benchmark Sample Loaded',
        'Loaded PAD-UFES-20 authentic case: $classKey (${sample['full_name']})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Error loading benchmark sample: $e');
      Get.snackbar('Error', 'Failed to load benchmark sample: $e');
    }
  }

  Future<void> submitForm() async {
    if (!isFormValid.value) {
      Get.snackbar(
        'error'.tr,
        'form_incomplete'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      // Create patient metadata with elevation
      final metadata = PatientMetadata(
        age: age.value,
        sex: sex.value,
        region: region.value,
        grew: grew.value,
        bleed: bleed.value,
        diameter: diameter.value,
        skinCancerHistory: skinCancerHistory.value,
        elevation: elevation.value,
      );

      debugPrint('✅ Form submitted with metadata: $metadata');

      // Navigate to Analysis screen
      Get.toNamed(
        AppRoutes.ANALYSIS,
        arguments: {
          'imagePath': currentImagePath.value.isNotEmpty ? currentImagePath.value : imagePath,
          'metadata': metadata,
          'patientId': patientId.value.isNotEmpty ? patientId.value : null,
          'lesionTag': lesionTag.value.isNotEmpty ? lesionTag.value : null,
          'useTta': useTta.value,
        },
      );
    } catch (e) {
      debugPrint('❌ Error submitting form: $e');
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
