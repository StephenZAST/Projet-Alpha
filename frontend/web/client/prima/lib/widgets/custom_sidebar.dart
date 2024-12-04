import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class CustomSidebar extends StatelessWidget {
  final String userName;
  const CustomSidebar({super.key, this.userName = 'ZAKANE'});

  @override
  Widget build(BuildContext context) {
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
            isSelected: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            text: 'Offres',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/offers');
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            text: 'Services',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/services');
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Commandes',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/orders');
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            text: 'Notifications',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/chat');
            },
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            text: 'Parrainage',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/referral');
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Réglages',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
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
