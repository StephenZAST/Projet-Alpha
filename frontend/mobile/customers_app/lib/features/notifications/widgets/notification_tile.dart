import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/notification.dart';

/// 📲 Tuile de Notification - Alpha Client App
///
/// Widget pour afficher une notification individuelle avec actions
/// et design premium glassmorphism.
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: notification.isRead 
                    ? null 
                    : Border.all(
                        color: notification.color.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContent(context),
                  ),
                  const SizedBox(width: 8),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Icône de notification
  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: notification.color.withOpacity(notification.isRead ? 0.1 : 0.15),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead 
            ? null 
            : Border.all(
                color: notification.color.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Icon(
        notification.icon,
        color: notification.color,
        size: 22,
      ),
    );
  }

  /// 📝 Contenu de la notification
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et temps
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification.timeAgo,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Message
        Text(
          notification.message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: notification.isRead 
                ? AppColors.textSecondary(context)
                : AppColors.textPrimary(context),
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Footer avec type et priorité
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notification.type.displayName,
                style: AppTextStyles.labelSmall.copyWith(
                  color: notification.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            
            if (notification.priority != NotificationPriority.normal) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: notification.priority.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      notification.priority == NotificationPriority.urgent
                          ? Icons.priority_high
                          : Icons.flag,
                      color: notification.priority.color,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      notification.priority.displayName,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: notification.priority.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Spacer(),
            
            // Indicateur non lu
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: notification.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 🎯 Actions de la notification
  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textTertiary(context),
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface(context),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'mark_read':
            onMarkAsRead?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          PopupMenuItem<String>(
            value: 'mark_read',
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read,
                  color: AppColors.textSecondary(context),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Marquer comme lu',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        
        if (notification.canBeDeleted)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Supprimer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 📲 Tuile de Notification Compacte
class CompactNotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const CompactNotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 16,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary(context),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!notification.isRead)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: notification.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
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