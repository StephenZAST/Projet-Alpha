import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';
import '../../models/user_subscription.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import '../../services/api_service.dart';
import 'package:get/get.dart';

class SubscribedUsersTab extends StatefulWidget {
  const SubscribedUsersTab({Key? key}) : super(key: key);

  @override
  State<SubscribedUsersTab> createState() => _SubscribedUsersTabState();
}

class _SubscribedUsersTabState extends State<SubscribedUsersTab> {
  List<UserSubscription> subscriptions = [];
  List<UserSubscription> filteredSubscriptions = [];
  bool isLoading = false;
  final api = Get.find<ApiService>();
  String statusFilter = 'ALL';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/admin/subscriptions');
      final data = response.data is List ? response.data : response.data['data'];
      subscriptions = (data as List)
          .map((json) => UserSubscription.fromJson(json))
          .toList();
      _applyFilters();
    } catch (e) {
      // Données de démonstration en cas d'erreur
      subscriptions = [
        UserSubscription(
          id: '1',
          userId: 'jean.dupont@example.com',
          userName: 'Jean Dupont',
          planId: 'plan-premium',
          startDate: DateTime.now().subtract(Duration(days: 15)),
          endDate: DateTime.now().add(Duration(days: 15)),
          status: 'ACTIVE',
          remainingOrders: 12,
          remainingWeight: 18.5,
        ),
        UserSubscription(
          id: '2',
          userId: 'marie.martin@example.com',
          userName: 'Marie Martin',
          planId: 'plan-basique',
          startDate: DateTime.now().subtract(Duration(days: 5)),
          endDate: DateTime.now().add(Duration(days: 25)),
          status: 'ACTIVE',
          remainingOrders: 4,
          remainingWeight: 8.0,
        ),
        UserSubscription(
          id: '3',
          userId: 'pierre.durand@example.com',
          userName: 'Pierre Durand',
          planId: 'plan-entreprise',
          startDate: DateTime.now().subtract(Duration(days: 45)),
          endDate: DateTime.now().subtract(Duration(days: 5)),
          status: 'EXPIRED',
          remainingOrders: 0,
          remainingWeight: 0.0,
        ),
        UserSubscription(
          id: '4',
          userId: 'sophie.bernard@example.com',
          userName: 'Sophie Bernard',
          planId: 'plan-premium',
          startDate: DateTime.now().subtract(Duration(days: 10)),
          endDate: DateTime.now().add(Duration(days: 20)),
          status: 'CANCELLED',
          remainingOrders: 8,
          remainingWeight: 12.0,
        ),
      ];
      _applyFilters();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredSubscriptions = subscriptions.where((sub) {
        final matchesStatus = statusFilter == 'ALL' || sub.status == statusFilter;
        final matchesSearch = searchQuery.isEmpty ||
            (sub.userName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (sub.userId.toLowerCase().contains(searchQuery.toLowerCase()));
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header avec filtres
        _buildFiltersSection(isDark),
        SizedBox(height: AppSpacing.lg),

        // Liste des abonnements
        Expanded(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Chargement des abonnements...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredSubscriptions.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildSubscriptionsList(isDark),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilisateurs abonnés',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${filteredSubscriptions.length} abonnement${filteredSubscriptions.length > 1 ? 's' : ''} trouvé${filteredSubscriptions.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GlassButton(
                    label: 'Exporter',
                    icon: Icons.download_outlined,
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => _showExportDialog(),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  GlassButton(
                    label: 'Actualiser',
                    icon: Icons.refresh_outlined,
                    variant: GlassButtonVariant.primary,
                    size: GlassButtonSize.small,
                    onPressed: _fetchSubscriptions,
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Filtres
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Recherche par nom ou email',
                    prefixIcon: Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.gray800.withOpacity(0.5)
                        : AppColors.white.withOpacity(0.7),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.gray800.withOpacity(0.5)
                        : AppColors.white.withOpacity(0.7),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text('Tous les statuts')),
                      DropdownMenuItem(
                        value: 'ACTIVE',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: AppColors.success),
                            SizedBox(width: AppSpacing.xs),
                            Text('Actifs'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'CANCELLED',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 16, color: AppColors.warning),
                            SizedBox(width: AppSpacing.xs),
                            Text('Annulés'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'EXPIRED',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: AppColors.error),
                            SizedBox(width: AppSpacing.xs),
                            Text('Expirés'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      statusFilter = value ?? 'ALL';
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
              Icons.people_outline,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun abonnement trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            searchQuery.isNotEmpty || statusFilter != 'ALL'
                ? 'Aucun abonnement ne correspond à vos critères de recherche'
                : 'Aucun utilisateur n\'est encore abonné',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty || statusFilter != 'ALL') ...[
            SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                searchQuery = '';
                statusFilter = 'ALL';
                _applyFilters();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(bool isDark) {
    return ListView.builder(
      itemCount: filteredSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = filteredSubscriptions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildSubscriptionCard(subscription, isDark),
        );
      },
    );
  }

  Widget _buildSubscriptionCard(UserSubscription subscription, bool isDark) {
    final Color statusColor = _getStatusColor(subscription.status);
    final IconData statusIcon = _getStatusIcon(subscription.status);
    final bool isActive = subscription.status == 'ACTIVE';
    final bool isExpiringSoon = isActive && 
        subscription.endDate.difference(DateTime.now()).inDays <= 7;

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Header avec avatar et statut
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  (subscription.userName ?? subscription.userId).substring(0, 1).toUpperCase(),
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.userName ?? 'Utilisateur',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subscription.userId,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: AppRadius.radiusSM,
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      _getStatusLabel(subscription.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Informations de l'abonnement
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Plan',
                  subscription.planId,
                  Icons.subscriptions_outlined,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Commandes restantes',
                  '${subscription.remainingOrders}',
                  Icons.shopping_cart_outlined,
                  AppColors.success,
                ),
              ),
              if (subscription.remainingWeight != null)
                Expanded(
                  child: _buildInfoItem(
                    'Poids restant',
                    '${subscription.remainingWeight!.toStringAsFixed(1)} kg',
                    Icons.scale_outlined,
                    AppColors.info,
                  ),
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Dates
          Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  'Début',
                  subscription.startDate,
                  Icons.play_circle_outline,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildDateInfo(
                  'Fin',
                  subscription.endDate,
                  Icons.stop_circle_outlined,
                  isExpiringSoon ? AppColors.warning : AppColors.error,
                ),
              ),
            ],
          ),

          if (isExpiringSoon) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, 
                       size: 16, color: AppColors.warning),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Expire dans ${subscription.endDate.difference(DateTime.now()).inDays} jour(s)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Détails',
                  icon: Icons.info_outline,
                  variant: GlassButtonVariant.info,
                  size: GlassButtonSize.small,
                  onPressed: () => _showSubscriptionDetails(subscription),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              if (isActive) ...[
                Expanded(
                  child: GlassButton(
                    label: 'Renouveler',
                    icon: Icons.refresh_outlined,
                    variant: GlassButtonVariant.success,
                    size: GlassButtonSize.small,
                    onPressed: () => _renewSubscription(subscription),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GlassButton(
                    label: 'Annuler',
                    icon: Icons.cancel_outlined,
                    variant: GlassButtonVariant.warning,
                    size: GlassButtonSize.small,
                    onPressed: () => _cancelSubscription(subscription),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: GlassButton(
                    label: 'Réactiver',
                    icon: Icons.play_arrow_outlined,
                    variant: GlassButtonVariant.success,
                    size: GlassButtonSize.small,
                    onPressed: () => _reactivateSubscription(subscription),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textLight
                : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray300
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: AppSpacing.xs),
        Text(
          date.toLocal().toString().split(' ')[0],
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textLight
                : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray300
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.warning;
      case 'EXPIRED':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      case 'EXPIRED':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Actif';
      case 'CANCELLED':
        return 'Annulé';
      case 'EXPIRED':
        return 'Expiré';
      default:
        return 'Inconnu';
    }
  }

  void _showSubscriptionDetails(UserSubscription subscription) {
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
            children: [
              Text(
                'Détails de l\'abonnement',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              // TODO: Afficher plus de détails
              Text('Détails complets en cours de développement'),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _renewSubscription(UserSubscription subscription) {
    // TODO: Implémenter le renouvellement
    Get.snackbar('Info', 'Fonctionnalité de renouvellement en cours de développement');
  }

  void _cancelSubscription(UserSubscription subscription) {
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
              Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text('Confirmer l\'annulation', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir annuler l\'abonnement de ${subscription.userName ?? subscription.userId} ?',
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
                      label: 'Confirmer',
                      variant: GlassButtonVariant.warning,
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implémenter l'annulation
                        Get.snackbar('Succès', 'Abonnement annulé');
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

  void _reactivateSubscription(UserSubscription subscription) {
    // TODO: Implémenter la réactivation
    Get.snackbar('Info', 'Fonctionnalité de réactivation en cours de développement');
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 48, color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Exporter les abonnements', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Fonctionnalité d\'export en cours de développement',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}