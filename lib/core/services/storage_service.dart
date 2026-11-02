import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _box;
  
  // Storage Keys
  static const String KEY_FIRST_TIME = 'first_time';
  static const String KEY_LANGUAGE = 'language';
  static const String KEY_THEME_MODE = 'theme_mode';
  static const String KEY_HISTORY = 'diagnosis_history';
  static const String KEY_USER_PREFERENCES = 'user_preferences';
  static const String KEY_API_URL = 'api_url';
  
  Future<StorageService> init() async {
    await GetStorage.init();
     _box = GetStorage();
 
    await _box.initStorage;
    debugPrint('✅ StorageService initialized');
    
    // Log initial state
    debugPrint('📊 Storage: isFirstTime = ${isFirstTime}');
    
    return this;
  }
  
  // First Time Check - with fallback
  bool get isFirstTime {
    try {
      final value = _box.read(KEY_FIRST_TIME);
      debugPrint('🔍 Storage: Reading first_time = $value');
      return value ?? true; // Default to true if null
    } catch (e) {
      debugPrint('⚠️ Storage: Error reading first_time: $e');
      return true; // Default to true on error
    }
  }
  
  Future<void> setFirstTime(bool value) async {
    try {
      await _box.write(KEY_FIRST_TIME, value);
      debugPrint('✅ Storage: first_time set to $value');
    } catch (e) {
      debugPrint('❌ Storage: Error setting first_time: $e');
    }
  }
  
  // Language
  String get language => _box.read(KEY_LANGUAGE) ?? 'ar';
  
  Future<void> setLanguage(String language) async {
    await _box.write(KEY_LANGUAGE, language);
  }
  
  // Theme Mode
  String get themeMode => _box.read(KEY_THEME_MODE) ?? 'light';
  
  Future<void> setThemeMode(String mode) async {
    await _box.write(KEY_THEME_MODE, mode);
  }
  
  // API URL
  String get apiUrl => _box.read(KEY_API_URL) ?? 'http://10.0.2.2:8000/api/v1';
  
  Future<void> setApiUrl(String url) async {
    await _box.write(KEY_API_URL, url);
  }
  
  // Diagnosis History
  List<Map<String, dynamic>> get diagnosisHistory {
    try {
      final List? data = _box.read(KEY_HISTORY);
      if (data == null) return [];
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
    } catch (e) {
      debugPrint('⚠️ Storage: Error reading history: $e');
      return [];
    }
  }
  
  Future<void> addDiagnosisToHistory(Map<String, dynamic> diagnosis) async {
    try {
      final history = diagnosisHistory;
      history.insert(0, diagnosis); // Add to beginning
      await _box.write(KEY_HISTORY, history);
    } catch (e) {
      debugPrint('❌ Storage: Error adding to history: $e');
    }
  }
  
  Future<void> removeDiagnosisFromHistory(int index) async {
    try {
      final history = diagnosisHistory;
      if (index >= 0 && index < history.length) {
        history.removeAt(index);
        await _box.write(KEY_HISTORY, history);
      }
    } catch (e) {
      debugPrint('❌ Storage: Error removing from history: $e');
    }
  }
  
  Future<void> clearHistory() async {
    try {
      await _box.write(KEY_HISTORY, []);
    } catch (e) {
      debugPrint('❌ Storage: Error clearing history: $e');
    }
  }
  
  // User Preferences
  Map<String, dynamic> get userPreferences {
    try {
      final data = _box.read(KEY_USER_PREFERENCES);
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('⚠️ Storage: Error reading preferences: $e');
      return {};
    }
  }
  
  Future<void> setUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _box.write(KEY_USER_PREFERENCES, preferences);
    } catch (e) {
      debugPrint('❌ Storage: Error setting preferences: $e');
    }
  }
  
  // Clear All Data
  Future<void> clearAll() async {
    try {
      await _box.erase();
      debugPrint('✅ Storage: All data cleared');
    } catch (e) {
      debugPrint('❌ Storage: Error clearing data: $e');
    }
  }
  
  // Generic Write
  Future<void> write(String key, dynamic value) async {
    try {
      await _box.write(key, value);
    } catch (e) {
      debugPrint('❌ Storage: Error writing $key: $e');
    }
  }
  
  // Generic Read
  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      debugPrint('⚠️ Storage: Error reading $key: $e');
      return null;
    }
  }
  
  // Remove
  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
    } catch (e) {
      debugPrint('❌ Storage: Error removing $key: $e');
    }
  }
  
  // Has Key
  bool hasKey(String key) {
    try {
      return _box.hasData(key);
    } catch (e) {
      debugPrint('⚠️ Storage: Error checking key $key: $e');
      return false;
    }
  }
}