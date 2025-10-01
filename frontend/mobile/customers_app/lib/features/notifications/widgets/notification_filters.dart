import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../core/models/notification.dart';

/// 🔍 Filtres de Notifications - Alpha Client App
///
/// Bottom sheet pour filtrer les notifications par type et statut
/// avec design premium glassmorphism.
class NotificationFilters extends StatefulWidget {
  const NotificationFilters({Key? key}) : super(key: key);

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends State<NotificationFilters> {
  NotificationType? _selectedType;
  bool? _showOnlyUnread;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    _selectedType = provider.selectedType;
    _showOnlyUnread = provider.showOnlyUnread;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildFilters(),
            _buildActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 🎯 Handle du bottom sheet
  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textTertiary(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 📋 En-tête
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtrer les notifications',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Réinitialiser',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Filtres
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Filtre par statut
          Text(
            'Statut',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatusFilter(
                  'Toutes',
                  null,
                  Icons.notifications_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusFilter(
                  'Non lues',
                  true,
                  Icons.mark_email_unread_outlined,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Filtre par type
          Text(
            'Type de notification',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildTypeFilters(),
        ],
      ),
    );
  }

  /// 📊 Filtre de statut
  Widget _buildStatusFilter(String label, bool? value, IconData icon) {
    final isSelected = _showOnlyUnread == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOnlyUnread = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.border(context),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.textSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textSecondary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Filtres par type
  Widget _buildTypeFilters() {
    return Column(
      children: [
        // Option "Tous les types"
        _buildTypeFilter(
          'Tous les types',
          null,
          Icons.all_inclusive,
          AppColors.textSecondary(context),
        ),
        
        const SizedBox(height: 8),
        
        // Types spécifiques
        ...NotificationType.values.map((type) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTypeFilter(
            type.displayName,
            type,
            _getTypeIcon(type),
            _getTypeColor(type),
          ),
        )),
      ],
    );
  }

  Widget _buildTypeFilter(String label, NotificationType? type, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.1)
              : AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color 
                : AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary(context),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected 
                    ? color 
                    : AppColors.textPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Actions
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
              text: 'Appliquer',
              onPressed: _applyFilters,
              icon: Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔄 Réinitialiser les filtres
  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _showOnlyUnread = null;
    });
  }

  /// ✅ Appliquer les filtres
  void _applyFilters() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.applyFilters(
      type: _selectedType,
      showOnlyUnread: _showOnlyUnread,
    );
    Navigator.of(context).pop();
  }

  /// 🎯 Icône par type
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.loyalty:
        return Icons.stars;
    }
  }

  /// 🎨 Couleur par type
  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
      case NotificationType.order:
        return AppColors.primary;
      case NotificationType.promotion:
        return AppColors.pink;
      case NotificationType.loyalty:
        return AppColors.warning;
    }
  }
}