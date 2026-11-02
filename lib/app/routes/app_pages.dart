import 'package:get/get.dart';
import '../../core/middleware/auth_middleware.dart';
import 'app_routes.dart';

// ── Bindings ──────────────────────────────────────────────────
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/bindings/register_binding.dart';
import '../../modules/main_layout/bindings/main_layout_binding.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/camera/bindings/camera_binding.dart';
import '../../modules/consent/bindings/consent_binding.dart';
import '../../modules/clinical_form/bindings/clinical_form_binding.dart';
import '../../modules/analysis/bindings/analysis_binding.dart';
import '../../modules/result/bindings/result_binding.dart';
import '../../modules/history/bindings/history_binding.dart';
import '../../modules/patients/bindings/patients_binding.dart';
import '../../modules/referrals/bindings/referrals_binding.dart';
import '../../modules/doctor_directory/bindings/doctor_directory_binding.dart';
import '../../modules/qr_followup/bindings/qr_followup_binding.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/education/bindings/education_binding.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/about/bindings/about_binding.dart';

// ── Views ─────────────────────────────────────────────────────
import '../../modules/splash/views/splash_view.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/views/pending_view.dart';
import '../../modules/auth/views/force_change_password_view.dart';
import '../../modules/main_layout/views/main_layout_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/camera/views/camera_view.dart';
import '../../modules/consent/views/consent_view.dart';
import '../../modules/clinical_form/views/clinical_form_view.dart';
import '../../modules/analysis/views/analysis_view.dart';
import '../../modules/result/views/result_view.dart';
import '../../modules/history/views/history_view.dart';
import '../../modules/patients/views/patients_view.dart';
import '../../modules/referrals/views/referrals_view.dart';
import '../../modules/doctor_directory/views/doctor_directory_view.dart';
import '../../modules/qr_followup/views/qr_followup_view.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/education/views/education_view.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/about/views/about_view.dart';

class AppPages {
  static final pages = [
    // Splash Screen
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),

    // Onboarding
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    // Clinician Authentication
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PENDING_VERIFICATION,
      page: () => const PendingView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.FORCE_CHANGE_PASSWORD,
      page: () => const ForceChangePasswordView(),
      transition: Transition.fadeIn,
    ),

    // Main Clinician Shell (Unified Bottom Navigation)
    GetPage(
      name: AppRoutes.MAIN_LAYOUT,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // Home
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Camera Capture
    GetPage(
      name: AppRoutes.CAMERA,
      page: () => const CameraView(),
      binding: CameraBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Informed Consent
    GetPage(
      name: AppRoutes.CONSENT,
      page: () => const ConsentView(),
      binding: ConsentBinding(),
      transition: Transition.rightToLeft,
    ),

    // Clinical 7-Feature Form
    GetPage(
      name: AppRoutes.CLINICAL_FORM,
      page: () => const ClinicalFormView(),
      binding: ClinicalFormBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Deep Learning Analysis Screen
    GetPage(
      name: AppRoutes.ANALYSIS,
      page: () => const AnalysisView(),
      binding: AnalysisBinding(),
      transition: Transition.fadeIn,
    ),

    // Multimodal Results & Grad-CAM++
    GetPage(
      name: AppRoutes.RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Telemedicine & Patient Longitudinal Modules
    GetPage(
      name: AppRoutes.PATIENTS,
      page: () => const PatientsView(),
      binding: PatientsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.REFERRALS,
      page: () => const ReferralsView(),
      binding: ReferralsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.DOCTOR_DIRECTORY,
      page: () => const DoctorDirectoryView(),
      binding: DoctorDirectoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.QR_FOLLOWUP,
      page: () => const QRFollowUpView(),
      binding: QRFollowUpBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // History
    GetPage(
      name: AppRoutes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Education
    GetPage(
      name: AppRoutes.EDUCATION,
      page: () => const EducationView(),
      binding: EducationBinding(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),

    // About (PFE Thesis)
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
