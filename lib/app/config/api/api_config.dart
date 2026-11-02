import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import 'api_constants.dart';

/// Network environment presets for development, physical testing, and production.
enum ApiEnvironment {
  emulator,
  localhost,
  lan,
  cloudflare,
  custom,
}

/// Centralized API Configuration helper.
class ApiConfig {
  ApiConfig._();

  /// Retrieve the current configured API base URL from storage.
  static String get baseUrl {
    try {
      if (Get.isRegistered<StorageService>()) {
        final service = Get.find<StorageService>();
        final stored = service.apiUrl;
        if (stored.isNotEmpty) {
          return stored;
        }
      }
    } catch (_) {
      // Fallback if StorageService not yet ready
    }
    return ApiConstants.defaultBaseUrl;
  }

  /// Update the configured base URL in storage.
  static Future<void> setBaseUrl(String newUrl) async {
    final cleaned = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (Get.isRegistered<StorageService>()) {
      final service = Get.find<StorageService>();
      await service.setApiUrl(cleaned);
    }
  }

  /// Resolve full image or Grad-CAM URL, handling both absolute MinIO S3 URLs
  /// and relative `/uploads/...` or `/dashboard/...` paths.
  static String? resolveMediaUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;
    final trimmed = pathOrUrl.trim();

    // Already a complete HTTP/HTTPS URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Extract host origin from baseUrl (e.g., http://10.0.2.2:8000 from http://10.0.2.2:8000/api/v1)
    final currentBase = baseUrl;
    final uri = Uri.tryParse(currentBase);
    if (uri != null) {
      final origin = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      if (trimmed.startsWith('/')) {
        return '$origin$trimmed';
      } else {
        return '$origin/$trimmed';
      }
    }

    return trimmed;
  }
}
