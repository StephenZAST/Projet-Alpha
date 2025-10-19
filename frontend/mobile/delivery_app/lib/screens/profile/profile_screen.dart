import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/shared/glass_container.dart';
import '../../routes/app_routes.dart';

/// 👤 Écran Profil Livreur - Alpha Delivery App
///
/// Interface mobile-first pour afficher et gérer le profil du livreur.
/// Fonctionnalités : informations personnelles, statistiques, paramètres.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          // =================================================================
          // 📱 SIMPLE APP BAR
          // =================================================================
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              onPressed: () => Get.back(),
            ),
            actions: const [],
          ),

          // =================================================================
          // 👤 HEADER PROFIL GLASSMORPHISM
          // =================================================================
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildProfileHeader(context, controller, isDark),
            ),
          ),

          // =================================================================
          // 📊 CONTENU PRINCIPAL
          // =================================================================
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),

                // Statut de disponibilité
                _buildAvailabilitySection(controller, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Statistiques de performance
                _buildPerformanceSection(controller, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Informations personnelles
                _buildPersonalInfoSection(controller, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Actions rapides
                _buildQuickActionsSection(controller, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Paramètres
                _buildSettingsSection(controller, isDark),

                // Espacement pour la navigation bottom
                const SizedBox(height: AppSpacing.xxl * 2),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 Header profil refactorisé - Glassmorphism
  Widget _buildProfileHeader(
    BuildContext context,
    ProfileController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primaryDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(MobileDimensions.radiusLG),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: AppShadows.glassmorphism,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ============================================================
            // 🔝 TOP ROW : Avatar + Infos + Actions
            // ============================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Obx(() => _buildProfileAvatar(controller, isDark)),
                const SizedBox(width: AppSpacing.lg),

                // Infos (Nom + Rôle)
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.user.value?.fullName ?? 'Livreur',
                            style: AppTextStyles.h4.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: AppRadius.radiusSM,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              controller.user.value?.role.toUpperCase() ??
                                  'LIVREUR',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )),
                ),

                // Boutons d'action (Edit + Menu)
                Column(
                  children: [
                    _buildHeaderActionButton(
                      Icons.edit,
                      AppColors.info,
                      () => _showEditProfileDialog(controller),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHeaderActionButton(
                      Icons.more_vert,
                      AppColors.gray400,
                      () => _showHeaderMenu(controller),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ============================================================
            // 📊 STATS RAPIDES (2 colonnes)
            // ============================================================
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatItem(
                        'Livraisons',
                        '${controller.stats.value?.totalDeliveries ?? 0}',
                        Icons.local_shipping,
                        AppColors.primary,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildQuickStatItem(
                        'Revenus',
                        '${controller.getFormattedStats()['totalEarnings'] ?? '0'} FCFA',
                        Icons.payments,
                        AppColors.success,
                        isDark,
                      ),
                    ),
                  ],
                )),

            const SizedBox(height: AppSpacing.md),

            // ============================================================
            // 🟢 STATUT DISPONIBILITÉ
            // ============================================================
            Obx(() => Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: controller.isAvailable.value
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.gray400.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(
                      color: controller.isAvailable.value
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.gray400.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isAvailable.value
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: controller.isAvailable.value
                            ? AppColors.success
                            : AppColors.gray400,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.isAvailable.value
                                  ? 'Disponible'
                                  : 'Non disponible',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              controller.isAvailable.value
                                  ? 'Prêt pour les livraisons'
                                  : 'Pas de nouvelles commandes',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.isAvailable.value,
                        onChanged: (value) =>
                            controller.toggleAvailability(),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 🔘 Bouton d'action du header
  Widget _buildHeaderActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  /// 📊 Item stat rapide
  Widget _buildQuickStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 👤 Avatar de profil
  Widget _buildProfileAvatar(ProfileController controller, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: _buildDefaultAvatar(controller),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: controller.isAvailable.value
                  ? AppColors.success
                  : AppColors.gray400,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.gray800 : Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              controller.isAvailable.value ? Icons.check : Icons.pause,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// 👤 Avatar par défaut
  Widget _buildDefaultAvatar(ProfileController controller) {
    return Center(
      child: Text(
        controller.user.value?.initials ?? 'L',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🎬 Menu header
  void _showHeaderMenu(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Get.back();
                AppRoutes.toSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () {
                Get.back();
                _showHelpDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showLogoutDialog(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 Section statut de disponibilité
  Widget _buildAvailabilitySection(ProfileController controller, bool isDark) {
    return Obx(() => GlassContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    controller.isAvailable.value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: controller.isAvailable.value
                        ? AppColors.success
                        : AppColors.gray400,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isAvailable.value
                              ? 'Disponible'
                              : 'Non disponible',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          controller.isAvailable.value
                              ? 'Pour livraisons'
                              : 'Pas de commandes',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Switch(
                    value: controller.isAvailable.value,
                    onChanged: (value) => controller.toggleAvailability(),
                    activeColor: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                controller.isAvailable.value
                    ? 'Vous recevrez de nouvelles commandes'
                    : 'Vous ne recevrez pas de nouvelles commandes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }

  /// 📊 Section statistiques de performance
  Widget _buildPerformanceSection(ProfileController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performances ce mois',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Livraisons',
                      '${controller.stats.value?.totalDeliveries ?? 0}',
                      Icons.local_shipping,
                      AppColors.primary,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStatCard(
                      'Revenus',
                      '${controller.getFormattedStats()['totalEarnings'] ?? '0'} FCFA',
                      Icons.payments,
                      AppColors.success,
                      isDark,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: AppSpacing.md),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Note moyenne',
                      '${controller.getFormattedStats()['averageRating'] ?? '0.0'}/5',
                      Icons.star,
                      AppColors.warning,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStatCard(
                      'Taux réussite',
                      '${controller.getFormattedStats()['successRate'] ?? '0%'}',
                      Icons.check_circle,
                      AppColors.info,
                      isDark,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  /// 📊 Card statistique
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 👤 Section informations personnelles
  Widget _buildPersonalInfoSection(ProfileController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Informations personnelles',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showEditProfileDialog(controller),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => Column(
                children: [
                  _buildInfoRow(
                    'Nom complet',
                    controller.user.value?.fullName ?? 'Non défini',
                    Icons.person,
                    isDark,
                  ),
                  _buildInfoRow(
                    'Téléphone',
                    controller.user.value?.phone ?? 'Non défini',
                    Icons.phone,
                    isDark,
                  ),
                  _buildInfoRow(
                    'Email',
                    controller.user.value?.email ?? 'Non défini',
                    Icons.email,
                    isDark,
                  ),
                  _buildInfoRow(
                    'Date d\'inscription',
                    controller.user.value?.createdAt != null
                        ? _formatDate(controller.user.value!.createdAt)
                        : 'Non défini',
                    Icons.calendar_today,
                    isDark,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  /// ⚡ Section actions rapides
  Widget _buildQuickActionsSection(ProfileController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Historique',
                  Icons.history,
                  AppColors.info,
                  () => _showDeliveryHistory(controller),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildActionButton(
                  'Gains',
                  Icons.account_balance_wallet,
                  AppColors.success,
                  () => _showEarningsDetails(controller),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Support',
                  Icons.support_agent,
                  AppColors.warning,
                  () => _contactSupport(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildActionButton(
                  'Évaluer',
                  Icons.star_rate,
                  AppColors.secondary,
                  () => _rateApp(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔘 Bouton d'action
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// ⚙️ Section paramètres
  Widget _buildSettingsSection(ProfileController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSettingsTile(
            'Notifications',
            'Gérer les notifications push',
            Icons.notifications,
            () => AppRoutes.toSettings(),
            isDark,
          ),
          _buildSettingsTile(
            'Confidentialité',
            'Paramètres de confidentialité',
            Icons.privacy_tip,
            () => _showPrivacySettings(),
            isDark,
          ),
          _buildSettingsTile(
            'À propos',
            'Version et informations',
            Icons.info,
            () => _showAboutDialog(),
            isDark,
          ),
        ],
      ),
    );
  }

  /// ⚙️ Tuile de paramètre
  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.gray400 : AppColors.gray500,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.gray400 : AppColors.gray500,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 📋 Widget ligne d'information
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✏️ Dialog d'édition de profil
  void _showEditProfileDialog(ProfileController controller) {
    Get.snackbar(
      'Édition',
      'Fonctionnalité d\'édition à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// Afficher l'historique des livraisons
  void _showDeliveryHistory(ProfileController controller) {
    Get.snackbar(
      'Historique',
      'Historique des livraisons à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// 💰 Afficher les détails des gains
  void _showEarningsDetails(ProfileController controller) {
    Get.snackbar(
      'Gains',
      'Détails des gains à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// 📞 Contacter le support
  void _contactSupport() {
    Get.snackbar(
      'Support',
      'Contact support à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// ⭐ Évaluer l'application
  void _rateApp() {
    Get.snackbar(
      'Évaluation',
      'Évaluation de l\'app à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// 🔒 Paramètres de confidentialité
  void _showPrivacySettings() {
    Get.snackbar(
      'Confidentialité',
      'Paramètres de confidentialité à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// ℹ️ Dialog à propos
  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('À propos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alpha Delivery App'),
            SizedBox(height: AppSpacing.sm),
            Text('Version 1.0.0'),
            SizedBox(height: AppSpacing.sm),
            Text('Application de livraison pour Alpha Laundry'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// ❓ Dialog d'aide
  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Aide'),
        content: const Text(
          'Pour toute assistance, contactez le support technique ou consultez la documentation dans les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// 🚪 Dialog de déconnexion
  void _showLogoutDialog(ProfileController controller) {
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
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }



  /// 📅 Formatage des dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
