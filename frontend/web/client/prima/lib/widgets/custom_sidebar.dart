import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:prima/navigation/navigation_provider.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    void handleNavigation(String route) {
      Navigator.pop(context); // Ferme le drawer
      if (NavigationProvider.mainRoutes.contains(route) || route == '/') {
        navigationProvider.navigateToMainRoute(context, route);
      } else {
        navigationProvider.navigateToSecondaryRoute(context, route);
      }
    }

    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/AlphaLogo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  'Mr ZAKANE',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.home,
            text: 'Home',
            isSelected: navigationProvider.currentRoute == '/home',
            onTap: () => handleNavigation('/home'),
          ),
          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            text: 'Offres',
            isSelected: navigationProvider.currentRoute == '/offers',
            onTap: () => handleNavigation('/offers'),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            text: 'Services',
            isSelected: navigationProvider.currentRoute == '/services',
            onTap: () => handleNavigation('/services'),
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            isSelected: navigationProvider.currentRoute == '/chat',
            onTap: () => handleNavigation('/chat'),
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            isSelected: navigationProvider.currentRoute == '/profile',
            onTap: () => handleNavigation('/profile'),
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Commandes',
            isSelected: navigationProvider.currentRoute == '/orders',
            onTap: () => handleNavigation('/orders'),
          ),
          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            text: 'Notifications',
            isSelected: navigationProvider.currentRoute == '/notifications',
            onTap: () => handleNavigation('/notifications'),
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            text: 'Parrainage',
            isSelected: navigationProvider.currentRoute == '/referral',
            onTap: () => handleNavigation('/referral'),
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Réglages',
            isSelected: navigationProvider.currentRoute == '/settings',
            onTap: () => handleNavigation('/settings'),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Déconnexion',
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle sign out
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.gray600,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
