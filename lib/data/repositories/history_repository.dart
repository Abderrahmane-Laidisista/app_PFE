import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../app/config/api/api_constants.dart';
import '../../core/services/connectivity_service.dart';
import '../models/diagnosis_history.dart';
import '../providers/api_provider.dart';
import '../providers/local_storage_provider.dart';

/// Repository managing historical scan records with seamless remote sync & offline cache.
class HistoryRepository extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();
  final LocalStorageProvider _storage = Get.find<LocalStorageProvider>();

  bool get _isOnline {
    if (Get.isRegistered<ConnectivityService>()) {
      return Get.find<ConnectivityService>().isOnline.value;
    }
    return true;
  }

  /// Fetch analyses from backend if online & authenticated; otherwise fallback to local cache
  Future<List<DiagnosisHistoryItem>> getAnalyses({
    int page = 1,
    int pageSize = 20,
    String? patientId,
    String? riskLevel,
    String? predictedClass,
  }) async {
    final isAuthenticated = _storage.isAuthenticated;

    if (_isOnline && isAuthenticated) {
      try {
        final query = <String, dynamic>{
          'page': page,
          'page_size': pageSize,
          if (patientId != null) 'patient_id': patientId,
          if (riskLevel != null) 'risk_level': riskLevel,
          if (predictedClass != null) 'predicted_class': predictedClass,
        };

        final response = await _api.get(
          ApiConstants.analyses,
          queryParameters: query,
          requiresAuth: true,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final itemsList = body['items'] as List? ?? [];
          final remoteItems = itemsList
              .map((e) => DiagnosisHistoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();

          // Sync into local cache for offline availability
          if (page == 1) {
            await _syncRemoteToLocal(remoteItems);
          }

          return remoteItems;
        }
      } catch (e) {
        debugPrint('⚠️ Remote history fetch failed, falling back to local: $e');
      }
    }

    // Offline / Guest Fallback
    final cached = _storage.getOfflineAnalyses();
    return cached
        .map((e) => DiagnosisHistoryItem.fromJson(e))
        .where((item) {
          if (riskLevel != null && item.riskLevel.toUpperCase() != riskLevel.toUpperCase()) {
            return false;
          }
          if (predictedClass != null && item.diagnosis.toUpperCase() != predictedClass.toUpperCase()) {
            return false;
          }
          return true;
        })
        .toList();
  }

  /// Remove single record from local cache and remote server if available
  Future<void> deleteAnalysis(String id, int localIndex) async {
    try {
      await _storage.removeOfflineAnalysis(localIndex);

      if (_isOnline && _storage.isAuthenticated) {
        await _api.delete(
          ApiConstants.analysisDetail(id),
          requiresAuth: true,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error deleting analysis: $e');
    }
  }

  Future<void> clearAll() async {
    await _storage.clearOfflineAnalyses();
  }

  Future<void> _syncRemoteToLocal(List<DiagnosisHistoryItem> remoteItems) async {
    try {
      final localData = remoteItems.map((e) => e.toJson()).toList();
      await _storage.saveOfflineAnalyses(localData);
    } catch (e) {
      debugPrint('⚠️ Failed to sync remote history to local cache: $e');
    }
  }
}
