import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../shared/utils/notification_utils.dart';
import '../../../core/models/notification.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_filters.dart';

/// 📲 Écran des Notifications - Alpha Client App
///
/// Centre de notifications premium avec filtres, actions groupées
/// et design glassmorphism sophistiqué.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initScrollController();
    _initializeNotifications();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.slideIn,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.initialize();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      if (!provider.isLoadingMore && provider.hasMoreNotifications) {
        provider.loadNotifications();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  /// 📱 AppBar Premium
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Notifications',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.hasUnreadNotifications) {
              return IconButton(
                icon: Icon(
                  Icons.done_all,
                  color: AppColors.primary,
                ),
                onPressed: () => _markAllAsRead(provider),
                tooltip: 'Tout marquer comme lu',
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: AppColors.textPrimary(context),
          ),
          onPressed: _showFilters,
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        if (provider.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildStatsHeader(provider),
              Expanded(
                child: _buildNotificationsList(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📊 En-tête avec statistiques
  Widget _buildStatsHeader(NotificationProvider provider) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total',
                '${provider.notifications.length}',
                Icons.notifications_outlined,
                AppColors.primary,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.border(context),
            ),
            Expanded(
              child: _buildStatItem(
                'Non lues',
                '${provider.unreadCount}',
                Icons.mark_email_unread_outlined,
                AppColors.warning,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.border(context),
            ),
            Expanded(
              child: _buildStatItem(
                'Aujourd\'hui',
                '${provider.todayNotifications.length}',
                Icons.today_outlined,
                AppColors.info,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 📋 Liste des notifications
  Widget _buildNotificationsList(NotificationProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: provider.notifications.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.notifications.length) {
          return _buildLoadingMoreIndicator();
        }

        final notification = provider.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification, provider),
          onMarkAsRead: () => _markAsRead(notification.id, provider),
          onDelete: () => _deleteNotification(notification.id, provider),
        );
      },
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des notifications...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: () {
                final provider = Provider.of<NotificationProvider>(context, listen: false);
                provider.refresh();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 60,
                color: AppColors.textTertiary(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucune notification',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore de notifications.\nElles apparaîtront ici dès que vous en recevrez.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ⏳ Indicateur de chargement supplémentaire
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  /// 🎯 Gestionnaires d'événements

  /// Tap sur une notification
  void _handleNotificationTap(AppNotification notification, NotificationProvider provider) {
    if (!notification.isRead) {
      _markAsRead(notification.id, provider);
    }
    
    // TODO: Navigation selon le type de notification
    NotificationUtils.showInfo(
      context,
      'Navigation vers ${notification.type.displayName}',
    );
  }

  /// Marquer comme lu
  void _markAsRead(String notificationId, NotificationProvider provider) async {
    final success = await provider.markAsRead(notificationId);
    if (success && mounted) {
      NotificationUtils.showSuccess(context, 'Notification marquée comme lue');
    }
  }

  /// Marquer tout comme lu
  void _markAllAsRead(NotificationProvider provider) async {
    final success = await provider.markAllAsRead();
    if (success && mounted) {
      NotificationUtils.showSuccess(context, 'Toutes les notifications marquées comme lues');
    }
  }

  /// Supprimer une notification
  void _deleteNotification(String notificationId, NotificationProvider provider) async {
    final success = await provider.deleteNotification(notificationId);
    if (success && mounted) {
      NotificationUtils.showSuccess(context, 'Notification supprimée');
    }
  }

  /// Afficher les filtres
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFilters(),
    );
  }
}