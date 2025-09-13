import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRead = notification['isRead'] ?? false;
    final String type = notification['type'] ?? 'system';
    final String priority = notification['priority'] ?? 'medium';
    final DateTime createdAt = notification['createdAt'] ?? DateTime.now();

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: Column(
          children: [
            // Header avec icône, titre et actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône avec indicateur de priorité
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.15),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                        size: 24,
                      ),
                    ),
                    if (priority == 'high')
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? AppColors.gray800 : AppColors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(width: AppSpacing.md),
                
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? 'Notification',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                color: isRead
                                    ? (isDark ? AppColors.gray300 : AppColors.textSecondary)
                                    : (isDark ? AppColors.textLight : AppColors.textPrimary),
                              ),
                            ),
                          ),
                          // Badge de priorité
                          if (priority == 'high')
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: AppRadius.radiusXS,
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'URGENT',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: AppSpacing.xs),
                      
                      Text(
                        notification['message'] ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Indicateur non lu
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Footer avec métadonnées et actions
            Row(
              children: [
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                    border: Border.all(
                      color: _getTypeColor(type).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 12,
                        color: _getTypeColor(type),
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getTypeLabel(type),
                        style: AppTextStyles.caption.copyWith(
                          color: _getTypeColor(type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: AppSpacing.sm),
                
                // Date
                Text(
                  _formatDate(createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                
                Spacer(),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isRead)
                      GlassButton(
                        label: '',
                        icon: Icons.mark_email_read_outlined,
                        variant: GlassButtonVariant.success,
                        size: GlassButtonSize.small,
                        onPressed: onTap,
                        tooltip: 'Marquer comme lu',
                      ),
                    SizedBox(width: AppSpacing.xs),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'details':
                            _showNotificationDetails(context);
                            break;
                          case 'delete':
                            if (onDelete != null) onDelete!();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'details',
                          child: ListTile(
                            leading: Icon(Icons.info_outline, size: 18),
                            title: Text('Voir les détails'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            title: Text('Supprimer',
                                style: TextStyle(color: AppColors.error)),
                            dense: true,
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? AppColors.gray300 : AppColors.gray600,
                        size: 18,
                      ),
                      color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'payment':
        return AppColors.success;
      case 'delivery':
        return AppColors.info;
      case 'user':
        return AppColors.violet;
      case 'support':
        return AppColors.warning;
      case 'system':
        return AppColors.gray500;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'user':
        return Icons.person_outline;
      case 'support':
        return Icons.support_agent_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'order':
        return 'Commande';
      case 'payment':
        return 'Paiement';
      case 'delivery':
        return 'Livraison';
      case 'user':
        return 'Utilisateur';
      case 'support':
        return 'Support';
      case 'system':
        return 'Système';
      default:
        return 'Notification';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNotificationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 500,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTypeIcon(notification['type'] ?? 'system'),
                      color: _getTypeColor(notification['type'] ?? 'system')),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Détails de la notification',
                      style: AppTextStyles.h4,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              
              Text(
                'Titre:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                notification['title'] ?? 'Sans titre',
                style: AppTextStyles.bodyMedium,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              Text(
                'Message:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                notification['message'] ?? 'Aucun message',
                style: AppTextStyles.bodyMedium,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getTypeLabel(notification['type'] ?? 'system'),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priorité:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          notification['priority'] ?? 'Moyenne',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.md),
              
              Text(
                'Date:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(notification['createdAt'] ?? DateTime.now()),
                style: AppTextStyles.bodySmall,
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Fermer',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}