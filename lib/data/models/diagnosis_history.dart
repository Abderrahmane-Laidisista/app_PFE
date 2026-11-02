import 'package:flutter/foundation.dart';
import 'prediction_response.dart';

/// Single item in diagnosis history, synchronized between server and local cache.
class DiagnosisHistoryItem {
  final String id;
  final DateTime date;
  final String? imagePath;
  final String? imageUrl;
  final String? gradcamUrl;
  final String diagnosis;
  final double confidence;
  final String riskLevel;
  final String? patientId;
  final String? lesionTag;
  final bool? doctorConfirmed;
  final String? doctorDiagnosis;
  final Map<String, double> allProbabilities;
  final Map<String, dynamic>? metadata;

  DiagnosisHistoryItem({
    required this.id,
    required this.date,
    this.imagePath,
    this.imageUrl,
    this.gradcamUrl,
    required this.diagnosis,
    required this.confidence,
    required this.riskLevel,
    this.patientId,
    this.lesionTag,
    this.doctorConfirmed,
    this.doctorDiagnosis,
    required this.allProbabilities,
    this.metadata,
  });

  factory DiagnosisHistoryItem.fromJson(Map<String, dynamic> json) {
    Map<String, double> probs = {};
    if (json['allProbabilities'] is Map) {
      probs = Map<String, double>.from(
        (json['allProbabilities'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    } else if (json['all_probabilities'] is Map) {
      probs = Map<String, double>.from(
        (json['all_probabilities'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    }

    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return DiagnosisHistoryItem(
      id: json['id']?.toString() ?? json['analysis_id']?.toString() ?? UniqueKey().toString(),
      date: parsedDate,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      gradcamUrl: json['gradcam_url'] as String? ?? json['gradcamUrl'] as String?,
      diagnosis: json['predicted_class'] as String? ?? json['diagnosis'] as String? ?? 'UNKNOWN',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? json['riskLevel'] as String? ?? 'MODERATE',
      patientId: json['patient_id'] as String? ?? json['patientId'] as String?,
      lesionTag: json['lesion_tag'] as String? ?? json['lesionTag'] as String?,
      doctorConfirmed: json['doctor_confirmed'] as bool?,
      doctorDiagnosis: json['doctor_diagnosis'] as String?,
      allProbabilities: probs,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'image_url': imageUrl,
      'gradcam_url': gradcamUrl,
      'diagnosis': diagnosis,
      'predicted_class': diagnosis,
      'confidence': confidence,
      'risk_level': riskLevel,
      'patient_id': patientId,
      'lesion_tag': lesionTag,
      'doctor_confirmed': doctorConfirmed,
      'doctor_diagnosis': doctorDiagnosis,
      'allProbabilities': allProbabilities,
      'metadata': metadata,
    };
  }
}
