import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/config/api/api_constants.dart';

/// Centralized local storage provider managing offline cache, JWT tokens,
/// clinician session profile, and application preferences using GetStorage.
class LocalStorageProvider extends GetxService {
  late final GetStorage _box;

  // ── Storage Keys ───────────────────────────────────────────────
  static const String keyAccessToken = 'jwt_access_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyUserProfile = 'user_profile';
  static const String keyOfflineAnalyses = 'offline_analyses';
  static const String keyApiUrl = 'api_url';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstTime = 'first_time';

  Future<LocalStorageProvider> init() async {
    await GetStorage.init();
    _box = GetStorage();
    await _box.initStorage;
    debugPrint('✅ LocalStorageProvider initialized');
    return this;
  }

  // ── JWT Token Management ───────────────────────────────────────
  String? getAccessToken() {
    return _box.read<String>(keyAccessToken);
  }

  String? getRefreshToken() {
    return _box.read<String>(keyRefreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.write(keyAccessToken, accessToken);
    await _box.write(keyRefreshToken, refreshToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _box.write(keyAccessToken, accessToken);
  }

  Future<void> clearTokens() async {
    await _box.remove(keyAccessToken);
    await _box.remove(keyRefreshToken);
  }

  bool get isAuthenticated {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Clinician Profile & Session ────────────────────────────────
  Map<String, dynamic>? getUserProfile() {
    final raw = _box.read(keyUserProfile);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    await _box.write(keyUserProfile, userJson);
  }

  Future<void> clearUserProfile() async {
    await _box.remove(keyUserProfile);
  }

  String? get userRole {
    final profile = getUserProfile();
    return profile?['role'] as String?;
  }

  String? get doctorType {
    final profile = getUserProfile();
    final nested = profile?['profile'] as Map<String, dynamic>?;
    return nested?['doctor_type'] as String?;
  }

  String? get doctorFullName {
    final profile = getUserProfile();
    final nested = profile?['profile'] as Map<String, dynamic>?;
    return nested?['full_name'] as String? ?? profile?['email'] as String?;
  }

  Future<void> clearSession() async {
    await clearTokens();
    await clearUserProfile();
  }

  // ── Offline Analyses & History Cache ───────────────────────────
  List<Map<String, dynamic>> getOfflineAnalyses() {
    try {
      final List? data = _box.read(keyOfflineAnalyses);
      if (data == null) return [];
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } catch (e) {
      debugPrint('⚠️ Error reading offline analyses: $e');
      return [];
    }
  }

  Future<void> saveOfflineAnalyses(List<Map<String, dynamic>> analyses) async {
    await _box.write(keyOfflineAnalyses, analyses);
  }

  Future<void> addOfflineAnalysis(Map<String, dynamic> item) async {
    try {
      final list = getOfflineAnalyses();
      list.insert(0, item);
      await _box.write(keyOfflineAnalyses, list);
    } catch (e) {
      debugPrint('❌ Error appending to offline analyses: $e');
    }
  }

  Future<void> removeOfflineAnalysis(int index) async {
    try {
      final list = getOfflineAnalyses();
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        await _box.write(keyOfflineAnalyses, list);
      }
    } catch (e) {
      debugPrint('❌ Error removing offline analysis: $e');
    }
  }

  Future<void> clearOfflineAnalyses() async {
    await _box.write(keyOfflineAnalyses, []);
  }

  // ── Preferences & API Base URL ─────────────────────────────────
  String get apiUrl =>
      _box.read(keyApiUrl) ?? ApiConstants.defaultBaseUrl;

  Future<void> setApiUrl(String url) async {
    await _box.write(keyApiUrl, url);
  }

  String get language => _box.read(keyLanguage) ?? 'en';

  Future<void> setLanguage(String lang) async {
    await _box.write(keyLanguage, lang);
  }

  String get themeMode => _box.read(keyThemeMode) ?? 'light';

  Future<void> setThemeMode(String mode) async {
    await _box.write(keyThemeMode, mode);
  }

  bool get isFirstTime => _box.read(keyFirstTime) ?? true;

  Future<void> setFirstTime(bool value) async {
    await _box.write(keyFirstTime, value);
  }
}
