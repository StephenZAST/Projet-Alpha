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

    // Déplacer les méthodes de navigation ici
    void navigateToMainRoute(String route) {
      Navigator.pop(context);
      navigationProvider.navigateToMainRoute(context, route);
    }

    void navigateToSecondaryRoute(String route) {
      Navigator.pop(context);
      navigationProvider.navigateToSecondaryRoute(context, route);
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
            isSelected: navigationProvider.isCurrentRoute('/'),
            onTap: () => navigationProvider.navigateToMainRoute(context, '/'),
          ),
          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            text: 'Offres',
            isSelected: navigationProvider.isCurrentRoute('/offers'),
            onTap: () => navigationProvider.navigateToMainRoute(context, '/offers'),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            text: 'Services',
            isSelected: navigationProvider.isCurrentRoute('/services'),
            onTap: () => navigationProvider.navigateToMainRoute(context, '/services'),
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            isSelected: navigationProvider.isCurrentRoute('/chat'),
            onTap: () => navigationProvider.navigateToMainRoute(context, '/chat'),
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            isSelected: navigationProvider.isCurrentRoute('/profile'),
            onTap: () => navigationProvider.navigateToMainRoute(context, '/profile'),
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Commandes',
            isSelected: navigationProvider.isCurrentRoute('/orders'),
            onTap: () => navigationProvider.navigateToSecondaryRoute(context, '/orders'),
          ),
          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            text: 'Notifications',
            isSelected: navigationProvider.isCurrentRoute('/notifications'),
            onTap: () => navigateToSecondaryRoute('/notifications'),
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            text: 'Parrainage',
            isSelected: navigationProvider.isCurrentRoute('/referral'),
            onTap: () => navigateToSecondaryRoute('/referral'),
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Réglages',
            isSelected: navigationProvider.isCurrentRoute('/settings'),
            onTap: () => navigateToSecondaryRoute('/settings'), // Correction ici
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
