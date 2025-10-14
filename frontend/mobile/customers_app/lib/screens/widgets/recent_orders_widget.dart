import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../components/glass_components.dart';
import '../../providers/orders_provider.dart';
import '../../core/models/order.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';

/// 📦 Widget Commandes Récentes - Alpha Client App
///
/// Affiche les 5 dernières commandes sur le dashboard avec cache de 2 minutes
class RecentOrdersWidget extends StatefulWidget {
  const RecentOrdersWidget({Key? key}) : super(key: key);

  @override
  State<RecentOrdersWidget> createState() => _RecentOrdersWidgetState();
}

class _RecentOrdersWidgetState extends State<RecentOrdersWidget> {
  DateTime? _lastFetch;
  List<Order> _recentOrders = [];
  bool _isLoading = false;
  static const Duration _cacheDuration = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _loadRecentOrders();
  }

  bool get _shouldRefresh {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference > _cacheDuration;
  }

  Future<void> _loadRecentOrders() async {
    // Vérifier le cache
    if (!_shouldRefresh && _recentOrders.isNotEmpty) {
      debugPrint('OK [RecentOrders] Cache valide - Pas de rechargement');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final provider = Provider.of<OrdersProvider>(context, listen: false);
      
      // Charger depuis le provider (qui a son propre cache de 5 min)
      if (!provider.isInitialized) {
        await provider.initialize();
      }

      // Prendre les 5 premières commandes
      _recentOrders = provider.orders.take(5).toList();
      _lastFetch = DateTime.now();

      debugPrint('OK [RecentOrders] ${_recentOrders.length} commandes chargees');
    } catch (e) {
      debugPrint('ERROR [RecentOrders] Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  /// 📋 Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Commandes recentes',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrdersScreen(),
              ),
            );
          },
          child: Text(
            'Voir tout',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 📦 Contenu
  Widget _buildContent() {
    if (_isLoading && _recentOrders.isEmpty) {
      return _buildLoadingState();
    }

    if (_recentOrders.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _recentOrders
          .map((order) => _buildOrderMiniCard(order))
          .toList(),
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
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
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune commande',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎴 Mini card de commande
  Widget _buildOrderMiniCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            // Icône de statut
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: order.statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.shortOrderId}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: order.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.statusText,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: order.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} article${order.items.length > 1 ? 's' : ''} • ${_formatDate(order.createdAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            // Prix
            Text(
              '${order.totalAmount.toInt().toFormattedString()} F',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Icône de statut
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit_note;
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.collecting:
        return Icons.local_shipping;
      case OrderStatus.collected:
        return Icons.inventory;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// 📅 Formater la date
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
      return DateFormat('dd/MM').format(date);
    }
  }
}
