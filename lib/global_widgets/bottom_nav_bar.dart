import 'package:flutter/material.dart';
import '../app/config/theme/app_colores.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
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
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history, color: AppColors.primary),
          label: 'History',
        ),
      ],
    );
  }
}
