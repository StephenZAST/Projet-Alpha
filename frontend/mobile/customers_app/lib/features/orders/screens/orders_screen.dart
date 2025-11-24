import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../providers/orders_provider.dart';
import '../../../core/models/order.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filters_dialog.dart';
import 'order_details_screen.dart';
import 'create_order_screen.dart';

/// 📦 Écran de Gestion des Commandes - Alpha Client App
///
/// Affiche l'historique complet des commandes avec filtres et recherche
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedStatus;
  bool _isFilteringLocally = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialiser le provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Charger plus de commandes
      final provider = Provider.of<OrdersProvider>(context, listen: false);
      if (!provider.isLoadingMore && provider.hasMore) {
        provider.loadOrders();
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _isFilteringLocally = true;
    });
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => const OrderFiltersDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusChips(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      title: Text(
        'Mes Commandes',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: AppColors.textPrimary(context),
          ),
          onPressed: _showFiltersDialog,
          tooltip: 'Filtres',
        ),
      ],
    );
  }

  /// 🔍 Barre de recherche
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface(context),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher une commande...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary(context),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary(context),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// 🎨 Chips de statut horizontaux scrollables
  Widget _buildStatusChips() {
    return Container(
      height: 60,
      color: AppColors.surface(context),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildStatusChip('Toutes', null, Icons.apps),
          _buildStatusChip('Brouillon', OrderStatus.draft, Icons.edit_note),
          _buildStatusChip('En attente', OrderStatus.pending, Icons.pending),
          _buildStatusChip('Collecte', OrderStatus.collecting, Icons.local_shipping),
          _buildStatusChip('Collectée', OrderStatus.collected, Icons.inventory),
          _buildStatusChip('Traitement', OrderStatus.processing, Icons.settings),
          _buildStatusChip('Prête', OrderStatus.ready, Icons.check_circle),
          _buildStatusChip('Livraison', OrderStatus.delivering, Icons.delivery_dining),
          _buildStatusChip('Livrée', OrderStatus.delivered, Icons.done_all),
          _buildStatusChip('Annulée', OrderStatus.cancelled, Icons.cancel),
        ],
      ),
    );
  }

  /// 🎯 Chip de statut individuel avec effet glassy
  Widget _buildStatusChip(String label, OrderStatus? status, IconData icon) {
    final isSelected = _selectedStatus == status;
    final color = status?.color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
            _isFilteringLocally = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  )
                : null,
            color: isSelected ? null : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📦 Liste des commandes optimisée (filtrage local instantané)
  Widget _buildOrdersList() {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        // État de chargement initial SEULEMENT si vraiment aucune donnée
        if (provider.isLoading && !provider.hasOrders && !_isFilteringLocally) {
          return _buildLoadingState();
        }

        // Filtrage local instantané depuis le cache
        List<Order> orders = provider.orders;
        
        // Appliquer le filtre de statut localement
        if (_selectedStatus != null) {
          orders = orders.where((order) => order.status == _selectedStatus).toList();
        }

        // Appliquer le filtre de recherche localement
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          orders = orders.where((order) {
            return order.shortOrderId.toLowerCase().contains(query) ||
                   order.id.toLowerCase().contains(query) ||
                   order.items.any((item) => 
                     item.articleName.toLowerCase().contains(query));
          }).toList();
        }

        // État d'erreur
        if (provider.error != null && orders.isEmpty && !_isFilteringLocally) {
          return _buildErrorState(provider);
        }

        // État aucun résultat (il y a des commandes mais aucune ne correspond au filtre)
        if (orders.isEmpty && provider.hasOrders) {
          return _buildNoResultsState();
        }

        // État vide (vraiment aucune commande)
        if (orders.isEmpty && !provider.hasOrders) {
          return _buildEmptyState();
        }

        // Liste des commandes
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isFilteringLocally = false;
            });
            await provider.refresh();
          },
          color: AppColors.primary,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (provider.hasMore && _selectedStatus == null ? 1 : 0),
            itemBuilder: (context, index) {
              // Indicateur de chargement en bas
              if (index == orders.length) {
                return _buildLoadingMoreIndicator();
              }

              final order = orders[index];
              return OrderCard(
                order: order,
                onTap: () => _navigateToDetails(order),
              );
            },
          ),
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
            'Chargement des commandes...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(OrdersProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              provider.error ?? 'Une erreur est survenue',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: () => provider.refresh(),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 État aucun résultat (différent de vide)
  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune commande ne correspond à ce filtre',
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

  /// 📭 État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune commande',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore passé de commande.\nCommencez dès maintenant !',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: 'Nouvelle Commande',
              onPressed: () {
                // TODO: Navigation vers création de commande
                Navigator.pushNamed(context, '/create-order');
              },
              icon: Icons.add,
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
      alignment: Alignment.center,
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  /// 🎯 Floating Action Button avec effet glassy radiant
  /// ✅ Lié à la création de commande COMPLÈTE
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.accent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleNewOrderTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Nouvelle',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🛍️ Gestionnaire Nouvelle Commande Complète
  void _handleNewOrderTap() {
    HapticFeedback.lightImpact();

    // Navigation vers l'écran de création de commande complète
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateOrderScreen(),
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

  /// 🔄 Navigation vers les détails
  void _navigateToDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }
}
