/// Publicly accessible doctor profile from the national MedAssist directory.
class PublicDoctor {
  final String id;
  final String userId;
  final String? profileId;
  final String fullName;
  final String doctorType; // 'general_practitioner' or 'specialist_dermatologist'
  final String specialization;
  final String institutionName;
  final String? wilaya;
  final String? avatarUrl;

  PublicDoctor({
    required this.id,
    required this.userId,
    this.profileId,
    required this.fullName,
    required this.doctorType,
    required this.specialization,
    required this.institutionName,
    this.wilaya,
    this.avatarUrl,
  });

  bool get isSpecialist =>
      doctorType == 'specialist_dermatologist' ||
      doctorType == 'specialist' ||
      specialization.toLowerCase().contains('dermatolog');

  factory PublicDoctor.fromJson(Map<String, dynamic> json) {
    return PublicDoctor(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString(),
      fullName: json['full_name'] as String? ?? 'Dr. Clinician',
      doctorType: json['doctor_type'] as String? ?? 'general_practitioner',
      specialization: json['specialization'] as String? ?? 'General Practice',
      institutionName: json['institution_name'] as String? ?? '',
      wilaya: json['wilaya']?.toString(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (profileId != null) 'profile_id': profileId,
      'full_name': fullName,
      'doctor_type': doctorType,
      'specialization': specialization,
      'institution_name': institutionName,
      if (wilaya != null) 'wilaya': wilaya,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
