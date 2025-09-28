import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';

/// 🏠 Écran Dashboard - Alpha Delivery App
/// 
/// Dashboard principal mobile-first pour les livreurs
/// avec statistiques, commandes du jour et actions rapides.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Get.find<DashboardController>().refreshData(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar personnalisée
              _buildSliverAppBar(isDark),
              
              // Contenu principal avec padding sécurisé
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl * 2, // Espace pour bottom nav + FAB
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Statistiques rapides
                    _buildQuickStats(isDark),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Actions rapides
                    _buildQuickActions(isDark),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Commandes du jour
                    _buildTodayOrders(isDark),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Statut et disponibilité
                    _buildStatusSection(isDark),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Navigation bottom
      bottomNavigationBar: _buildBottomNavigation(isDark),
      
      // FAB pour action principale
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// App Bar avec glassmorphism
  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        title: GetBuilder<AuthController>(
          builder: (authController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.gray600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: authController.roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: authController.roleColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            authController.roleIcon,
                            size: 12,
                            color: authController.roleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            authController.roleDisplayName,
                            style: AppTextStyles.caption.copyWith(
                              color: authController.roleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  authController.currentUserName,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              // Badge de notification
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO: Ouvrir les notifications
          },
        ),
        
        // Menu profil
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Profil'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Paramètres'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Statistiques rapides
  Widget _buildQuickStats(bool isDark) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _buildStatsLoading(isDark);
        }
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Aujourd\'hui',
                '${controller.todayDeliveries}',
                Icons.today,
                AppColors.primary,
                isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Cette semaine',
                '${controller.weekDeliveries}',
                Icons.calendar_view_week,
                AppColors.success,
                isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Gains',
                '${controller.todayEarnings} F',
                Icons.monetization_on,
                AppColors.warning,
                isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Card de statistique
  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
              : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Loading des statistiques
  Widget _buildStatsLoading(bool isDark) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < 2 ? AppSpacing.sm : 0,
            ),
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
              borderRadius: AppRadius.radiusMD,
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }),
    );
  }

  /// Actions rapides
  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Commandes',
                Icons.list_alt,
                AppColors.primary,
                () => Get.toNamed('/orders'),
                isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionButton(
                'Carte',
                Icons.map,
                AppColors.info,
                () => Get.toNamed('/map'),
                isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionButton(
                'Historique',
                Icons.history,
                AppColors.secondary,
                () => Get.toNamed('/orders?tab=history'),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bouton d'action
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMD,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Section commandes du jour
  Widget _buildTodayOrders(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Commandes du jour',
              style: AppTextStyles.h4.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/orders'),
              child: Text(
                'Voir tout',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Liste des commandes (placeholder)
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: isDark 
                  ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
                  : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Aucune commande pour aujourd\'hui',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Section statut et disponibilité
  Widget _buildStatusSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
              : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statut',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Statut de disponibilité
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Disponible',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Changer la disponibilité
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Navigation bottom
  Widget _buildBottomNavigation(bool isDark) {
    return BottomAppBar(
      color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', true, () {}),
          _buildNavItem(Icons.list_alt, 'Commandes', false, () => Get.toNamed('/orders')),
          const SizedBox(width: 40), // Espace pour le FAB
          _buildNavItem(Icons.map, 'Carte', false, () => Get.toNamed('/map')),
          _buildNavItem(Icons.person, 'Profil', false, () => Get.toNamed('/profile')),
        ],
      ),
    );
  }

  /// Item de navigation
  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.gray500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.gray500,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating Action Button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Action principale (scanner QR code, nouvelle commande, etc.)
        Get.snackbar(
          'Action',
          'Fonctionnalité en cours de développement',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.info.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(AppSpacing.md),
          borderRadius: MobileDimensions.radiusMD,
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.qr_code_scanner, color: Colors.white),
    );
  }

  /// Gère les actions du menu
  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        Get.toNamed('/profile');
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  /// Affiche le dialog de déconnexion
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}