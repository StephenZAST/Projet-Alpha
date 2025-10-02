import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../core/models/order.dart';
import '../../providers/orders_provider.dart';
import '../../components/glass_components.dart';

/// 📋 Écran Détails Commande - Alpha Client App
///
/// Affichage complet des détails d'une commande avec timeline des statuts

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Détails Commande',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingOrderDetails) {
            return _buildLoadingState();
          }

          if (provider.orderDetailsError != null) {
            return _buildErrorState(provider.orderDetailsError!);
          }

          final order = provider.selectedOrder;
          if (order == null) {
            return _buildNotFoundState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadOrderDetails(widget.orderId),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(order),
                  const SizedBox(height: 24),
                  _buildStatusTimeline(order),
                  const SizedBox(height: 24),
                  _buildOrderItems(order),
                  const SizedBox(height: 24),
                  _buildAddressInfo(order),
                  const SizedBox(height: 24),
                  _buildPaymentInfo(order),
                  const SizedBox(height: 24),
                  _buildPricingBreakdown(order),
                  if (order.canBeCancelled) ...[
                    const SizedBox(height: 24),
                    _buildCancelButton(order),
                  ],
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📱 En-tête de la commande
  Widget _buildOrderHeader(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande #${order.shortId}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passée le ${_formatFullDate(order.createdAt)}',
                      style: AppTextStyles.bodyMedium.copyWith(
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.1),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: order.statusColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: order.statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.statusText,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: order.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getStatusDescription(order.status),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: order.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ⏱️ Timeline des statuts
  Widget _buildStatusTimeline(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivi de la Commande',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineStep(
            'Commande passée',
            order.createdAt,
            true,
            Icons.shopping_cart,
            AppColors.primary,
          ),
          _buildTimelineStep(
            'Confirmée',
            order.confirmedAt,
            order.status.index >= OrderStatus.pending.index,
            Icons.check_circle,
            AppColors.success,
          ),
          _buildTimelineStep(
            'En traitement',
            order.processingAt,
            order.status.index >= OrderStatus.processing.index,
            Icons.settings,
            AppColors.warning,
          ),
          _buildTimelineStep(
            'Prête',
            order.readyAt,
            order.status.index >= OrderStatus.ready.index,
            Icons.inventory,
            AppColors.info,
          ),
          _buildTimelineStep(
            'En livraison',
            order.deliveringAt,
            order.status.index >= OrderStatus.delivering.index,
            Icons.local_shipping,
            AppColors.accent,
          ),
          _buildTimelineStep(
            'Livrée',
            order.deliveredAt,
            order.status == OrderStatus.delivered,
            Icons.check_circle,
            AppColors.success,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    DateTime? date,
    bool isCompleted,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color
                    : AppColors.textTertiary(context).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted
                    ? Colors.white
                    : AppColors.textTertiary(context),
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isCompleted
                    ? color
                    : AppColors.textTertiary(context).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isCompleted
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFullDate(date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🛍️ Articles de la commande
  Widget _buildOrderItems(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Articles (${order.items.length})',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items
              .map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context).withOpacity(0.5),
                      borderRadius: AppRadius.radiusSM,
                      border: Border.all(
                        color: AppColors.border(context).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.checkroom,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.articleName,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.serviceName} • ${item.serviceTypeName}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              if (item.isPremium) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Premium',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'x${item.quantity}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(item.unitPrice * item.quantity).toFormattedString()} FCFA',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  /// 📍 Informations d'adresse
  Widget _buildAddressInfo(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresses',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Adresse de collecte
          _buildAddressCard(
            'Collecte',
            order.pickupAddress,
            Icons.home,
            AppColors.primary,
          ),

          const SizedBox(height: 12),

          // Adresse de livraison
          _buildAddressCard(
            'Livraison',
            order.deliveryAddress,
            Icons.location_on,
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    String title,
    OrderAddress? address,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (address != null) ...[
                  Text(
                    address.fullAddress,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  if (address.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      address.phone!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ] else
                  Text(
                    'Non spécifiée',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💳 Informations de paiement
  Widget _buildPaymentInfo(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paiement',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPaymentColor(order.paymentMethod).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPaymentIcon(order.paymentMethod),
                  color: _getPaymentColor(order.paymentMethod),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodText(order.paymentMethod),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      order.isPaid ? 'Payé' : 'En attente',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: order.isPaid
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: order.isPaid ? 'Payé' : 'En attente',
                color: order.isPaid ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💰 Détail des prix
  Widget _buildPricingBreakdown(Order order) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail des Prix',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(context, 'Sous-total', order.subtotal),
          if (order.discountAmount > 0)
            _buildPriceRow(
              context,
              'Réduction',
              -order.discountAmount,
              color: AppColors.success,
            ),
          if (order.deliveryFee > 0)
            _buildPriceRow(context, 'Frais de livraison', order.deliveryFee),
          if (order.taxAmount > 0)
            _buildPriceRow(context, 'Taxes', order.taxAmount),
          const Divider(height: 24),
          _buildPriceRow(
            context,
            'Total',
            order.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: (isTotal
                      ? AppTextStyles.labelLarge
                      : AppTextStyles.bodyMedium)
                  .copyWith(
                color: color ?? AppColors.textPrimary(context),
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${amount.toFormattedString()} FCFA',
            style:
                (isTotal ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
                    .copyWith(
              color: color ?? AppColors.textPrimary(context),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Bouton d'annulation
  Widget _buildCancelButton(Order order) {
    return SizedBox(
      width: double.infinity,
      child: PremiumButton(
        text: 'Annuler la Commande',
        icon: Icons.cancel,
        backgroundColor: AppColors.error,
        onPressed: () => _showCancelDialog(order),
      ),
    );
  }

  // États de chargement et d'erreur
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

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
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineSmall.copyWith(
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
              onPressed: () => context
                  .read<OrdersProvider>()
                  .loadOrderDetails(widget.orderId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
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
              'Commande introuvable',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette commande n\'existe pas ou a été supprimée',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Retour',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Actions
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
          'Êtes-vous sûr de vouloir annuler cette commande ? Cette action ne peut pas être annulée.',
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
    final success =
        await provider.cancelOrder(order.id, 'Annulé par le client');

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Retour à la liste
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

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Votre commande est en brouillon';
      case OrderStatus.pending:
        return 'Votre commande est en attente de confirmation';
      case OrderStatus.collecting:
        return 'Collecte en cours';
      case OrderStatus.collected:
        return 'Votre commande a été collectée';
      case OrderStatus.processing:
        return 'Votre commande est en cours de traitement';
      case OrderStatus.ready:
        return 'Votre commande est prête';
      case OrderStatus.delivering:
        return 'Votre commande est en cours de livraison';
      case OrderStatus.delivered:
        return 'Votre commande a été livrée';
      case OrderStatus.cancelled:
        return 'Votre commande a été annulée';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.orangeMoney:
        return Icons.phone_android;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  Color _getPaymentColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppColors.success;
      case PaymentMethod.card:
        return AppColors.primary;
      case PaymentMethod.orangeMoney:
        return AppColors.accent;
      case PaymentMethod.mobileMoney:
        return AppColors.accent;
      case PaymentMethod.bankTransfer:
        return AppColors.info;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.card:
        return 'Carte bancaire';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Virement bancaire';
    }
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
