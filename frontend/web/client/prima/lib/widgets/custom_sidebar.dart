import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:prima/navigation/navigation_provider.dart';

class CustomSidebar extends StatelessWidget {
  final String userName;
  const CustomSidebar({super.key, this.userName = 'ZAKANE'});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    void navigateToMainPage(int index) {
      navigationProvider.setIndex(index);
      Navigator.pop(context);
    }

    void navigateToSecondaryPage(String route, int index) {
      Navigator.pop(context);
      navigationProvider.setSecondaryPageIndex(index);
      Navigator.pushNamed(context, route);
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
                  'Mr $userName',
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
            isSelected: !navigationProvider.isSecondaryPage && navigationProvider.currentIndex == 0,
            onTap: () => navigateToMainPage(0),
          ),
          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            text: 'Offres',
            isSelected: !navigationProvider.isSecondaryPage && navigationProvider.currentIndex == 1,
            onTap: () => navigateToMainPage(1),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            text: 'Services',
            isSelected: !navigationProvider.isSecondaryPage && navigationProvider.currentIndex == 2,
            onTap: () => navigateToMainPage(2),
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            isSelected: !navigationProvider.isSecondaryPage && navigationProvider.currentIndex == 3,
            onTap: () => navigateToMainPage(3),
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            isSelected: !navigationProvider.isSecondaryPage && navigationProvider.currentIndex == 4,
            onTap: () => navigateToMainPage(4),
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Commandes',
            isSelected: navigationProvider.isSecondaryPage && navigationProvider.currentIndex == NavigationProvider.orderIndex,
            onTap: () => navigateToSecondaryPage('/orders', NavigationProvider.orderIndex),
          ),
          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            text: 'Notifications',
            isSelected: navigationProvider.isSecondaryPage && navigationProvider.currentIndex == NavigationProvider.notificationsIndex,
            onTap: () => navigateToSecondaryPage('/notifications', NavigationProvider.notificationsIndex),
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            text: 'Parrainage',
            isSelected: navigationProvider.isSecondaryPage && navigationProvider.currentIndex == NavigationProvider.referralIndex,
            onTap: () => navigateToSecondaryPage('/referral', NavigationProvider.referralIndex),
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Réglages',
            isSelected: navigationProvider.isSecondaryPage && navigationProvider.currentIndex == NavigationProvider.settingsIndex,
            onTap: () => navigateToSecondaryPage('/settings', NavigationProvider.settingsIndex),
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
