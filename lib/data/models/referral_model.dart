import '../../app/config/api/api_config.dart';

/// Telemedicine referral status enum.
enum ReferralStatus {
  pending,
  accepted,
  completed,
  cancelled,
}

/// Telemedicine referral representation connecting Frontline GP with Dermatologist.
class ReferralModel {
  final String id;
  final String analysisId;
  final String referringDoctorId;
  final String? specialistId;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final String referralNote;
  final String? specialistResponse;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? referringDoctorName;
  final String? specialistName;
  final String? analysisPredictedClass;
  final double? analysisConfidence;
  final String? analysisRiskLevel;
  final String? analysisImageUrl;

  ReferralModel({
    required this.id,
    required this.analysisId,
    required this.referringDoctorId,
    this.specialistId,
    required this.status,
    required this.referralNote,
    this.specialistResponse,
    required this.createdAt,
    this.respondedAt,
    this.referringDoctorName,
    this.specialistName,
    this.analysisPredictedClass,
    this.analysisConfidence,
    this.analysisRiskLevel,
    this.analysisImageUrl,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    String? predClass;
    double? conf;
    String? risk;
    String? imgUrl;

    if (json['analysis'] != null && json['analysis'] is Map) {
      final a = Map<String, dynamic>.from(json['analysis']);
      predClass = a['predicted_class'] as String?;
      conf = (a['confidence'] as num?)?.toDouble();
      risk = a['risk_level'] as String?;
      imgUrl = ApiConfig.resolveMediaUrl(a['image_url'] as String?);
    }

    return ReferralModel(
      id: json['id']?.toString() ?? '',
      analysisId: json['analysis_id']?.toString() ?? '',
      referringDoctorId: json['referring_doctor_id']?.toString() ?? '',
      specialistId: json['specialist_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      referralNote: json['referral_note'] as String? ?? '',
      specialistResponse: json['specialist_response'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      respondedAt: DateTime.tryParse(json['responded_at']?.toString() ?? ''),
      referringDoctorName: json['referring_doctor_name'] as String?,
      specialistName: json['specialist_name'] as String?,
      analysisPredictedClass: predClass,
      analysisConfidence: conf,
      analysisRiskLevel: risk,
      analysisImageUrl: imgUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analysis_id': analysisId,
      'referring_doctor_id': referringDoctorId,
      'specialist_id': specialistId,
      'status': status,
      'referral_note': referralNote,
      'specialist_response': specialistResponse,
      'created_at': createdAt.toIso8601String(),
      if (respondedAt != null) 'responded_at': respondedAt!.toIso8601String(),
      if (referringDoctorName != null) 'referring_doctor_name': referringDoctorName,
      if (specialistName != null) 'specialist_name': specialistName,
    };
  }
}

/// Request payload to initiate a referral
class ReferralCreateRequest {
  final String analysisId;
  final String? specialistId;
  final String referralNote;

  ReferralCreateRequest({
    required this.analysisId,
    this.specialistId,
    required this.referralNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      if (specialistId != null && specialistId!.isNotEmpty) 'specialist_id': specialistId,
      'referral_note': referralNote,
    };
  }
}

/// Specialist Response payload
class ReferralRespondRequest {
  final String status; // 'completed', 'accepted', 'cancelled'
  final String specialistResponse;

  ReferralRespondRequest({
    this.status = 'completed',
    required this.specialistResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'specialist_response': specialistResponse,
    };
  }
}
