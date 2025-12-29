import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../shared/providers/notification_provider.dart';

/// 🔔 Helper pour le Badge de Notifications
/// Réutilisable dans tous les AppBars
class NotificationBadgeHelper {
  /// Construire le widget du badge de notifications
  static Widget buildNotificationBadge(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              _buildGlassIconButton(
                context: context,
                icon: Icons.notifications_none_rounded,
                onPressed: () => _navigateToNotifications(context),
                tooltip: 'Notifications',
              ),
              // Badge élégant
              if (notificationProvider.hasUnreadNotifications)
                Positioned(
                  right: 4,
                  top: 4,
                  child: _buildBadgeCounter(
                    context,
                    notificationProvider.unreadCount,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Construire le compteur du badge
  static Widget _buildBadgeCounter(BuildContext context, int count) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: AppTextStyles.overline.copyWith(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Naviguer vers l'écran de notifications
  static void _navigateToNotifications(BuildContext context) {
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
  }

  /// Construire le bouton icône glassmorphism
  static Widget _buildGlassIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary(context),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
