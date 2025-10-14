import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../screens/home_page.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/orders/screens/flash_order_screen.dart';
import '../../shared/providers/auth_provider.dart';
import 'bottom_navigation.dart';

/// 🏗️ Navigation Principale - Alpha Client App
///
/// Wrapper de navigation avec Bottom Navigation Bar et gestion des pages
/// avec animations fluides et state management intégré.
class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> 
    with TickerProviderStateMixin {
  
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    _fabAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: AppAnimations.bounceIn,
    ));
    
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomePage(),
          OrdersScreen(),
          ServicesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: PremiumBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// 🎯 Floating Action Button conditionnel
  Widget? _buildFloatingActionButton() {
    // Afficher le FAB seulement sur la page d'accueil
    if (_currentIndex != 0) return null;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ScaleTransition(
          scale: _fabAnimation,
          child: PremiumFloatingActionButton(
            onPressed: () => _handleFlashOrder(authProvider),
            tooltip: 'Commande Flash',
            icon: Icons.flash_on,
          ),
        );
      },
    );
  }

  /// ⚡ Gestionnaire Commande Flash
  void _handleFlashOrder(AuthProvider authProvider) {
    // Navigation directe vers FlashOrderScreen
    // La vérification de l'adresse se fera dans le service
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const FlashOrderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 📍 Dialog Adresse Requise
  void _showAddressRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Adresse requise',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        content: Text(
          'Pour utiliser la commande flash, vous devez d\'abord configurer une adresse par défaut.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Naviguer vers le profil pour configurer l'adresse
              _onNavItemTapped(3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Configurer'),
          ),
        ],
      ),
    );
  }

  /// 📱 Gestionnaire de navigation
  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: AppAnimations.medium,
      curve: AppAnimations.slideIn,
    );
    
    // Animation du FAB
    if (index == 0) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  /// 📄 Gestionnaire de changement de page
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Animation du FAB
    if (index == 0) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }
}

/// 🎯 Navigation Helper
class NavigationHelper {
  static void navigateToPage(BuildContext context, int pageIndex) {
    final mainNavState = context.findAncestorStateOfType<_MainNavigationState>();
    mainNavState?._onNavItemTapped(pageIndex);
  }
  
  static void navigateToHome(BuildContext context) {
    navigateToPage(context, 0);
  }
  
  static void navigateToOrders(BuildContext context) {
    navigateToPage(context, 1);
  }
  
  static void navigateToServices(BuildContext context) {
    navigateToPage(context, 2);
  }
  
  static void navigateToProfile(BuildContext context) {
    navigateToPage(context, 3);
  }
}