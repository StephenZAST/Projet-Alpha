import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import '../../controllers/notification_controller.dart';
import 'components/notification_tile.dart';
import 'components/notification_stats_grid.dart';
import 'components/notification_filters.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final controller = Get.find<NotificationController>();
  String selectedType = 'ALL';
  String selectedStatus = 'ALL';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('[NotificationsScreen] initState: Initialisation');
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    print('[NotificationsScreen] Chargement des notifications');
    try {
      await controller.fetchNotifications(refresh: true);
    } catch (e) {
      print('[NotificationsScreen] Erreur lors du chargement: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      filteredNotifications = notifications.where((notification) {
        final matchesType =
            selectedType == 'ALL' || notification['type'] == selectedType;
        final matchesStatus = selectedStatus == 'ALL' ||
            (selectedStatus == 'read' && notification['isRead']) ||
            (selectedStatus == 'unread' && !notification['isRead']);
        final matchesSearch = searchQuery.isEmpty ||
            notification['title']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            notification['message']
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        return matchesType && matchesStatus && matchesSearch;
      }).toList();

      // Trier par date (plus récent en premier)
      filteredNotifications.sort((a, b) =>
          (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['isRead'] = true;
        _applyFilters();
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
      _applyFilters();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n['id'] == id);
      _applyFilters();
    });
  }

  void _deleteAllRead() {
    setState(() {
      notifications.removeWhere((n) => n['isRead']);
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: Obx(() => _buildHeader(context, isDark)),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      Obx(() => _buildStatsGrid(context, isDark)),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres
                      _buildFilters(context, isDark),
                      SizedBox(height: AppSpacing.md),

                      // Liste des notifications avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.primary),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Chargement des notifications...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final filteredNotifications = _getFilteredNotifications();
                          
                          if (filteredNotifications.isEmpty) {
                            return _buildEmptyState(context, isDark);
                          }

                          return _buildNotificationsList(isDark, filteredNotifications);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    final notifications = controller.notifications.map((n) => {
      'id': n.id,
      'title': n.title,
      'message': n.message,
      'type': n.type.toString().split('.').last.toLowerCase(),
      'priority': n.priority.toString().split('.').last.toLowerCase(),
      'isRead': n.isRead,
      'createdAt': n.createdAt,
      'referenceId': n.referenceId,
    }).toList();

    final filtered = notifications.where((notification) {
      final matchesType = selectedType == 'ALL' || 
          notification['type'] == selectedType.toLowerCase();
      final matchesStatus = selectedStatus == 'ALL' ||
          (selectedStatus == 'read' && notification['isRead']) ||
          (selectedStatus == 'unread' && !notification['isRead']);
      final matchesSearch = searchQuery.isEmpty ||
          notification['title']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          notification['message']
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      return matchesType && matchesStatus && matchesSearch;
    }).toList();

    // Trier par date (plus récent en premier)
    filtered.sort((a, b) =>
        (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));

    return filtered;
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final totalCount = controller.notifications.length;
    final unreadCount = controller.unreadCount.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '$totalCount notification${totalCount > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
                if (unreadCount > 0) ...[
                  Text(' • ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.gray300
                            : AppColors.textSecondary,
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Text(
                      '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Row(
          children: [
            if (unreadCount > 0) ...[
              GlassButton(
                label: 'Tout marquer lu',
                icon: Icons.done_all_outlined,
                variant: GlassButtonVariant.success,
                onPressed: () => controller.markAllAsRead(),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: _loadNotifications,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    final notifications = controller.notifications;
    final totalCount = notifications.length;
    final unreadCount = controller.unreadCount.value;
    final highPriorityCount = notifications
        .where((n) => n.priority.toString().contains('HIGH') || 
                     n.priority.toString().contains('URGENT'))
        .length;
    final todayCount = notifications
        .where((n) => DateTime.now().difference(n.createdAt).inDays == 0)
        .length;

    return NotificationStatsGrid(
      totalNotifications: totalCount,
      unreadNotifications: unreadCount,
      highPriorityNotifications: highPriorityCount,
      todayNotifications: todayCount,
    );
  }

  Widget _buildFilters(BuildContext context, bool isDark) {
    return NotificationFilters(
      selectedType: selectedType,
      selectedStatus: selectedStatus,
      onTypeChanged: (type) {
        setState(() {
          selectedType = type;
        });
      },
      onStatusChanged: (status) {
        setState(() {
          selectedStatus = status;
        });
      },
      onSearchChanged: (query) {
        setState(() {
          searchQuery = query;
        });
      },
      onClearFilters: () {
        setState(() {
          selectedType = 'ALL';
          selectedStatus = 'ALL';
          searchQuery = '';
        });
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              searchQuery.isNotEmpty ||
                      selectedType != 'ALL' ||
                      selectedStatus != 'ALL'
                  ? Icons.search_off_outlined
                  : Icons.notifications_none_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            searchQuery.isNotEmpty ||
                    selectedType != 'ALL' ||
                    selectedStatus != 'ALL'
                ? 'Aucune notification trouvée'
                : 'Aucune notification',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            searchQuery.isNotEmpty ||
                    selectedType != 'ALL' ||
                    selectedStatus != 'ALL'
                ? 'Aucune notification ne correspond à vos critères de recherche'
                : 'Vous n\'avez aucune notification pour le moment',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty ||
              selectedType != 'ALL' ||
              selectedStatus != 'ALL') ...[
            SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                selectedType = 'ALL';
                selectedStatus = 'ALL';
                searchQuery = '';
                _applyFilters();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark, List<Map<String, dynamic>> filteredNotifications) {
    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDelete: () => _handleNotificationDelete(notification['id']),
          ),
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Marquer comme lu si pas encore lu
    if (!notification['isRead']) {
      final adminNotification = controller.notifications.firstWhere(
        (n) => n.id == notification['id'],
        orElse: () => controller.notifications.first,
      );
      controller.markAsRead(adminNotification);
    }

    // Gérer l'action de navigation
    controller.handleNotificationAction(
      controller.notifications.firstWhere((n) => n.id == notification['id']),
    );
  }

  void _handleNotificationDelete(String id) {
    // TODO: Implémenter la suppression via le contrôleur
    // Pour l'instant, on peut juste rafraîchir la liste
    _loadNotifications();
  }

  void _showDeleteAllReadDialog() {
    final readCount = notifications.where((n) => n['isRead']).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text('Supprimer les notifications lues', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir supprimer les $readCount notification${readCount > 1 ? 's' : ''} lue${readCount > 1 ? 's' : ''} ?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Supprimer',
                      variant: GlassButtonVariant.warning,
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAllRead();
                      },
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
