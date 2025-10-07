import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../components/glass_components.dart';

/// 📱 Bottom Navigation Premium - Alpha Client App
///
/// Navigation bar sophistiquée avec glassmorphism et animations fluides
/// pour une expérience utilisateur premium.
class PremiumBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.surface(context).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.border(context),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Accueil',
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              label: 'Commandes',
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.local_laundry_service_outlined,
              activeIcon: Icons.local_laundry_service,
              label: 'Services',
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isActive 
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive 
                      ? AppColors.primary 
                      : AppColors.textSecondary(context),
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive 
                        ? AppColors.primary 
                        : AppColors.textTertiary(context),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 10,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎯 Navigation Items Data
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// 📋 Navigation Items Configuration
class NavigationConfig {
  static const List<NavigationItem> items = [
    NavigationItem(
      label: 'Accueil',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/home',
    ),
    NavigationItem(
      label: 'Commandes',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: '/orders',
    ),
    NavigationItem(
      label: 'Services',
      icon: Icons.local_laundry_service_outlined,
      activeIcon: Icons.local_laundry_service,
      route: '/services',
    ),
    NavigationItem(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];
}

/// 🎨 Floating Action Button Premium
class PremiumFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  const PremiumFloatingActionButton({
    Key? key,
    required this.onPressed,
    this.tooltip = 'Commande Flash',
    this.icon = Icons.flash_on,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}