import 'user_model.dart';

/// Authentication response containing JWT tokens and clinician data.
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map) {
      parsedUser = UserModel.fromJson(Map<String, dynamic>.from(json['user']));
    }

    return AuthResponse(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
