import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15), 
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.gray500,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            items: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.local_offer_rounded, 'Offres', 1),
              const BottomNavigationBarItem(
                icon: SizedBox(height: 40), 
                label: '',
              ),
              _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
              _buildNavItem(Icons.person_rounded, 'Profile', 4),
            ],
            onTap: (index) {
              if (index != 2) { 
                onItemSelected(index);
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/offers');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/chat');
                    break;
                  case 4:
                    Navigator.pushReplacementNamed(context, '/profile');
                    break;
                }
              }
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -22, 
          child: Center(
            child: SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 30),
              ),
              onTap: () {
                // TODO: Implement add order functionality
              },
              scaleCoefficient: 0.9,
              useCache: false,
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(selectedIndex == index ? 12 : 8),
        decoration: BoxDecoration(
          color: selectedIndex == index 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
