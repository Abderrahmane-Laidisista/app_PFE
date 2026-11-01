import '../../app/config/api/api_config.dart';

/// Single chronological scan in a patient's lesion evolution timeline.
class PatientTimelineItem {
  final String analysisId;
  final DateTime createdAt;
  final String? lesionTag;
  final String predictedClass;
  final double confidence;
  final String riskLevel;
  final String? imageUrl;
  final double? diameter1;
  final bool? doctorConfirmed;
  final String? doctorDiagnosis;

  PatientTimelineItem({
    required this.analysisId,
    required this.createdAt,
    this.lesionTag,
    required this.predictedClass,
    required this.confidence,
    required this.riskLevel,
    this.imageUrl,
    this.diameter1,
    this.doctorConfirmed,
    this.doctorDiagnosis,
  });

  factory PatientTimelineItem.fromJson(Map<String, dynamic> json) {
    return PatientTimelineItem(
      analysisId: json['analysis_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      lesionTag: json['lesion_tag'] as String?,
      predictedClass: json['predicted_class'] as String? ?? 'UNKNOWN',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? 'MODERATE',
      imageUrl: ApiConfig.resolveMediaUrl(json['image_url'] as String?),
      diameter1: (json['diameter_1'] as num?)?.toDouble(),
      doctorConfirmed: json['doctor_confirmed'] as bool?,
      doctorDiagnosis: json['doctor_diagnosis'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'created_at': createdAt.toIso8601String(),
      'lesion_tag': lesionTag,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'risk_level': riskLevel,
      'image_url': imageUrl,
      'diameter_1': diameter1,
      'doctor_confirmed': doctorConfirmed,
      'doctor_diagnosis': doctorDiagnosis,
    };
  }
}

/// Pseudonymous patient record representation.
class PatientModel {
  final String id;
  final String patientCode;
  final int? birthYear;
  final String sex;
  final String? notes;
  final DateTime? createdAt;
  final int analysesCount;
  final List<PatientTimelineItem> timeline;

  PatientModel({
    required this.id,
    required this.patientCode,
    this.birthYear,
    required this.sex,
    this.notes,
    this.createdAt,
    this.analysesCount = 0,
    this.timeline = const [],
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'] as List? ?? [];
    final items = rawTimeline
        .map((e) => PatientTimelineItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PatientModel(
      id: json['id']?.toString() ?? '',
      patientCode: json['patient_code'] as String? ?? '',
      birthYear: json['birth_year'] as int?,
      sex: json['sex'] as String? ?? 'unknown',
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      analysesCount: (json['analyses_count'] as num?)?.toInt() ?? items.length,
      timeline: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_code': patientCode,
      'birth_year': birthYear,
      'sex': sex,
      'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'analyses_count': analysesCount,
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}

/// Request to create a new patient
class PatientCreateRequest {
  final String patientCode;
  final int? birthYear;
  final String sex;
  final String? notes;

  PatientCreateRequest({
    required this.patientCode,
    this.birthYear,
    required this.sex,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_code': patientCode,
      if (birthYear != null) 'birth_year': birthYear,
      'sex': sex,
      if (notes != null) 'notes': notes,
    };
  }
}
