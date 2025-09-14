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
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  bool isLoading = true;
  String selectedType = 'ALL';
  String selectedStatus = 'ALL';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      // Essayer de charger depuis le contrôleur
      await controller.fetchNotifications();
      if (controller.notifications.isNotEmpty) {
        notifications = controller.notifications
            .map((n) => {
                  'id': n.id,
                  'title': n.title,
                  'message': n.message,
                  'type': n.type,
                  'priority': n.priority,
                  'isRead': n.isRead,
                  'createdAt': n.createdAt,
                })
            .toList();
      } else {
        // Données de démonstration
        notifications = [
          {
            'id': '1',
            'title': 'Nouvelle commande reçue',
            'message':
                'Une nouvelle commande a été passée par Jean Dupont pour un montant de 25,000 FCFA',
            'type': 'order',
            'priority': 'high',
            'isRead': false,
            'createdAt': DateTime.now().subtract(Duration(minutes: 5)),
            'userId': 'user123',
            'orderId': 'order456',
          },
          {
            'id': '2',
            'title': 'Paiement confirmé',
            'message':
                'Paiement de 15,000 FCFA reçu pour la commande #12345 via Mobile Money',
            'type': 'payment',
            'priority': 'medium',
            'isRead': false,
            'createdAt': DateTime.now().subtract(Duration(hours: 1)),
            'orderId': 'order12345',
          },
          {
            'id': '3',
            'title': 'Nouvel utilisateur inscrit',
            'message':
                'Marie Martin s\'est inscrite sur la plateforme et a complété son profil',
            'type': 'user',
            'priority': 'low',
            'isRead': true,
            'createdAt': DateTime.now().subtract(Duration(hours: 2)),
            'userId': 'user789',
          },
          {
            'id': '4',
            'title': 'Commande livrée avec succès',
            'message':
                'La commande #12344 a été livrée avec succès à l\'adresse indiquée',
            'type': 'delivery',
            'priority': 'medium',
            'isRead': true,
            'createdAt': DateTime.now().subtract(Duration(days: 1)),
            'orderId': 'order12344',
          },
          {
            'id': '5',
            'title': 'Problème de livraison',
            'message':
                'Échec de livraison pour la commande #12346. Client non disponible.',
            'type': 'delivery',
            'priority': 'high',
            'isRead': false,
            'createdAt': DateTime.now().subtract(Duration(hours: 3)),
            'orderId': 'order12346',
          },
          {
            'id': '6',
            'title': 'Nouveau message support',
            'message':
                'Un client a envoyé un message concernant sa commande en cours',
            'type': 'support',
            'priority': 'medium',
            'isRead': false,
            'createdAt': DateTime.now().subtract(Duration(hours: 4)),
            'userId': 'user456',
          },
          {
            'id': '7',
            'title': 'Maintenance système',
            'message':
                'Maintenance programmée du système prévue demain de 2h à 4h du matin',
            'type': 'system',
            'priority': 'low',
            'isRead': true,
            'createdAt': DateTime.now().subtract(Duration(days: 2)),
          },
        ];
      }
      _applyFilters();
    } catch (e) {
      // En cas d'erreur, utiliser les données de démonstration
      notifications = [
        {
          'id': '1',
          'title': 'Nouvelle commande reçue',
          'message': 'Une nouvelle commande a été passée par Jean Dupont',
          'type': 'order',
          'priority': 'high',
          'isRead': false,
          'createdAt': DateTime.now().subtract(Duration(minutes: 5)),
        },
      ];
      _applyFilters();
    } finally {
      setState(() => isLoading = false);
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
    final unreadCount = notifications.where((n) => !n['isRead']).length;
    final totalCount = notifications.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark, unreadCount, totalCount),
              SizedBox(height: AppSpacing.lg),

              // Statistiques
              NotificationStatsGrid(
                totalNotifications: totalCount,
                unreadNotifications: unreadCount,
                highPriorityNotifications:
                    notifications.where((n) => n['priority'] == 'high').length,
                todayNotifications: notifications
                    .where((n) =>
                        DateTime.now()
                            .difference(n['createdAt'] as DateTime)
                            .inDays ==
                        0)
                    .length,
              ),
              SizedBox(height: AppSpacing.lg),

              // Filtres
              NotificationFilters(
                selectedType: selectedType,
                selectedStatus: selectedStatus,
                onTypeChanged: (type) {
                  selectedType = type;
                  _applyFilters();
                },
                onStatusChanged: (status) {
                  selectedStatus = status;
                  _applyFilters();
                },
                onSearchChanged: (query) {
                  searchQuery = query;
                  _applyFilters();
                },
                onClearFilters: () {
                  selectedType = 'ALL';
                  selectedStatus = 'ALL';
                  searchQuery = '';
                  _applyFilters();
                },
              ),
              SizedBox(height: AppSpacing.md),

              // Liste des notifications
              Expanded(
                child: isLoading
                    ? Center(
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
                      )
                    : filteredNotifications.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : _buildNotificationsList(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, int unreadCount, int totalCount) {
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
                  '$totalCount notification${totalCount > 1 ? 's' : ''}',
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
                onPressed: _markAllAsRead,
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            if (notifications.where((n) => n['isRead']).isNotEmpty) ...[
              GlassButton(
                label: 'Supprimer lues',
                icon: Icons.delete_sweep_outlined,
                variant: GlassButtonVariant.warning,
                onPressed: () => _showDeleteAllReadDialog(),
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

  Widget _buildNotificationsList(bool isDark) {
    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: NotificationTile(
            notification: notification,
            onTap: () => _markAsRead(notification['id']),
            onDelete: () => _deleteNotification(notification['id']),
          ),
        );
      },
    );
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
