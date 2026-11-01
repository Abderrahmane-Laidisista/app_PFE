import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../home/views/home_view.dart';
import '../../patients/views/patients_view.dart';
import '../../profile/views/profile_view.dart';
import '../../referrals/views/referrals_view.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const PatientsView(),
      const ReferralsView(),
      const ProfileView(),
    ];

    return Obx(() {
      final idx = controller.currentIndex.value;

      return Scaffold(
        body: IndexedStack(
          index: idx,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: controller.changeTab,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_shared_outlined),
              selectedIcon: Icon(Icons.folder_shared, color: AppColors.primary),
              label: 'Patients',
            ),
            NavigationDestination(
              icon: Icon(Icons.connect_without_contact_outlined),
              selectedIcon: Icon(Icons.connect_without_contact, color: AppColors.primary),
              label: 'Referrals',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
