import 'patient_metadata.dart';

/// Request object representing input data for the multimodal inference pipeline (/predict).
class PredictionRequest {
  final String imagePath;
  final double age;
  final String sex; // 'male', 'female', 'unknown'
  final String localization; // 'back', 'face', 'scalp', 'chest', 'hand', etc.
  final double? diameter1; // Largest diameter in mm (0 to 200)
  final bool grew;
  final bool bleed;
  final bool? elevation; // Palpable/elevated lesion
  final bool skinCancerHistory;
  final String? patientId; // Optional UUID or patient code DZ-XX-PXXXX
  final String? lesionTag; // Optional clinical anatomical tag
  final bool useTta; // Test-time augmentation (8x)

  PredictionRequest({
    required this.imagePath,
    required this.age,
    required this.sex,
    required this.localization,
    this.diameter1,
    this.grew = false,
    this.bleed = false,
    this.elevation,
    this.skinCancerHistory = false,
    this.patientId,
    this.lesionTag,
    this.useTta = false,
  });

  /// Factory from PatientMetadata and local image path
  factory PredictionRequest.fromMetadata({
    required String imagePath,
    required PatientMetadata metadata,
    String? patientId,
    String? lesionTag,
    bool useTta = false,
  }) {
    return PredictionRequest(
      imagePath: imagePath,
      age: metadata.age,
      sex: _normalizeSex(metadata.sex),
      localization: _normalizeLocalization(metadata.region),
      diameter1: metadata.diameter,
      grew: metadata.grew,
      bleed: metadata.bleed,
      elevation: metadata.elevation,
      skinCancerHistory: metadata.skinCancerHistory,
      patientId: patientId,
      lesionTag: lesionTag,
      useTta: useTta,
    );
  }

  /// Convert to multipart form fields map for FastAPI backend
  Map<String, String> toFormData() {
    final fields = <String, String>{
      'age': age.toString(),
      'sex': _normalizeSex(sex),
      'localization': _normalizeLocalization(localization),
      'grew': grew.toString(),
      'bleed': bleed.toString(),
      'skin_cancer_history': skinCancerHistory.toString(),
      'use_tta': useTta.toString(),
    };

    if (diameter1 != null) {
      fields['diameter_1'] = diameter1!.toString();
    }
    if (elevation != null) {
      fields['elevation'] = elevation!.toString();
    }
    if (patientId != null && patientId!.trim().isNotEmpty) {
      fields['patient_id'] = patientId!.trim();
    }
    if (lesionTag != null && lesionTag!.trim().isNotEmpty) {
      fields['lesion_tag'] = lesionTag!.trim();
    }

    return fields;
  }

  static String _normalizeSex(String value) {
    final lower = value.trim().toLowerCase();
    if (lower == 'm' || lower == 'male' || lower == 'homme' || lower == 'ذكر') {
      return 'male';
    }
    if (lower == 'f' || lower == 'female' || lower == 'femme' || lower == 'أنثى') {
      return 'female';
    }
    return 'unknown';
  }

  static String _normalizeLocalization(String loc) {
    switch (loc) {
      case 'location_head':
      case 'head':
      case 'face':
        return 'face';
      case 'scalp':
        return 'scalp';
      case 'location_neck':
      case 'neck':
        return 'neck';
      case 'location_chest':
      case 'chest':
        return 'chest';
      case 'location_back':
      case 'back':
        return 'back';
      case 'location_arm_left':
      case 'location_arm_right':
      case 'arm':
      case 'upper extremity':
        return 'upper extremity';
      case 'location_hand_left':
      case 'location_hand_right':
      case 'hand':
        return 'hand';
      case 'location_abdomen':
      case 'abdomen':
        return 'abdomen';
      case 'location_leg_left':
      case 'location_leg_right':
      case 'leg':
      case 'lower extremity':
        return 'lower extremity';
      case 'location_foot_left':
      case 'location_foot_right':
      case 'foot':
        return 'foot';
      default:
        return loc.isNotEmpty ? loc : 'unknown';
    }
  }
}
