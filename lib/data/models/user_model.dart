import 'doctor_profile.dart';

/// Clinician / User model representation in MedAssist AI V2.
class UserModel {
  final String id;
  final String email;
  final String role; // 'admin', 'doctor', 'guest'
  final String status; // 'active', 'pending_verification', 'suspended'
  final bool mustChangePassword;
  final DateTime? createdAt;
  final DoctorProfile? profile;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.mustChangePassword = false,
    this.createdAt,
    this.profile,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending_verification';
  bool get isDoctor => role == 'doctor' || role == 'admin';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DoctorProfile? parsedProfile;
    if (json['profile'] != null && json['profile'] is Map) {
      parsedProfile = DoctorProfile.fromJson(Map<String, dynamic>.from(json['profile']));
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'guest',
      status: json['status'] as String? ?? 'active',
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      createdAt: created,
      profile: parsedProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      'must_change_password': mustChangePassword,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (profile != null) 'profile': profile!.toJson(),
    };
  }
}
