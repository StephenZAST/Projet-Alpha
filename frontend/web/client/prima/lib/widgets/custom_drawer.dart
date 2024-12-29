import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/navigation/navigation_provider.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  const CustomDrawer({super.key, this.userName = 'ZAKANE'});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

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
            context: context,
            icon: Icons.home,
            text: 'Home',
            index: 0,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.local_offer_outlined,
            text: 'Offres',
            index: 1,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.shopping_bag_outlined,
            text: 'Services',
            index: 2,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.receipt_long_outlined,
            text: 'Commandes',
            index: 5,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.notifications_outlined,
            text: 'Notifications',
            index: 8,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.message_outlined,
            text: 'Messages',
            index: 3,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.people_outline,
            text: 'Parrainage',
            index: 6,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            text: 'Profile',
            index: 4,
            navigationProvider: navigationProvider,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_outlined,
            text: 'Réglages',
            index: 7,
            navigationProvider: navigationProvider,
          ),
          const Divider(height: 1, color: AppColors.gray200),
          _buildDrawerItem(
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required String text,
    int? index,
    NavigationProvider? navigationProvider,
    VoidCallback? onTap,
  }) {
    final isSelected = index != null 
        ? navigationProvider?.currentIndex == index
        : false;

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
      onTap: onTap ?? () {
        if (index != null && navigationProvider != null) {
          navigationProvider.setIndex(index);
        }
        Navigator.pop(context);
      },
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}