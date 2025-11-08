import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../components/glass_components.dart';
import '../theme/theme_provider.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/providers/user_profile_provider.dart';
import '../shared/providers/notification_provider.dart';
import '../features/orders/screens/flash_order_screen.dart';
import '../features/orders/screens/create_order_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/orders/widgets/order_card.dart';
import '../screens/orders/order_details_screen.dart';
import '../features/profile/screens/address_management_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/services/screens/services_screen.dart';
import '../features/offers/screens/offers_screen.dart';
import '../providers/orders_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/services_provider.dart';
import '../providers/offers_provider.dart';
import 'loyalty/loyalty_dashboard_screen.dart';
import 'loyalty/rewards_catalog_screen.dart';

/// 🏠 Page d'Accueil Premium - Alpha Client App
///
/// Page d'accueil sophistiquée avec glassmorphism et animations fluides.
/// Représente l'excellence du design Alpha Pressing.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _simulateLoading();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.slideIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.slideIn,
    ));
  }

  void _simulateLoading() async {
    // ✅ Charger les données réelles avec cache
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);
    final servicesProvider =
        Provider.of<ServicesProvider>(context, listen: false);
    final profileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);

    try {
      // Charger en parallèle (utilise le cache si valide)
      await Future.wait([
        profileProvider
            .initialize(), // ✅ Charger le profil en premier pour les points
        ordersProvider.initialize(),
        loyaltyProvider.initialize(),
        servicesProvider.initialize(),
      ]);

      debugPrint('🏠 [HomePage] Tous les providers initialisés');
      debugPrint('   💰 Points: ${profileProvider.loyaltyPoints}');
    } catch (e) {
      debugPrint('❌ [HomePage] Erreur chargement: $e');
    }

    setState(() => _isLoading = false);
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Don't draw the body behind the AppBar to avoid visual overlap with
      // the top cards / hero area. This ensures the AppBar logo area isn't
      // visually masked by content that sits under the AppBar.
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildHomeContent(),
    );
  }

  /// 📱 AppBar Transparente Premium avec Logo SVG
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Row(
        children: [
          // 🎨 Logo SVG Alpha
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                // Use contain so the PNG keeps its aspect ratio and cannot
                // overflow the 40x40 container. Padding keeps some inner
                // breathing room (avoids the image touching rounded corners).
                child: Image.asset(
                  'assets/Frame 95.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Alpha Pressing',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        // 🌓 Toggle de thème - Glassmorphism Soft
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildGlassIconButton(
                icon: themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onPressed: () {
                  themeProvider.toggleTheme();
                  HapticFeedback.lightImpact();
                },
                tooltip: 'Changer le thème',
              ),
            );
          },
        ),
        // 🔔 Notifications avec badge - Glassmorphism Soft
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  _buildGlassIconButton(
                    icon: Icons.notifications_none_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const NotificationsScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero)
                                    .chain(CurveTween(
                                        curve: AppAnimations.slideIn)),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: AppAnimations.medium,
                        ),
                      );
                    },
                    tooltip: 'Notifications',
                  ),
                  // Badge élégant
                  if (notificationProvider.hasUnreadNotifications)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            notificationProvider.unreadCount > 9
                                ? '9+'
                                : '${notificationProvider.unreadCount}',
                            style: AppTextStyles.overline.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 💀 Écran de Chargement Premium
  Widget _buildLoadingScreen() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildSkeletonHeader(),
                const SizedBox(height: 32),
                _buildSkeletonServices(),
                const SizedBox(height: 32),
                _buildSkeletonOrders(),
                const SizedBox(height: 32), // Espace supplémentaire en bas
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return GlassContainer(
      padding: AppSpacing.cardPadding,
      child: Column(
        children: [
          const SkeletonLoader(width: double.infinity, height: 24),
          const SizedBox(height: 12),
          const SkeletonLoader(width: 200, height: 16),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: SkeletonLoader(width: double.infinity, height: 48),
              ),
              const SizedBox(width: 12),
              const SkeletonLoader(width: 60, height: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 150, height: 20),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
                child: GlassContainer(
                  padding: AppSpacing.cardPadding,
                  child: const Column(
                    children: [
                      SkeletonLoader(width: 40, height: 40),
                      SizedBox(height: 12),
                      SkeletonLoader(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 80, height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 180, height: 20),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: AppSpacing.cardPadding,
              child: const Row(
                children: [
                  SkeletonLoader(width: 50, height: 50),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: double.infinity, height: 16),
                        SizedBox(height: 8),
                        SkeletonLoader(width: 120, height: 14),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            SkeletonLoader(width: 80, height: 24),
                            Spacer(),
                            SkeletonLoader(width: 60, height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎨 Contenu Principal Premium
  Widget _buildHomeContent() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildQuickOrderSection(),
                  const SizedBox(height: 32),
                  _buildServicesSection(),
                  const SizedBox(height: 32),
                  _buildRecentOrdersSection(),
                  const SizedBox(height: 32),
                  _buildPromoSection(),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 👋 Section d'Accueil Premium
  Widget _buildWelcomeSection() {
    return Consumer2<AuthProvider, UserProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = authProvider.currentUser;
        final loyaltyInfo = profileProvider.loyaltyInfo;
        final loyaltyPoints = loyaltyInfo['points'] ??
            0; // ✅ Données réelles depuis UserProfileProvider
        final loyaltyTier = loyaltyInfo['tier'] ??
            'BRONZE'; // ✅ Tier depuis UserProfileProvider

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec salutation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      user?.firstName ?? 'Utilisateur',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showProfileMenu,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        authProvider.userInitials,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Carte principale style banking
            GestureDetector(
              onTap: _handleNewOrderTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alpha Premium',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            loyaltyTier.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Points de fidélité',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$loyaltyPoints pts',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _handleNewOrderTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Nouvelle Commande',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _handleFlashOrderTap,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ⚡ Section Services Populaires (Raccourcis)
  Widget _buildQuickOrderSection() {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final loyaltyPoints = profileProvider.loyaltyPoints;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services populaires',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // 1. Fidélité Dashboard
                  _buildQuickActionCard(
                    '$loyaltyPoints pts',
                    'Mes récompenses',
                    Icons.stars,
                    AppColors.purple,
                    () => _navigateToLoyaltyDashboard(),
                  ),

                  // 2. Mes Adresses
                  _buildQuickActionCard(
                    'Adresses',
                    'Mes Adresses',
                    Icons.location_on,
                    AppColors.success,
                    () => _navigateToAddresses(),
                  ),

                  // 3. Offres
                  _buildQuickActionCard(
                    'Offres',
                    'Offres',
                    Icons.local_offer,
                    AppColors.warning,
                    () => _navigateToOffers(),
                  ),

                  // 4. Récompenses
                  _buildQuickActionCard(
                    'Récompenses',
                    'Échanger',
                    Icons.card_giftcard,
                    AppColors.accent,
                    () => _navigateToRewards(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceVariant(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛍️ Section Services (✅ Hardcodé - Simple et rapide)
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nos Services',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ServicesScreen(),
                  ),
                );
              },
              child: Text(
                'Voir tout',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid 2x2 avec les 4 services en dur
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 12) /
                    crossAxisCount;
            final itemHeight = itemWidth * 0.85;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: itemWidth / itemHeight,
              children: [
                _buildServiceCardSimple(
                  'Nettoyage à sec',
                  'Utilisation de solvants non aqueux',
                  Icons.dry_cleaning,
                  AppColors.success,
                ),
                _buildServiceCardSimple(
                  'LAVAGE + REPASSAGE',
                  'Nettoyage à l\'eau + repassage',
                  Icons.local_laundry_service,
                  AppColors.info,
                ),
                _buildServiceCardSimple(
                  'Repassage Simple',
                  'Repassage unique de vos vêtements',
                  Icons.iron,
                  AppColors.warning,
                ),
                _buildServiceCardSimple(
                  'Lavage Simple',
                  'Lavage unique de vos vêtements',
                  Icons.water_drop,
                  AppColors.primary,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 📦 Carte de service simple (hardcodée)
  Widget _buildServiceCardSimple(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigation vers le stepper de création de commande
        _handleNewOrderTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceVariant(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Section Commandes Récentes (✅ Données réelles)
  Widget _buildRecentOrdersSection() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        // Récupérer les 3 dernières commandes
        final recentOrders = ordersProvider.orders.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commandes Récentes',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // ✅ Navigation vers OrdersScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Historique',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Afficher les vraies commandes
            if (ordersProvider.isLoading)
              ...List.generate(3, (index) => _buildSkeletonOrderCard())
            else if (recentOrders.isEmpty)
              _buildEmptyOrdersState()
            else
              ...recentOrders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: order,
                      onTap: () {
                        // Navigation vers les détails
                        ordersProvider.selectOrder(order);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  )),
          ],
        );
      },
    );
  }

  /// 📦 État vide - Aucune commande
  Widget _buildEmptyOrdersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceVariant(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande récente',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première commande',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 💀 Skeleton pour les commandes en chargement
  Widget _buildSkeletonOrderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceVariant(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SkeletonLoader(width: 60, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 120, height: 14),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SkeletonLoader(width: 80, height: 24),
                    const Spacer(),
                    const SkeletonLoader(width: 60, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎁 Section Promotions - Offre Généreuse Première Commande
  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.15),
            AppColors.primary.withOpacity(0.15)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icône avec gradient
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // Contenu texte compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 Bienvenue chez Alpha!',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2 chemises + 1 pantalon gratuits en premium',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bouton compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Profiter',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🛍️ Gestionnaire Nouvelle Commande
  void _handleNewOrderTap() {
    HapticFeedback.lightImpact();

    // Navigation vers l'écran de création de commande complète
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateOrderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// ⚡ Gestionnaire Commande Flash
  void _handleFlashOrderTap() {
    HapticFeedback.lightImpact();

    // Navigation directe vers l'écran de commande flash
    // La vérification de l'adresse se fera dans FlashOrderScreen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FlashOrderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
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
          'Pour utiliser la commande flash, vous devez d\'abord configurer une adresse par défaut dans votre profil.',
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
          PremiumButton(
            text: 'Configurer',
            onPressed: () {
              Navigator.pop(context);
              // Navigation vers la gestion des adresses
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddressManagementScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: AppAnimations.slideIn)),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: AppAnimations.medium,
                ),
              );
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// 📱 Afficher SnackBar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 👤 Menu Profil
  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Menu items
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline,
                            color: AppColors.textPrimary(context)),
                        title: Text('Profil',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigation vers l'écran de profil
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ProfileScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero)
                                        .chain(CurveTween(
                                            curve: AppAnimations.slideIn)),
                                  ),
                                  child: child,
                                );
                              },
                              transitionDuration: AppAnimations.medium,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings_outlined,
                            color: AppColors.textPrimary(context)),
                        title: Text('Paramètres',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to settings
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help_outline,
                            color: AppColors.textPrimary(context)),
                        title: Text('Aide',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to help
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: AppColors.error),
                        title: Text('Déconnexion',
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.error)),
                        onTap: () async {
                          Navigator.pop(context);
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎁 Navigation vers Loyalty Dashboard
  void _navigateToLoyaltyDashboard() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoyaltyDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 📍 Navigation vers Adresses
  void _navigateToAddresses() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddressManagementScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 🎁 Navigation vers Offres
  void _navigateToOffers() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OffersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 🎁 Navigation vers Récompenses
  void _navigateToRewards() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RewardsCatalogScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 🚧 Dialog "Bientôt disponible"
  void _showComingSoonDialog(String featureName) {
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
              Icons.construction,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Bientôt disponible',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'La fonctionnalité "$featureName" sera bientôt disponible. Restez connecté!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          PremiumButton(
            text: 'Compris',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 💎 Bouton Icône Glassmorphism Soft & Smart
  /// Design élégant et subtil pour les actions du header
  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // Glassmorphism soft background
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
                width: 1,
              ),
              // Subtle shadow pour la profondeur
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary(context),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
