import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/shared/glass_container.dart';

/// ⚙️ Écran Paramètres - Alpha Delivery App
///
/// Interface mobile-first pour gérer les paramètres de l'application.
/// Fonctionnalités : notifications, thème, langue, cache, à propos.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialiser le contrôleur s'il n'existe pas
    if (!Get.isRegistered<SettingsController>()) {
      Get.put<SettingsController>(SettingsController());
    }

    final controller = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================================
            // 🔔 NOTIFICATIONS
            // =============================================================
            _buildSectionHeader('Notifications', Icons.notifications, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildNotificationsSection(controller, isDark),
            const SizedBox(height: AppSpacing.lg),

            // =============================================================
            // 🎨 APPARENCE
            // =============================================================
            _buildSectionHeader('Apparence', Icons.palette, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildAppearanceSection(controller, isDark),
            const SizedBox(height: AppSpacing.lg),

            // =============================================================
            // 🗺️ CARTE ET GPS
            // =============================================================
            _buildSectionHeader('Carte et GPS', Icons.map, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildMapSection(controller, isDark),
            const SizedBox(height: AppSpacing.lg),

            // =============================================================
            // 💾 DONNÉES ET CACHE
            // =============================================================
            _buildSectionHeader('Données et cache', Icons.storage, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildDataSection(controller, isDark),
            const SizedBox(height: AppSpacing.lg),

            // =============================================================
            // 🔒 CONFIDENTIALITÉ
            // =============================================================
            _buildSectionHeader('Confidentialité', Icons.privacy_tip, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildPrivacySection(controller, isDark),
            const SizedBox(height: AppSpacing.lg),

            // =============================================================
            // ℹ️ À PROPOS
            // =============================================================
            _buildSectionHeader('À propos', Icons.info, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildAboutSection(controller, isDark),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  /// 📋 Header de section
  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 🔔 Section notifications
  Widget _buildNotificationsSection(
      SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          Obx(() => _buildSwitchTile(
                'Notifications push',
                'Recevoir les notifications de nouvelles commandes',
                Icons.notifications_active,
                controller.pushNotificationsEnabled.value,
                (value) => controller.togglePushNotifications(value),
                isDark,
              )),
          const Divider(height: 1),
          Obx(() => _buildSwitchTile(
                'Sons de notification',
                'Jouer un son lors des notifications',
                Icons.volume_up,
                controller.notificationSoundsEnabled.value,
                (value) => controller.toggleNotificationSounds(value),
                isDark,
              )),
          const Divider(height: 1),
          Obx(() => _buildSwitchTile(
                'Vibrations',
                'Vibrer lors des notifications importantes',
                Icons.vibration,
                controller.vibrationsEnabled.value,
                (value) => controller.toggleVibrations(value),
                isDark,
              )),
          const Divider(height: 1),
          _buildTile(
            'Heures de notification',
            'Définir les heures de réception',
            Icons.schedule,
            () => _showNotificationHoursDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  '${controller.notificationStartHour.value}h - ${controller.notificationEndHour.value}h',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  /// 🎨 Section apparence
  Widget _buildAppearanceSection(SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          _buildTile(
            'Thème',
            'Choisir le thème de l\'application',
            Icons.brightness_6,
            () => _showThemeDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  controller.themeMode.value.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
          const Divider(height: 1),
          _buildTile(
            'Langue',
            'Changer la langue de l\'interface',
            Icons.language,
            () => _showLanguageDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  controller.language.value.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
          const Divider(height: 1),
          Obx(() => _buildSwitchTile(
                'Animations',
                'Activer les animations de l\'interface',
                Icons.animation,
                controller.animationsEnabled.value,
                (value) => controller.toggleAnimations(value),
                isDark,
              )),
        ],
      ),
    );
  }

  /// 🗺️ Section carte et GPS
  Widget _buildMapSection(SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          _buildTile(
            'Précision GPS',
            'Niveau de précision de la géolocalisation',
            Icons.gps_fixed,
            () => _showGpsPrecisionDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  controller.gpsPrecision.value.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
          const Divider(height: 1),
          Obx(() => _buildSwitchTile(
                'Suivi de position',
                'Partager votre position en temps réel',
                Icons.my_location,
                controller.locationTrackingEnabled.value,
                (value) => controller.toggleLocationTracking(value),
                isDark,
              )),
          const Divider(height: 1),
          _buildTile(
            'App de navigation',
            'Application de navigation par défaut',
            Icons.navigation,
            () => _showNavigationAppDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  controller.defaultNavigationApp.value.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  /// 💾 Section données et cache
  Widget _buildDataSection(SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          Obx(() => _buildSwitchTile(
                'Mode hors ligne',
                'Sauvegarder les données pour usage hors ligne',
                Icons.offline_bolt,
                controller.offlineModeEnabled.value,
                (value) => controller.toggleOfflineMode(value),
                isDark,
              )),
          const Divider(height: 1),
          _buildTile(
            'Vider le cache',
            'Supprimer les données temporaires',
            Icons.cleaning_services,
            () => _showClearCacheDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  '${controller.cacheSize.value} MB',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
          const Divider(height: 1),
          _buildTile(
            'Synchronisation auto',
            'Fréquence de synchronisation des données',
            Icons.sync,
            () => _showSyncFrequencyDialog(controller),
            isDark,
            trailing: Obx(() => Text(
                  controller.syncFrequency.value.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  /// 🔒 Section confidentialité
  Widget _buildPrivacySection(SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          Obx(() => _buildSwitchTile(
                'Analytics',
                'Partager des données d\'usage anonymes',
                Icons.analytics,
                controller.analyticsEnabled.value,
                (value) => controller.toggleAnalytics(value),
                isDark,
              )),
          const Divider(height: 1),
          Obx(() => _buildSwitchTile(
                'Crash reports',
                'Envoyer automatiquement les rapports d\'erreur',
                Icons.bug_report,
                controller.crashReportsEnabled.value,
                (value) => controller.toggleCrashReports(value),
                isDark,
              )),
          const Divider(height: 1),
          _buildTile(
            'Politique de confidentialité',
            'Consulter notre politique de confidentialité',
            Icons.policy,
            () => controller.openPrivacyPolicy(),
            isDark,
          ),
          const Divider(height: 1),
          _buildTile(
            'Conditions d\'utilisation',
            'Consulter les conditions d\'utilisation',
            Icons.description,
            () => controller.openTermsOfService(),
            isDark,
          ),
        ],
      ),
    );
  }

  /// ℹ️ Section à propos
  Widget _buildAboutSection(SettingsController controller, bool isDark) {
    return GlassContainer(
      child: Column(
        children: [
          _buildTile(
            'Version de l\'application',
            'Alpha Delivery App',
            Icons.info,
            null,
            isDark,
            trailing: Obx(() => Text(
                  controller.appVersion.value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ),
          const Divider(height: 1),
          _buildTile(
            'Vérifier les mises à jour',
            'Rechercher une nouvelle version',
            Icons.system_update,
            () => controller.checkForUpdates(),
            isDark,
          ),
          const Divider(height: 1),
          _buildTile(
            'Aide et support',
            'Obtenir de l\'aide ou contacter le support',
            Icons.help,
            () => controller.openSupport(),
            isDark,
          ),
          const Divider(height: 1),
          _buildTile(
            'Évaluer l\'application',
            'Donner votre avis sur l\'app store',
            Icons.star_rate,
            () => controller.rateApp(),
            isDark,
          ),
          const Divider(height: 1),
          _buildTile(
            'Licences open source',
            'Voir les licences des bibliothèques utilisées',
            Icons.code,
            () => controller.showLicenses(),
            isDark,
          ),
        ],
      ),
    );
  }

  /// 🔘 Widget tuile avec switch
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 📋 Widget tuile simple
  Widget _buildTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
    bool isDark, {
    Widget? trailing,
  }) {
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
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                )
              : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 🔔 Dialog heures de notification
  void _showNotificationHoursDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Heures de notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Définir les heures de réception des notifications'),
            const SizedBox(height: AppSpacing.lg),
            // TODO: Implémenter sélecteur d'heures
            const Text('Sélecteur d\'heures à implémenter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  /// 🎨 Dialog choix de thème
  void _showThemeDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((theme) {
            return Obx(() => RadioListTile<AppThemeMode>(
                  title: Text(theme.displayName),
                  value: theme,
                  groupValue: controller.themeMode.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setThemeMode(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
      ),
    );
  }

  /// 🌍 Dialog choix de langue
  void _showLanguageDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            return Obx(() => RadioListTile<AppLanguage>(
                  title: Text(language.displayName),
                  value: language,
                  groupValue: controller.language.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguage(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
      ),
    );
  }

  /// 📍 Dialog précision GPS
  void _showGpsPrecisionDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Précision GPS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GpsPrecision.values.map((precision) {
            return Obx(() => RadioListTile<GpsPrecision>(
                  title: Text(precision.displayName),
                  subtitle: Text(precision.description),
                  value: precision,
                  groupValue: controller.gpsPrecision.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setGpsPrecision(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
      ),
    );
  }

  /// 🧭 Dialog app de navigation
  void _showNavigationAppDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('App de navigation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NavigationApp.values.map((app) {
            return Obx(() => RadioListTile<NavigationApp>(
                  title: Text(app.displayName),
                  value: app,
                  groupValue: controller.defaultNavigationApp.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setDefaultNavigationApp(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
      ),
    );
  }

  /// 🗑️ Dialog vider le cache
  void _showClearCacheDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les données temporaires ? '
          'Cela peut ralentir l\'application temporairement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  /// 🔄 Dialog fréquence de synchronisation
  void _showSyncFrequencyDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Fréquence de synchronisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SyncFrequency.values.map((frequency) {
            return Obx(() => RadioListTile<SyncFrequency>(
                  title: Text(frequency.displayName),
                  value: frequency,
                  groupValue: controller.syncFrequency.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setSyncFrequency(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
      ),
    );
  }
}
