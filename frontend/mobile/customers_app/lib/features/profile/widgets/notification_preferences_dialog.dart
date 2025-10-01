import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/models/user.dart' as model;
import '../widgets/profile_menu_section.dart';

/// 🔔 Dialog des Préférences de Notification - Alpha Client App
///
/// Dialog premium pour configurer les préférences de notification
/// avec switches et design glassmorphism.
class NotificationPreferencesDialog extends StatefulWidget {
  const NotificationPreferencesDialog({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesDialog> createState() =>
      _NotificationPreferencesDialogState();
}

class _NotificationPreferencesDialogState
    extends State<NotificationPreferencesDialog> {
  late model.NotificationPreferences _preferences;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  void _initializePreferences() {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    // Map existing provider preferences (model) or provide sensible defaults
    _preferences = provider.notificationPreferences ??
        model.NotificationPreferences(
          orderUpdates: true,
          promotions: true,
          newsletter: false,
          sms: true,
          push: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildPreferences(),
                ),
              ),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 En-tête du dialog
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.info,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Préférences de notification',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Choisissez comment vous souhaitez être notifié',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 🔔 Préférences de notification
  Widget _buildPreferences() {
    return Column(
      children: [
        // Canaux de notification
        _buildPreferenceSection(
          'Canaux de notification',
          [
            _buildPreferenceItem(
              'Notifications push',
              'Notifications sur votre appareil',
              Icons.phone_android,
              _preferences.push,
              (value) =>
                  _updatePreference((prefs) => prefs.copyWith(push: value)),
            ),
            _buildPreferenceItem(
              'Notifications email',
              'Notifications par email',
              Icons.email_outlined,
              _preferences.newsletter,
              (value) => _updatePreference(
                  (prefs) => prefs.copyWith(newsletter: value)),
            ),
            _buildPreferenceItem(
              'Notifications SMS',
              'Notifications par SMS',
              Icons.sms_outlined,
              _preferences.sms,
              (value) =>
                  _updatePreference((prefs) => prefs.copyWith(sms: value)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Types de notification
        _buildPreferenceSection(
          'Types de notification',
          [
            _buildPreferenceItem(
              'Mises à jour de commande',
              'Statut, livraison, prêt à récupérer',
              Icons.shopping_bag_outlined,
              _preferences.orderUpdates,
              (value) => _updatePreference(
                  (prefs) => prefs.copyWith(orderUpdates: value)),
            ),
            _buildPreferenceItem(
              'Offres promotionnelles',
              'Réductions, offres spéciales',
              Icons.local_offer_outlined,
              _preferences.promotions,
              (value) => _updatePreference(
                  (prefs) => prefs.copyWith(promotions: value)),
            ),
            _buildPreferenceItem(
              'Programme de fidélité',
              'Points, récompenses, niveau',
              Icons.stars_outlined,
              _preferences.loyaltyUpdates,
              (value) => _updatePreference(
                  (prefs) => prefs.copyWith(loyaltyUpdates: value)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Note informative
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Les notifications de commande sont recommandées pour suivre vos commandes.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📋 Section de préférences
  Widget _buildPreferenceSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppColors.border(context),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 🔔 Élément de préférence
  Widget _buildPreferenceItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  value ? AppColors.primary : AppColors.textSecondary(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
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
          ProfileMenuSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// 🎯 Actions du dialog
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Sauvegarder',
            onPressed: (_isLoading || !_hasChanges) ? null : _handleSave,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
        ),
      ],
    );
  }

  /// 🔄 Mettre à jour une préférence
  void _updatePreference(
      model.NotificationPreferences Function(model.NotificationPreferences)
          updater) {
    setState(() {
      _preferences = updater(_preferences);
      _hasChanges = true;
    });
  }

  /// 💾 Gestionnaire de sauvegarde
  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      final success =
          await provider.updateNotificationPreferences(_preferences);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Préférences mises à jour avec succès');
      } else if (provider.error != null && mounted) {
        _showErrorSnackBar(provider.error!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sauvegarde');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ✅ Afficher SnackBar de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ❌ Afficher SnackBar d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
