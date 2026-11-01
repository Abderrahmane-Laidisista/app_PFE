import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/config/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/translations/app_translations.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/pdf_service.dart';
import 'core/services/storage_service.dart';
import 'data/providers/api_provider.dart';
import 'data/providers/local_storage_provider.dart';
import 'data/repositories/diagnosis_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/patient_repository.dart';
import 'data/repositories/referral_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services
  await initServices();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

Future<void> initServices() async {
  debugPrint('🔧 Starting MedAssist AI services initialization...');

  // 1. Local Storage Providers
  await Get.putAsync(() => LocalStorageProvider().init());
  await Get.putAsync(() => StorageService().init());
  debugPrint('✅ Storage Providers initialized');

  // 2. Connectivity Service
  Get.put(ConnectivityService());
  debugPrint('✅ Connectivity Service initialized');

  // 3. Centralized HTTP API Provider
  Get.put(ApiProvider());
  debugPrint('✅ ApiProvider initialized');

  // 4. Clinical Repositories
  Get.put(DiagnosisRepository());
  Get.put(HistoryRepository());
  Get.put(PatientRepository());
  Get.put(ReferralRepository());
  debugPrint('✅ Data Repositories initialized');

  // 5. Auth Service
  await Get.putAsync(() => AuthService().init());
  debugPrint('✅ AuthService initialized');

  // 6. Legacy Adapter Services
  Get.put(ApiService());
  Get.put(PdfService());
  debugPrint('✅ Adapter Services initialized');

  debugPrint('🎉 All MedAssist AI services initialized successfully');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LocalStorageProvider>();
    final initialLocale = Locale(storage.language);
    final initialThemeMode = storage.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;

    return GetMaterialApp(
      title: 'MedAssist AI',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,

      // Translations & RTL Support
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),

      // Routes
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,

      // Default Transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // TextScaler adaptation (Replaces deprecated textScaleFactor)
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
