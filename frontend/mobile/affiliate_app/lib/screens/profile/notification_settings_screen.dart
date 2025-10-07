import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/notification_system.dart';

/// 🔔 Écran Paramètres de Notification - Alpha Affiliate App
///
/// Permet de configurer les préférences de notifications

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // États des notifications
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  // Types de notifications
  bool _orderUpdates = true;
  bool _commissionUpdates = true;
  bool _withdrawalUpdates = true;
  bool _promotions = true;
  bool _levelUpdates = true;
  bool _referralUpdates = true;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildChannelsSection(),
            const SizedBox(height: 24),
            _buildTypesSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Notifications',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  /// 🎯 En-tête
  Widget _buildHeader() {
    return GlassContainer(
      child: Row(
        children: [
          GlassContainer(
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            color: AppColors.info.withOpacity(0.20),
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres de Notification',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configurez vos préférences de notifications',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📡 Section canaux de notification
  Widget _buildChannelsSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Canaux de Notification',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choisissez comment recevoir vos notifications',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'Notifications Email',
            subtitle: 'Recevoir les notifications par email',
            icon: Icons.email_outlined,
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
          _buildSwitchTile(
            title: 'Notifications Push',
            subtitle: 'Recevoir les notifications sur l\'application',
            icon: Icons.notifications_outlined,
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
          ),
          _buildSwitchTile(
            title: 'Notifications SMS',
            subtitle: 'Recevoir les notifications par SMS',
            icon: Icons.sms_outlined,
            value: _smsNotifications,
            onChanged: (value) => setState(() => _smsNotifications = value),
          ),
        ],
      ),
    );
  }

  /// 🏷️ Section types de notifications
  Widget _buildTypesSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Types de Notifications',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez les types de notifications à recevoir',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'Mises à jour des commandes',
            subtitle: 'Notifications sur l\'état des commandes de vos clients',
            icon: Icons.shopping_bag_outlined,
            value: _orderUpdates,
            onChanged: (value) => setState(() => _orderUpdates = value),
          ),
          _buildSwitchTile(
            title: 'Commissions',
            subtitle: 'Notifications sur vos gains et commissions',
            icon: Icons.account_balance_wallet_outlined,
            value: _commissionUpdates,
            onChanged: (value) => setState(() => _commissionUpdates = value),
          ),
          _buildSwitchTile(
            title: 'Retraits',
            subtitle: 'Notifications sur vos demandes de retrait',
            icon: Icons.money_outlined,
            value: _withdrawalUpdates,
            onChanged: (value) => setState(() => _withdrawalUpdates = value),
          ),
          _buildSwitchTile(
            title: 'Promotions',
            subtitle: 'Offres spéciales et promotions',
            icon: Icons.local_offer_outlined,
            value: _promotions,
            onChanged: (value) => setState(() => _promotions = value),
          ),
          _buildSwitchTile(
            title: 'Niveaux d\'affiliation',
            subtitle: 'Notifications sur vos changements de niveau',
            icon: Icons.emoji_events_outlined,
            value: _levelUpdates,
            onChanged: (value) => setState(() => _levelUpdates = value),
          ),
          _buildSwitchTile(
            title: 'Nouveaux filleuls',
            subtitle: 'Notifications quand quelqu\'un utilise votre code',
            icon: Icons.people_outlined,
            value: _referralUpdates,
            onChanged: (value) => setState(() => _referralUpdates = value),
          ),
        ],
      ),
    );
  }

  /// 🎛️ Switch tile personnalisé
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Map icon types to semantic colors for better visibility
    Color _getIconColor(IconData icon) {
      switch (icon) {
        case Icons.email_outlined:
          return AppColors.secondary;
        case Icons.notifications_outlined:
          return AppColors.warning;
        case Icons.sms_outlined:
          return AppColors.success;
        case Icons.shopping_bag_outlined:
          return AppColors.primary;
        case Icons.account_balance_wallet_outlined:
          return AppColors.success;
        case Icons.money_outlined:
          return AppColors.warning;
        case Icons.local_offer_outlined:
          return AppColors.secondary;
        case Icons.emoji_events_outlined:
          return AppColors.success;
        case Icons.people_outlined:
          return AppColors.primary;
        default:
          return AppColors.primary;
      }
    }

    final iconColor = _getIconColor(icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GlassContainer(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            color: iconColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: AppColors.gray400,
            inactiveTrackColor: AppColors.gray200,
          ),
        ],
      ),
    );
  }

  /// 💾 Bouton sauvegarder
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: PremiumButton(
          text: 'Sauvegarder les Préférences',
          icon: Icons.save,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _saveSettings,
        ),
      ),
    );
  }

  /// 💾 Sauvegarder les paramètres
  void _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Appeler l'API pour sauvegarder les préférences
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      NotificationManager().showSuccess(
        context,
        title: 'Préférences Sauvegardées',
        message: 'Vos paramètres de notification ont été mis à jour',
      );

      Navigator.pop(context);
    } catch (e) {
      NotificationManager().showError(
        context,
        title: 'Erreur de Sauvegarde',
        message: 'Impossible de sauvegarder vos préférences',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
