import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/order.dart';
import '../../../providers/orders_provider.dart';
import '../widgets/order_timeline.dart';

/// 📋 Écran de Détails de Commande - Alpha Client App
///
/// Affiche tous les détails d'une commande avec timeline et actions
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    
    // Charger les détails complets depuis le cache ou l'API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetails();
    });
  }

  Future<void> _loadOrderDetails() async {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    await provider.loadOrderById(_currentOrder.id);
    
    if (provider.selectedOrder != null) {
      setState(() {
        _currentOrder = provider.selectedOrder!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedOrder == null) {
            return _buildLoadingState();
          }

          return RefreshIndicator(
            onRefresh: _loadOrderDetails,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 16),
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildItemsSection(),
                  const SizedBox(height: 16),
                  _buildPricingSection(),
                  const SizedBox(height: 16),
                  _buildAddressSection(),
                  const SizedBox(height: 16),
                  _buildPaymentSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      title: Text(
        'Commande #${_currentOrder.shortOrderId}',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () {
            // TODO: Partager la commande
          },
        ),
      ],
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
            'Chargement des details...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Card de statut
  Widget _buildStatusCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _currentOrder.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(_currentOrder.status),
              color: _currentOrder.statusColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.statusText,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: _currentOrder.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(_currentOrder.status),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📈 Timeline
  Widget _buildTimeline() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivi de commande',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          OrderTimeline(order: _currentOrder),
        ],
      ),
    );
  }

  /// ℹ️ Section informations
  Widget _buildInfoSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID Commande', '#${_currentOrder.shortOrderId}'),
          _buildInfoRow('Date de creation', _formatDateTime(_currentOrder.createdAt)),
          if (_currentOrder.collectionDate != null)
            _buildInfoRow('Date de collecte', _formatDate(_currentOrder.collectionDate!)),
          if (_currentOrder.deliveryDate != null)
            _buildInfoRow('Date de livraison', _formatDate(_currentOrder.deliveryDate!)),
          if (_currentOrder.isRecurring)
            _buildInfoRow('Recurrence', _currentOrder.recurrenceType?.displayName ?? 'Oui'),
        ],
      ),
    );
  }

  /// 📦 Section articles
  Widget _buildItemsSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentOrder.items.length} article${_currentOrder.items.length > 1 ? 's' : ''}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._currentOrder.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  /// 🛍️ Ligne d'article
  Widget _buildItemRow(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}x',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.articleName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.serviceName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(item.unitPrice * item.quantity).toInt().toFormattedString()} F',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (item.isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 💰 Section tarification (SIMPLIFIÉE - Compacte)
  Widget _buildPricingSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail des Prix',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          // ✅ Afficher le prix manuel si applicable
          if (_currentOrder.manualPrice != null) ...[
            _buildManualPricingSection(),
            const SizedBox(height: 16),
          ],
          
          // 💰 Prix à payer (prix ajusté ou prix original)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix à payer',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_currentOrder.manualPrice ?? _currentOrder.totalAmount).toInt().toFormattedString()} FCFA',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          // ✅ Afficher le statut de paiement
          const SizedBox(height: 12),
          _buildPaymentStatusBadge(),
        ],
      ),
    );
  }

  /// ✅ NOUVEAU - Affiche le prix manuel et la réduction/augmentation
  Widget _buildManualPricingSection() {
    final hasReduction = _currentOrder.manualPrice! < _currentOrder.totalAmount;
    final adjustmentAmount = (_currentOrder.totalAmount - _currentOrder.manualPrice!).abs();
    final adjustmentPercent = _currentOrder.discountPercentage ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasReduction 
          ? AppColors.success.withOpacity(0.1)
          : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasReduction 
            ? AppColors.success.withOpacity(0.3)
            : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              Icon(
                hasReduction ? Icons.trending_down : Icons.trending_up,
                color: hasReduction ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasReduction ? 'Réduction appliquée' : 'Augmentation appliquée',
                style: AppTextStyles.labelMedium.copyWith(
                  color: hasReduction ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Prix original et manuel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix original',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${_currentOrder.totalAmount.toInt().toFormattedString()} FCFA',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix ajusté',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${_currentOrder.manualPrice!.toInt().toFormattedString()} FCFA',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Montant et pourcentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant',
                style: AppTextStyles.labelSmall.copyWith(
                  color: hasReduction ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${hasReduction ? '-' : '+'}${adjustmentAmount.toInt().toFormattedString()} FCFA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: hasReduction ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pourcentage',
                style: AppTextStyles.labelSmall.copyWith(
                  color: hasReduction ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${hasReduction ? '-' : '+'}${adjustmentPercent.toStringAsFixed(1)}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: hasReduction ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ NOUVEAU - Badge de statut paiement
  Widget _buildPaymentStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _currentOrder.isPaid 
          ? AppColors.success.withOpacity(0.15)
          : AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _currentOrder.isPaid 
            ? AppColors.success.withOpacity(0.5)
            : AppColors.warning.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentOrder.isPaid ? Icons.check_circle : Icons.pending,
            color: _currentOrder.isPaid ? AppColors.success : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _currentOrder.isPaid ? 'Payée' : 'Non payée',
            style: AppTextStyles.labelMedium.copyWith(
              color: _currentOrder.isPaid ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_currentOrder.paidAt != null) ...[
            const SizedBox(width: 8),
            Text(
              'le ${_formatDate(_currentOrder.paidAt!)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📍 Section adresse
  Widget _buildAddressSection() {
    if (_currentOrder.deliveryAddress == null) return const SizedBox.shrink();

    final address = _currentOrder.deliveryAddress!;
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse de livraison',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    if (address.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.phone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💳 Section paiement
  Widget _buildPaymentSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paiement',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _getPaymentIcon(_currentOrder.paymentMethod),
                color: _currentOrder.paymentMethod.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentOrder.paymentMethod.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // ✅ CORRIGÉ - Utiliser isPaid au lieu de paymentStatus
                    Text(
                      _currentOrder.isPaid ? 'Payé' : 'En attente',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _currentOrder.isPaid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _currentOrder.isPaid
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentOrder.isPaid ? 'Payé' : 'En attente',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _currentOrder.isPaid ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📋 Ligne d'info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 Ligne de prix
  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (isTotal ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium).copyWith(
              color: isTotal ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.toInt().toFormattedString()} FCFA',
            style: (isTotal ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium).copyWith(
              color: isDiscount ? AppColors.success : (isTotal ? AppColors.primary : AppColors.textPrimary(context)),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
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

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Commande en brouillon';
      case OrderStatus.pending:
        return 'En attente de collecte';
      case OrderStatus.collecting:
        return 'Collecte en cours';
      case OrderStatus.collected:
        return 'Articles collectes';
      case OrderStatus.processing:
        return 'Traitement en cours';
      case OrderStatus.ready:
        return 'Prete pour livraison';
      case OrderStatus.delivering:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Commande livree';
      case OrderStatus.cancelled:
        return 'Commande annulee';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.orangeMoney:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobileMoney:
        return Icons.smartphone;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
} 