import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../app/config/api/api_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/auth_response.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/local_storage_provider.dart';

/// Central Authentication Service managing clinician identity, login, registration,
/// token lifecycle, and session state.
class AuthService extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();
  final LocalStorageProvider _storage = Get.find<LocalStorageProvider>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  bool get isAuthenticated => isLoggedIn.value;
  bool get isDoctor => currentUser.value?.isDoctor ?? (_storage.userRole == 'doctor' || _storage.userRole == 'admin');
  bool get isPending => currentUser.value?.isPending ?? false;
  String? get doctorFullName => currentUser.value?.profile?.fullName ?? _storage.doctorFullName;

  Future<AuthService> init() async {
    isLoggedIn.value = _storage.isAuthenticated;
    // Restore cached user profile if present
    final cached = _storage.getUserProfile();
    if (cached != null) {
      try {
        currentUser.value = UserModel.fromJson(cached);
      } catch (e) {
        debugPrint('⚠️ Error parsing cached user profile: $e');
      }
    }
    return this;
  }

  /// Login clinician with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final response = await _api.post(
        ApiConstants.login,
        body: {
          'email': email.trim(),
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        await _storage.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        isLoggedIn.value = true;

        if (authResponse.user != null) {
          currentUser.value = authResponse.user;
          await _storage.saveUserProfile(authResponse.user!.toJson());
        }

        return authResponse;
      } else {
        String message = 'Login failed (${response.statusCode})';
        try {
          final err = jsonDecode(response.body);
          if (err['detail'] != null) message = err['detail'].toString();
        } catch (_) {}
        throw Exception(message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new clinician account
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String doctorType,
    required String specialization,
    required String licenseNumber,
    required String institutionName,
    required String phone,
    required String wilaya,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'doctor_type': doctorType,
        'specialization': specialization.trim(),
        'license_number': licenseNumber.trim(),
        'institution_name': institutionName.trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
      };

      final response = await _api.post(
        ApiConstants.register,
        body: body,
        requiresAuth: false,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String message = 'Registration failed (${response.statusCode})';
        try {
          final err = jsonDecode(response.body);
          if (err['detail'] != null) message = err['detail'].toString();
        } catch (_) {}
        throw Exception(message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch currently authenticated doctor profile from backend
  Future<UserModel?> fetchCurrentProfile() async {
    if (!_storage.isAuthenticated) {
      isLoggedIn.value = false;
      return null;
    }
    isLoggedIn.value = true;
    try {
      final response = await _api.get(
        ApiConstants.me,
        requiresAuth: true,
        timeout: const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        currentUser.value = user;
        await _storage.saveUserProfile(user.toJson());
        return user;
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching profile /me: $e');
    }
    return currentUser.value;
  }

  /// Logout clinician and clear session
  Future<void> logout() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _api.post(
          ApiConstants.logout,
          body: {'refresh_token': refreshToken},
          requiresAuth: true,
        );
      }
    } catch (_) {}
    await _storage.clearSession();
    isLoggedIn.value = false;
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.HOME);
  }
}
