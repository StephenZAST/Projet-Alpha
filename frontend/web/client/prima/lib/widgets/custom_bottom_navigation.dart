import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray500,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.local_offer_rounded, 'Offres', 1),
            _buildNavItem(Icons.add_circle, '', 2),
            _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
            _buildNavItem(Icons.person_rounded, 'Profile', 4),
          ],
          onTap: onItemSelected,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: index == 2 ? 0 : 24, // Hide the middle icon
      ),
      label: label,
    );
  }
}
