import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/orders_provider.dart';
import '../../components/glass_components.dart';
import '../../core/models/order.dart';
import 'order_details_screen.dart';

/// 📦 Écran Historique Commandes - Alpha Client App
///
/// Liste complète des commandes avec filtres, recherche et pagination

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrdersProvider>().loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Mes Commandes',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        actions: [
          IconButton(
            onPressed: () => _showFiltersDialog(context),
            icon: Icon(
              Icons.filter_list,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary,
          onTap: (index) => _onTabChanged(index),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(null),
                _buildOrdersList(_getActiveStatuses()),
                _buildOrdersList([OrderStatus.delivered]),
                _buildOrdersList([OrderStatus.cancelled]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Barre de recherche
  Widget _buildSearchBar() {
    return Container(
      padding: AppSpacing.pagePadding,
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher par ID ou contenu...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary(context),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary(context),
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface(context),
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMD,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  /// 📊 En-tête avec statistiques
  Widget _buildStatsHeader() {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        final stats = provider.ordersStats;

        return Container(
          padding: AppSpacing.pagePadding,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${stats['totalOrders']}',
                  Icons.shopping_bag,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En cours',
                  '${stats['activeOrders']}',
                  Icons.pending,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Livrées',
                  '${stats['completedOrders']}',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Liste des commandes
  Widget _buildOrdersList(List<OrderStatus>? statusFilter) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        List<Order> orders;

        if (statusFilter == null) {
          orders = provider.orders;
        } else {
          orders = provider.orders
              .where((order) => statusFilter.contains(order.status))
              .toList();
        }

        if (provider.isLoadingOrders && orders.isEmpty) {
          return _buildLoadingList();
        }

        if (orders.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount: orders.length + (provider.hasMoreOrders ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                return _buildLoadingIndicator();
              }

              final order = orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  /// 📦 Carte de commande
  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        onTap: () => _navigateToOrderDetails(order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec ID et statut
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${order.shortId}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: order.statusText,
                  color: order.statusColor,
                  icon: _getStatusIcon(order.status),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Articles
            if (order.items.isNotEmpty) ...[
              Text(
                '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.items
                        .take(2)
                        .map((item) => '${item.quantity}x ${item.articleName}')
                        .join(', ') +
                    (order.items.length > 2 ? '...' : ''),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Pied avec montant et action
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toFormattedString()} FCFA',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions selon le statut
                if (order.canBeCancelled) ...[
                  TextButton(
                    onPressed: () => _showCancelDialog(order),
                    child: Text(
                      'Annuler',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textTertiary(context),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 Indicateur de chargement
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  /// 💀 Liste de chargement skeleton
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 120, height: 16),
                          const SizedBox(height: 4),
                          const SkeletonLoader(width: 80, height: 12),
                        ],
                      ),
                    ),
                    const SkeletonLoader(width: 60, height: 24),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonLoader(width: 100, height: 12),
                const SizedBox(height: 4),
                const SkeletonLoader(width: double.infinity, height: 16),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 40, height: 12),
                          const SizedBox(height: 4),
                          const SkeletonLoader(width: 100, height: 16),
                        ],
                      ),
                    ),
                    const SkeletonLoader(width: 16, height: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(List<OrderStatus>? statusFilter) {
    String title;
    String subtitle;
    IconData icon;

    if (statusFilter == null) {
      title = 'Aucune commande';
      subtitle = 'Vous n\'avez pas encore passé de commande';
      icon = Icons.shopping_bag_outlined;
    } else if (statusFilter.contains(OrderStatus.delivered)) {
      title = 'Aucune commande livrée';
      subtitle = 'Vos commandes livrées apparaîtront ici';
      icon = Icons.check_circle_outline;
    } else if (statusFilter.contains(OrderStatus.cancelled)) {
      title = 'Aucune commande annulée';
      subtitle = 'Vos commandes annulées apparaîtront ici';
      icon = Icons.cancel_outlined;
    } else {
      title = 'Aucune commande en cours';
      subtitle = 'Vos commandes en cours apparaîtront ici';
      icon = Icons.pending_outlined;
    }

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (statusFilter == null) ...[
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Passer une commande',
                icon: Icons.add_shopping_cart,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Actions et utilitaires
  void _onTabChanged(int index) {
    final provider = context.read<OrdersProvider>();

    switch (index) {
      case 0: // Toutes
        provider.applyFilters();
        break;
      case 1: // En cours
        provider.applyFilters(status: null); // Sera filtré dans la vue
        break;
      case 2: // Livrées
        provider.applyFilters(status: OrderStatus.delivered);
        break;
      case 3: // Annulées
        provider.applyFilters(status: OrderStatus.cancelled);
        break;
    }
  }

  void _onSearchChanged(String query) {
    final provider = context.read<OrdersProvider>();
    provider.applyFilters(query: query.isNotEmpty ? query : null);
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersBottomSheet(),
    );
  }

  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        title: Text(
          'Annuler la commande',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler cette commande ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Oui, annuler',
            backgroundColor: AppColors.error,
            onPressed: () => _cancelOrder(order),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(Order order) async {
    Navigator.pop(context); // Fermer le dialog

    final provider = context.read<OrdersProvider>();
    final success = await provider.cancelOrder(order.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'annulation'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Utilitaires
  List<OrderStatus> _getActiveStatuses() {
    return [
      OrderStatus.draft,
      OrderStatus.pending,
      OrderStatus.collecting,
      OrderStatus.collected,
      OrderStatus.processing,
      OrderStatus.ready,
      OrderStatus.delivering,
    ];
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit;
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.collecting:
        return Icons.local_shipping;
      case OrderStatus.collected:
        return Icons.inventory_2;
      case OrderStatus.processing:
        return Icons.refresh;
      case OrderStatus.ready:
        return Icons.inventory;
      case OrderStatus.delivering:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// 🔍 Bottom Sheet des Filtres
class _FiltersBottomSheet extends StatefulWidget {
  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textTertiary(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtres',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Filtres de date
                Text(
                  'Période',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        onTap: () => _selectStartDate(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Date début',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _startDate != null
                                    ? AppColors.textPrimary(context)
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassContainer(
                        onTap: () => _selectEndDate(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Date fin',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _endDate != null
                                    ? AppColors.textPrimary(context)
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Effacer',
                        isOutlined: true,
                        onPressed: () => _clearFilters(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumButton(
                        text: 'Appliquer',
                        onPressed: () => _applyFilters(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _clearFilters(BuildContext context) {
    context.read<OrdersProvider>().clearFilters();
    Navigator.pop(context);
  }

  void _applyFilters(BuildContext context) {
    context.read<OrdersProvider>().applyFilters(
          startDate: _startDate,
          endDate: _endDate,
        );
    Navigator.pop(context);
  }
}
