class PatientQRFollowUpModel {
  final String analysisId;
  final String predictedClass;
  final double confidence;
  final String riskLevel;
  final List<String> recommendations;
  final DateTime createdAt;
  final DateTime? nextFollowupDate;
  final bool? doctorConfirmed;
  final String? doctorDiagnosis;
  final String? doctorInstitution;

  PatientQRFollowUpModel({
    required this.analysisId,
    required this.predictedClass,
    required this.confidence,
    required this.riskLevel,
    required this.recommendations,
    required this.createdAt,
    this.nextFollowupDate,
    this.doctorConfirmed,
    this.doctorDiagnosis,
    this.doctorInstitution,
  });

  factory PatientQRFollowUpModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    List<String> parseRecommendations(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return PatientQRFollowUpModel(
      analysisId: json['analysis_id']?.toString() ?? '',
      predictedClass: json['predicted_class']?.toString() ?? 'UNKNOWN',
      confidence: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.0,
      riskLevel: json['risk_level']?.toString() ?? 'LOW',
      recommendations: parseRecommendations(json['recommendations']),
      createdAt: parseDate(json['created_at']),
      nextFollowupDate: parseNullableDate(json['next_followup_date']),
      doctorConfirmed: json['doctor_confirmed'] as bool?,
      doctorDiagnosis: json['doctor_diagnosis']?.toString(),
      doctorInstitution: json['doctor_institution']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'risk_level': riskLevel,
      'recommendations': recommendations,
      'created_at': createdAt.toIso8601String(),
      'next_followup_date': nextFollowupDate?.toIso8601String(),
      'doctor_confirmed': doctorConfirmed,
      'doctor_diagnosis': doctorDiagnosis,
      'doctor_institution': doctorInstitution,
    };
  }
}
