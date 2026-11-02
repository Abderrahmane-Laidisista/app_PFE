import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Global API Constants and Route Specifications for MedAssist AI V2.
class ApiConstants {
  ApiConstants._();

  // ── Default Base URLs ──────────────────────────────────────────
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String localhostBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String defaultLanBaseUrl = 'http://192.168.1.15:8000/api/v1';
  static const String productionBaseUrl = 'https://api.medassist.dz/api/v1';

  /// Resolves the recommended default base URL based on platform.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return localhostBaseUrl;
    }
    try {
      if (Platform.isAndroid) {
        return emulatorBaseUrl;
      } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return localhostBaseUrl;
      }
    } catch (_) {
      // Fallback if Platform check fails
    }
    return localhostBaseUrl;
  }

  // ── Auth Endpoints ─────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // ── Inference / Diagnostic Endpoints ───────────────────────────
  static const String predict = '/predict';

  // ── Clinical Analyses Endpoints ────────────────────────────────
  static const String analyses = '/analyses';
  static String analysisDetail(String id) => '/analyses/$id';
  static String analysisFeedback(String id) => '/analyses/$id/feedback';
  static String analysisPdf(String id) => '/analyses/$id/export-pdf';

  // ── Patient Management & Lesion Timelines ──────────────────────
  static const String patients = '/patients';
  static String patientDetail(String id) => '/patients/$id';
  static String patientTimeline(String id) => '/patients/$id';

  // ── Telemedicine Referrals & Public Directory ──────────────────
  static const String referrals = '/referrals';
  static const String sentReferrals = '/referrals/sent';
  static const String receivedReferrals = '/referrals/received';
  static String referralDetail(String id) => '/referrals/$id';
  static String referralRespond(String id) => '/referrals/$id/respond';
  static const String publicDoctors = '/public/doctors';

  // ── Public Platform Resources & QR Verification ────────────────
  static const String platformResources = '/public/platform-resources';
  static String qrFollowUp(String token) => '/public/follow-up/$token';

  // ── System Health ──────────────────────────────────────────────
  static const String health = '/health';
  static const String modelInfo = '/model/info';

  // ── Timeouts ───────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration inferenceTimeout = Duration(seconds: 90);
  static const Duration defaultTimeout = Duration(seconds: 30);
}
