/// Doctor Profile information for authenticated clinicians.
class DoctorProfile {
  final String? id;
  final String? userId;
  final String fullName;
  final String doctorType; // 'general_practitioner' or 'specialist_dermatologist'
  final String specialization;
  final String licenseNumber;
  final String institutionName;
  final String? phone;
  final String? wilaya;
  final String? avatarUrl;

  DoctorProfile({
    this.id,
    this.userId,
    required this.fullName,
    required this.doctorType,
    required this.specialization,
    required this.licenseNumber,
    required this.institutionName,
    this.phone,
    this.wilaya,
    this.avatarUrl,
  });

  bool get isSpecialist =>
      doctorType == 'specialist_dermatologist' ||
      doctorType == 'specialist' ||
      specialization.toLowerCase().contains('dermatolog');

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id']?.toString() ?? json['profile_id']?.toString(),
      userId: json['user_id']?.toString(),
      fullName: json['full_name'] as String? ?? '',
      doctorType: json['doctor_type'] as String? ?? 'general_practitioner',
      specialization: json['specialization'] as String? ?? 'General Practice',
      licenseNumber: json['license_number'] as String? ?? '',
      institutionName: json['institution_name'] as String? ?? '',
      phone: json['phone'] as String?,
      wilaya: json['wilaya']?.toString(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'full_name': fullName,
      'doctor_type': doctorType,
      'specialization': specialization,
      'license_number': licenseNumber,
      'institution_name': institutionName,
      if (phone != null) 'phone': phone,
      if (wilaya != null) 'wilaya': wilaya,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
