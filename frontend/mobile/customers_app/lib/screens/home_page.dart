import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// svg support removed; using PNG logo instead
import 'package:provider/provider.dart';
import '../constants.dart';
import '../components/glass_components.dart';
import '../core/models/order.dart';
import '../theme/theme_provider.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/providers/address_provider.dart';
import '../shared/providers/notification_provider.dart';
import '../features/orders/screens/flash_order_screen.dart';
import '../features/orders/screens/create_order_screen.dart';
import '../features/profile/screens/address_management_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';

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
    await Future.delayed(const Duration(seconds: 2));
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
        // 🌓 Toggle de thème
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ThemeToggle(themeProvider: themeProvider),
            );
          },
        ),
        // 🔔 Notifications avec badge
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                              const NotificationsScreen(),
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
                    },
                  ),
                  if (notificationProvider.hasUnreadNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            notificationProvider.unreadCount > 9 
                                ? '9+' 
                                : '${notificationProvider.unreadCount}',
                            style: AppTextStyles.overline.copyWith(
                              color: Colors.white,
                              fontSize: 8,
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final loyaltyPoints = authProvider.loyaltyPoints;
        final loyaltyTier = authProvider.loyaltyTier;
        
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  /// ⚡ Section Commande Rapide
  Widget _buildQuickOrderSection() {
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
              _buildQuickOrderCard(
                'Chemise',
                'À partir de 8€',
                Icons.checkroom,
                AppColors.success,
              ),
              _buildQuickOrderCard(
                'Pantalon',
                'À partir de 10€',
                Icons.checkroom_outlined,
                AppColors.warning,
              ),
              _buildQuickOrderCard(
                'Costume',
                'À partir de 25€',
                Icons.work_outline,
                AppColors.info,
              ),
              _buildQuickOrderCard(
                'Robe',
                'À partir de 15€',
                Icons.woman,
                AppColors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOrderCard(
      String title, String price, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        // Ensure the card fills the parent's vertical space (the horizontal ListView
        // provides a bounded height). This prevents the inner Column from exceeding
        // the available height and causing a RenderFlex overflow.
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
          // Center content vertically so items don't push past the bottom on
          // small heights.
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
            // Constrain the title so it can't grow vertically and cause overflow.
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
              price,
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
    );
  }

  /// 🛍️ Section Services
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
              onPressed: () {},
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
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
            final itemHeight = itemWidth * 0.85; // Ratio plus adaptatif
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: itemWidth / itemHeight,
              children: [
                _buildServiceCard(
                  'Nettoyage à Sec',
                  'Service professionnel',
                  Icons.dry_cleaning,
                  AppColors.primary,
                ),
                _buildServiceCard(
                  'Repassage',
                  'Finition parfaite',
                  Icons.iron,
                  AppColors.warning,
                ),
                _buildServiceCard(
                  'Retouches',
                  'Ajustements sur mesure',
                  Icons.content_cut,
                  AppColors.info,
                ),
                _buildServiceCard(
                  'Express 24h',
                  'Livraison rapide',
                  Icons.flash_on,
                  AppColors.success,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
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
    );
  }

  /// 📋 Section Commandes Récentes
  Widget _buildRecentOrdersSection() {
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
              onPressed: () {},
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
        _buildOrderCard(
          'CMD001',
          '3 Chemises + 1 Pantalon',
          OrderStatus.processing,
          DateTime.now().subtract(const Duration(days: 2)),
          '28€',
        ),
        const SizedBox(height: 12),
        _buildOrderCard(
          'CMD002',
          '1 Costume complet',
          OrderStatus.ready,
          DateTime.now().subtract(const Duration(days: 5)),
          '45€',
        ),
        const SizedBox(height: 12),
        _buildOrderCard(
          'CMD003',
          '2 Robes de soirée',
          OrderStatus.delivered,
          DateTime.now().subtract(const Duration(days: 8)),
          '35€',
        ),
      ],
    );
  }

  Widget _buildOrderCard(String orderId, String description, OrderStatus status,
      DateTime date, String price) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.draft:
        statusColor = AppColors.textTertiary(context);
        statusText = 'Brouillon';
        statusIcon = Icons.edit;
        break;
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'En attente';
        statusIcon = Icons.pending;
        break;
      case OrderStatus.collecting:
        statusColor = AppColors.info;
        statusText = 'Collecte';
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.collected:
        statusColor = AppColors.primary;
        statusText = 'Collectée';
        statusIcon = Icons.inventory_2;
        break;
      case OrderStatus.processing:
        statusColor = AppColors.info;
        statusText = 'En cours';
        statusIcon = Icons.refresh;
        break;
      case OrderStatus.ready:
        statusColor = AppColors.success;
        statusText = 'Prêt';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.delivering:
        statusColor = AppColors.accent;
        statusText = 'En livraison';
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.textSecondary(context);
        statusText = 'Livré';
        statusIcon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Annulé';
        statusIcon = Icons.cancel;
        break;
    }

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderId,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      price,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      text: statusText,
                      color: statusColor,
                      icon: statusIcon,
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎁 Section Promotions
  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_offer,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offre Spéciale',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '-20% sur votre prochaine commande de plus de 50€',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'En profiter',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.canMakeFlashOrders) {
      _showAddressRequiredDialog();
      return;
    }
    
    // Navigation vers l'écran de commande flash
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
                        leading: Icon(Icons.person_outline, color: AppColors.textPrimary(context)),
                        title: Text('Profil', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigation vers l'écran de profil
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                  const ProfileScreen(),
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
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings_outlined, color: AppColors.textPrimary(context)),
                        title: Text('Paramètres', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to settings
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help_outline, color: AppColors.textPrimary(context)),
                        title: Text('Aide', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context))),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to help
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: AppColors.error),
                        title: Text('Déconnexion', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
                        onTap: () async {
                          Navigator.pop(context);
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed('/login');
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
}
