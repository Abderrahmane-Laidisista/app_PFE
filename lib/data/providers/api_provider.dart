import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../app/config/api/api_config.dart';
import '../../app/config/api/api_constants.dart';
import '../../app/routes/app_routes.dart';
import 'local_storage_provider.dart';

/// Centralized API Provider with automatic JWT authentication, silent 401 token refresh,
/// customizable timeouts, and structured error propagation.
class ApiProvider extends GetxService {
  final http.Client _client = http.Client();
  LocalStorageProvider get _storage => Get.find<LocalStorageProvider>();

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  String get baseUrl => ApiConfig.baseUrl;

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$cleanEndpoint';
    final uri = Uri.parse(fullUrl);

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final sanitizedParams = <String, dynamic>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        sanitizedParams[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: sanitizedParams);
  }

  Map<String, String> _buildHeaders({
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
    bool isJson = true,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (requiresAuth) {
      final token = _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // ── Silent Token Refresh ─────────────────────────────────────────
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      return await (_refreshCompleter?.future ?? Future.value(false));
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    final refreshToken = _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _isRefreshing = false;
      _refreshCompleter?.complete(false);
      await _storage.clearSession();
      return false;
    }

    try {
      final refreshUri = _buildUri(ApiConstants.refresh);
      final response = await _client
          .post(
            refreshUri,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess = data['access_token'] as String?;
        final newRefresh = (data['refresh_token'] as String?) ?? refreshToken;

        if (newAccess != null && newAccess.isNotEmpty) {
          await _storage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          debugPrint('🔄 Token refreshed successfully');
          _refreshCompleter?.complete(true);
          return true;
        }
      }

      debugPrint('❌ Silent token refresh failed [${response.statusCode}]: ${response.body}');
    } catch (e) {
      debugPrint('❌ Error during token refresh: $e');
    } finally {
      _isRefreshing = false;
    }

    _refreshCompleter?.complete(false);
    await _storage.clearSession();
    Get.offAllNamed(AppRoutes.HOME);
    return false;
  }

  // ── Standard HTTP Methods ────────────────────────────────────────

  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final requestHeaders = _buildHeaders(customHeaders: headers, requiresAuth: requiresAuth);

    try {
      var response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(timeout ?? ApiConstants.defaultTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retriedHeaders = _buildHeaders(customHeaders: headers, requiresAuth: true);
          response = await _client
              .get(uri, headers: retriedHeaders)
              .timeout(timeout ?? ApiConstants.defaultTimeout);
        }
      }

      return response;
    } on TimeoutException {
      throw TimeoutException('Request to $endpoint timed out after ${timeout ?? ApiConstants.defaultTimeout}');
    }
  }

  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final isJsonBody = body is Map || body is List;
    final requestHeaders = _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
      isJson: isJsonBody,
    );

    final encodedBody = isJsonBody ? jsonEncode(body) : body;

    try {
      var response = await _client
          .post(uri, headers: requestHeaders, body: encodedBody)
          .timeout(timeout ?? ApiConstants.defaultTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retriedHeaders = _buildHeaders(
            customHeaders: headers,
            requiresAuth: true,
            isJson: isJsonBody,
          );
          response = await _client
              .post(uri, headers: retriedHeaders, body: encodedBody)
              .timeout(timeout ?? ApiConstants.defaultTimeout);
        }
      }

      return response;
    } on TimeoutException {
      throw TimeoutException('Request to $endpoint timed out.');
    }
  }

  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final isJsonBody = body is Map || body is List;
    final requestHeaders = _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
      isJson: isJsonBody,
    );

    final encodedBody = isJsonBody ? jsonEncode(body) : body;

    try {
      var response = await _client
          .put(uri, headers: requestHeaders, body: encodedBody)
          .timeout(timeout ?? ApiConstants.defaultTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retriedHeaders = _buildHeaders(
            customHeaders: headers,
            requiresAuth: true,
            isJson: isJsonBody,
          );
          response = await _client
              .put(uri, headers: retriedHeaders, body: encodedBody)
              .timeout(timeout ?? ApiConstants.defaultTimeout);
        }
      }

      return response;
    } on TimeoutException {
      throw TimeoutException('Request to $endpoint timed out.');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final requestHeaders = _buildHeaders(customHeaders: headers, requiresAuth: requiresAuth);

    try {
      var response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(timeout ?? ApiConstants.defaultTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retriedHeaders = _buildHeaders(customHeaders: headers, requiresAuth: true);
          response = await _client
              .delete(uri, headers: retriedHeaders)
              .timeout(timeout ?? ApiConstants.defaultTimeout);
        }
      }

      return response;
    } on TimeoutException {
      throw TimeoutException('Request to $endpoint timed out.');
    }
  }

  // ── Multipart POST (Inference) ───────────────────────────────────

  Future<http.Response> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
    bool requiresAuth = false,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint);

    http.MultipartRequest buildRequest() {
      final req = http.MultipartRequest('POST', uri);
      final reqHeaders = _buildHeaders(
        customHeaders: headers,
        requiresAuth: requiresAuth,
        isJson: false,
      );
      req.headers.addAll(reqHeaders);
      req.fields.addAll(fields);
      for (final f in files) {
        req.files.add(f);
      }
      return req;
    }

    try {
      var streamed = await buildRequest()
          .send()
          .timeout(timeout ?? ApiConstants.inferenceTimeout);
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          streamed = await buildRequest()
              .send()
              .timeout(timeout ?? ApiConstants.inferenceTimeout);
          response = await http.Response.fromStream(streamed);
        }
      }

      return response;
    } on TimeoutException {
      throw TimeoutException('Multipart request to $endpoint timed out.');
    }
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
