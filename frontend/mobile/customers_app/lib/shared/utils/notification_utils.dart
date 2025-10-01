import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';

/// 📲 Utilitaires de Notification Premium - Alpha Client App
///
/// Système unifié de notifications avec design glassmorphism
/// et animations sophistiquées selon les spécifications Alpha.
class NotificationUtils {
  
  /// ✅ Notification de succès
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
  }) {
    HapticFeedback.lightImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  /// ❌ Notification d'erreur
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    HapticFeedback.mediumImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  /// ℹ️ Notification d'information
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
  }) {
    HapticFeedback.selectionClick();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.info,
      duration: duration,
      onTap: onTap,
    );
  }

  /// ⚠️ Notification d'avertissement
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    HapticFeedback.mediumImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 📦 Notification de commande
  static void showOrder(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    HapticFeedback.lightImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.order,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 🎁 Notification de promotion
  static void showPromotion(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    HapticFeedback.lightImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.promotion,
      duration: duration,
      onTap: onTap,
    );
  }

  /// ⭐ Notification de fidélité
  static void showLoyalty(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    HapticFeedback.lightImpact();
    _showSnackBar(
      context,
      message: message,
      type: NotificationSnackBarType.loyalty,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 🎨 SnackBar premium unifié
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required NotificationSnackBarType type,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
  }) {
    // Fermer les SnackBars existants
    ScaffoldMessenger.of(context).clearSnackBars();

    final config = _getTypeConfig(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    config.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (config.title != null) ...[
                        Text(
                          config.title!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
        backgroundColor: config.color.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: duration,
        elevation: 0,
        padding: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: '',
          onPressed: () {},
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  /// 🎯 Configuration par type
  static _NotificationConfig _getTypeConfig(NotificationSnackBarType type) {
    switch (type) {
      case NotificationSnackBarType.success:
        return _NotificationConfig(
          color: AppColors.success,
          icon: Icons.check_circle,
          title: 'Succès',
        );
      case NotificationSnackBarType.error:
        return _NotificationConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
          title: 'Erreur',
        );
      case NotificationSnackBarType.warning:
        return _NotificationConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber,
          title: 'Attention',
        );
      case NotificationSnackBarType.info:
        return _NotificationConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
          title: null, // Pas de titre pour info
        );
      case NotificationSnackBarType.order:
        return _NotificationConfig(
          color: AppColors.primary,
          icon: Icons.shopping_bag_outlined,
          title: 'Commande',
        );
      case NotificationSnackBarType.promotion:
        return _NotificationConfig(
          color: AppColors.pink,
          icon: Icons.local_offer,
          title: 'Promotion',
        );
      case NotificationSnackBarType.loyalty:
        return _NotificationConfig(
          color: AppColors.warning,
          icon: Icons.stars,
          title: 'Fidélité',
        );
    }
  }

  /// 🔄 Notification avec action personnalisée
  static void showWithAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    NotificationSnackBarType type = NotificationSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    final config = _getTypeConfig(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          onPressed: onActionPressed,
        ),
      ),
    );
  }

  /// 📱 Notification de loading
  static void showLoading(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 30),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: duration,
      ),
    );
  }

  /// 🚫 Fermer toutes les notifications
  static void dismissAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// 🏷️ Types de SnackBar
enum NotificationSnackBarType {
  success,
  error,
  warning,
  info,
  order,
  promotion,
  loyalty,
}

/// ⚙️ Configuration de notification
class _NotificationConfig {
  final Color color;
  final IconData icon;
  final String? title;

  _NotificationConfig({
    required this.color,
    required this.icon,
    this.title,
  });
}