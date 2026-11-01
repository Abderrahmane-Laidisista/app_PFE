// ignore_for_file: constant_identifier_names

abstract class AppRoutes {
  // Authentication & Clinician Onboarding
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PENDING_VERIFICATION = '/pending-verification';
  static const FORCE_CHANGE_PASSWORD = '/force-change-password';

  // Main Layout & Diagnostic Flow
  static const MAIN_LAYOUT = '/main';
  static const HOME = '/home';
  static const CAMERA = '/camera';
  static const CONSENT = '/consent';
  static const CLINICAL_FORM = '/clinical-form';
  static const ANALYSIS = '/analysis';
  static const RESULT = '/result';

  // Telemedicine & Patient Longitudinal Tracking
  static const PATIENTS = '/patients';
  static const REFERRALS = '/referrals';
  static const DOCTOR_DIRECTORY = '/doctor-directory';
  static const QR_FOLLOWUP = '/qr-followup';
  static const PROFILE = '/profile';

  // History & Offline Consultation
  static const HISTORY = '/history';
  static const HISTORY_DETAIL = '/history-detail';

  // Preferences & Education
  static const SETTINGS = '/settings';
  static const ABOUT = '/about';
  static const EDUCATION = '/education';
}
