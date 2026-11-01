import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/providers/local_storage_provider.dart';

/// Navigation guard protecting clinician-only routes (Analysis, Patients, Referrals, Profile).
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      if (Get.isRegistered<LocalStorageProvider>()) {
        final storage = Get.find<LocalStorageProvider>();
        if (!storage.isAuthenticated) {
          return const RouteSettings(name: AppRoutes.LOGIN);
        }
      }
    } catch (_) {}
    return null;
  }
}
