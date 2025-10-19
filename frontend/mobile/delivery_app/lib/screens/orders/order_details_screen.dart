import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../controllers/orders_controller.dart';
import '../../models/delivery_order.dart';
import '../../widgets/shared/glass_container.dart';
import '../../services/navigation_service.dart';

/// 📋 Écran Détails Commande - Alpha Delivery App
///
/// Interface mobile-first pour afficher et gérer les détails d'une commande.
/// Fonctionnalités : navigation GPS, actions statut, informations complètes.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Récupérer la commande depuis les arguments ou la sélection
    final arguments = Get.arguments as Map<String, dynamic>?;
    final orderId = arguments?['orderId'] as String?;
    final orderFromArgs = arguments?['order'] as DeliveryOrder?;

    // Si on a une commande dans les arguments, l'utiliser directement
    if (orderFromArgs != null) {
      return _buildOrderDetails(context, orderFromArgs, controller, isDark);
    }

    // Sinon, observer les changements du contrôleur
    return Obx(() {
      DeliveryOrder? order;

      if (orderId != null) {
        order = controller.orders.firstWhereOrNull((o) => o.id == orderId);
      } else {
        order = controller.selectedOrder.value;
      }

      if (order == null) {
        return _buildErrorScreen(isDark);
      }

      return _buildOrderDetails(context, order, controller, isDark);
    });
  }

  /// 📋 Construction des détails de commande
  Widget _buildOrderDetails(BuildContext context, DeliveryOrder order,
      OrdersController controller, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          // =================================================================
          // 📱 APP BAR AVEC ACTIONS
          // =================================================================
          _buildSliverAppBar(context, order, isDark),

          // =================================================================
          // 📋 CONTENU PRINCIPAL
          // =================================================================
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informations principales
                _buildMainInfoSection(order, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Informations client
                _buildCustomerSection(order, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Adresse avec navigation
                _buildAddressSection(order, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Articles de la commande
                _buildItemsSection(order, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Notes et historique
                if (order.notes.isNotEmpty) _buildNotesSection(order, isDark),

                // Espacement pour le FAB
                const SizedBox(height: AppSpacing.xxl * 2),
              ]),
            ),
          ),
        ],
      ),

      // =================================================================
      // 🎯 ACTIONS FLOTTANTES
      // =================================================================
      floatingActionButton: _buildFloatingActions(order, controller, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 📱 App Bar avec informations commande
  Widget _buildSliverAppBar(
      BuildContext context, DeliveryOrder order, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: order.status.color,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Commande #${order.shortId}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                order.status.color,
                order.status.color.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        order.status.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        order.status.displayName,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (order.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.priority_high,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'URGENT',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareOrderDetails(order),
          icon: const Icon(Icons.share, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, order),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_id',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: AppSpacing.sm),
                  Text('Copier ID'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_note',
              child: Row(
                children: [
                  Icon(Icons.note_add),
                  SizedBox(width: AppSpacing.sm),
                  Text('Ajouter note'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'call_customer',
              child: Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: AppSpacing.sm),
                  Text('Appeler client'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📋 Section informations principales
  Widget _buildMainInfoSection(DeliveryOrder order, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations générales',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            'Service',
            order.serviceTypeName,
            Icons.cleaning_services,
            isDark,
          ),
          _buildInfoRow(
            'Montant total',
            order.formattedAmount,
            Icons.payments,
            isDark,
          ),
          _buildInfoRow(
            'Mode de paiement',
            order.paymentMethod,
            Icons.payment,
            isDark,
          ),
          if (order.collectionDate != null)
            _buildInfoRow(
              'Date de collecte',
              _formatDateTime(order.collectionDate!),
              Icons.schedule,
              isDark,
            ),
          if (order.deliveryDate != null)
            _buildInfoRow(
              'Date de livraison',
              _formatDateTime(order.deliveryDate!),
              Icons.local_shipping,
              isDark,
            ),
          _buildInfoRow(
            'Créée le',
            _formatDateTime(order.createdAt),
            Icons.calendar_today,
            isDark,
          ),
        ],
      ),
    );
  }

  /// 👤 Section informations client
  Widget _buildCustomerSection(DeliveryOrder order, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Informations client',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (order.customer.phone != null)
                GestureDetector(
                  onTap: () => _callCustomer(order.customer.phone!),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Icon(
                      Icons.phone,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Center(
                  child: Text(
                    order.customer.initials,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customer.fullName,
                      style: AppTextStyles.h4.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (order.customer.phone != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.customer.phone!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (order.customer.email != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.customer.email!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
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

  /// 📍 Section adresse avec navigation - PRIORITÉ AUX COORDONNÉES GPS
  Widget _buildAddressSection(DeliveryOrder order, bool isDark) {
    final hasGPS = order.address.hasCoordinates;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Emplacement de livraison',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (hasGPS)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    'GPS',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // PRIORITÉ 1 : Coordonnées GPS (si disponibles)
          if (hasGPS) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.satellite,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Coordonnées GPS',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${order.address.latitude!.toStringAsFixed(6)}, ${order.address.longitude!.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _copyAddress(
                          '${order.address.latitude!.toStringAsFixed(6)}, ${order.address.longitude!.toStringAsFixed(6)}',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: AppRadius.radiusXS,
                          ),
                          child: Icon(
                            Icons.copy,
                            color: AppColors.info,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => _navigateToAddress(order.address),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: AppRadius.radiusXS,
                          ),
                          child: Icon(
                            Icons.navigation,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            // Pas de GPS disponible
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Coordonnées GPS non disponibles',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // PRIORITÉ 2 : Informations supplémentaires de l'adresse
          if (order.address.fullAddress.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations supplémentaires',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (order.address.name != null) ...[
                        Text(
                          order.address.name!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        order.address.fullAddress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 🛍️ Section articles de la commande
  Widget _buildItemsSection(DeliveryOrder order, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Articles (${order.items.length})',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${order.totalItems} pièces',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...order.items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.isPremium
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.gray200.withOpacity(0.5),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: item.isPremium
                                    ? AppColors.warning
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.articleName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (item.isPremium)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        borderRadius: AppRadius.radiusXS,
                                      ),
                                      child: Text(
                                        'PREMIUM',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (item.categoryName != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  item.categoryName!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          item.formattedTotalPrice,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  /// 📝 Section notes
  Widget _buildNotesSection(DeliveryOrder order, bool isDark) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes (${order.notes.length})',
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...order.notes
              .map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.gray800.withOpacity(0.5)
                            : AppColors.gray100.withOpacity(0.5),
                        borderRadius: AppRadius.radiusSM,
                        border: Border.all(
                          color: isDark ? AppColors.gray700 : AppColors.gray200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.note,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _formatDateTime(note.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  /// 🎯 Actions flottantes selon le statut
  Widget _buildFloatingActions(
      DeliveryOrder order, OrdersController controller, bool isDark) {
    final actions = _getAvailableActions(order);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (actions.length == 1) {
      final action = actions.first;
      return FloatingActionButton.extended(
        onPressed: () =>
            _handleStatusUpdate(controller, order.id, action.status),
        backgroundColor: action.color,
        icon: Icon(action.icon, color: Colors.white),
        label: Text(
          action.label,
          style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions
          .map((action) => FloatingActionButton(
                heroTag: action.label,
                onPressed: () =>
                    _handleStatusUpdate(controller, order.id, action.status),
                backgroundColor: action.color,
                child: Icon(action.icon, color: Colors.white),
              ))
          .toList(),
    );
  }

  /// 📋 Widget ligne d'information
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Écran d'erreur
  Widget _buildErrorScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Commande introuvable',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Actions disponibles selon le statut
  List<_OrderAction> _getAvailableActions(DeliveryOrder order) {
    switch (order.status) {
      case OrderStatus.PENDING:
        return [
          _OrderAction(
            label: 'Collecter',
            icon: Icons.local_shipping_outlined,
            color: AppColors.primary,
            status: OrderStatus.COLLECTING,
          ),
        ];

      case OrderStatus.COLLECTING:
        return [
          _OrderAction(
            label: 'Collectée',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            status: OrderStatus.COLLECTED,
          ),
        ];

      case OrderStatus.READY:
        return [
          _OrderAction(
            label: 'Livrer',
            icon: Icons.delivery_dining_outlined,
            color: AppColors.primary,
            status: OrderStatus.DELIVERING,
          ),
        ];

      case OrderStatus.DELIVERING:
        return [
          _OrderAction(
            label: 'Livrée',
            icon: Icons.done_all_outlined,
            color: AppColors.success,
            status: OrderStatus.DELIVERED,
          ),
        ];

      default:
        return [];
    }
  }

  /// 🎬 Gestion des actions
  Future<void> _handleStatusUpdate(OrdersController controller, String orderId,
      OrderStatus newStatus) async {
    final success = await controller.updateOrderStatus(orderId, newStatus);
    if (success) {
      // Optionnel : retour à la liste après mise à jour
      // Get.back();
    }
  }

  /// 📞 Appeler le client
  Future<void> _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 🧭 Navigation vers l'adresse
  Future<void> _navigateToAddress(DeliveryAddress address) async {
    try {
      final navigationService = Get.find<NavigationService>();

      if (address.hasCoordinates) {
        await navigationService.navigateToCoordinates(
          address.latitude!,
          address.longitude!,
          label: address.name ?? 'Adresse de livraison',
        );
      } else {
        await navigationService.navigateToAddress(address.fullAddress);
      }
    } catch (e) {
      debugPrint('❌ Erreur navigation: $e');

      // Fallback : copier l'adresse si la navigation échoue
      _copyAddress(address.fullAddress);

      Get.snackbar(
        'Navigation indisponible',
        'L\'adresse a été copiée dans le presse-papiers',
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 📋 Copier l'adresse
  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    Get.snackbar(
      'Copié',
      'Adresse copiée dans le presse-papiers',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// 📤 Partager les détails
  void _shareOrderDetails(DeliveryOrder order) {
    final details = '''
Commande #${order.shortId}
Client: ${order.customer.fullName}
Statut: ${order.status.displayName}
Montant: ${order.formattedAmount}
Adresse: ${order.address.fullAddress}
    ''';

    // TODO: Implémenter le partage
    Get.snackbar(
      'Partage',
      'Fonctionnalité de partage à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  /// 🎯 Gestion des actions du menu
  void _handleMenuAction(String action, DeliveryOrder order) {
    switch (action) {
      case 'copy_id':
        Clipboard.setData(ClipboardData(text: order.id));
        Get.snackbar(
          'Copié',
          'ID de commande copié',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'add_note':
        _showAddNoteDialog(order);
        break;
      case 'call_customer':
        if (order.customer.phone != null) {
          _callCustomer(order.customer.phone!);
        }
        break;
    }
  }

  /// 📝 Dialog d'ajout de note
  void _showAddNoteDialog(DeliveryOrder order) {
    final controller = Get.find<OrdersController>();
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter une note'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Saisissez votre note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                Get.back();
                await controller.addOrderNote(order.id, textController.text);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  /// 📅 Formatage des dates
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// 🎯 Modèle d'action pour les commandes
class _OrderAction {
  final String label;
  final IconData icon;
  final Color color;
  final OrderStatus status;

  const _OrderAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.status,
  });
}
