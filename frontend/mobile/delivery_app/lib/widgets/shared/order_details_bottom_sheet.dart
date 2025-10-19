import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../models/delivery_order.dart';
import '../../services/navigation_service.dart';

/// 📋 Bottom Sheet Détails Commande
///
/// Widget réutilisable pour afficher les détails d'une commande
/// avec actions rapides (mise à jour statut, navigation, appel)
class OrderDetailsBottomSheet extends StatelessWidget {
  final DeliveryOrder order;
  final Function(OrderStatus) onStatusUpdate;
  final VoidCallback? onClose;

  const OrderDetailsBottomSheet({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray600 : AppColors.gray400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header avec statut
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  order.statusColor,
                  order.statusColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(order.statusIcon, color: Colors.white, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${order.shortId}',
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order.status.displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.priority_high,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
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
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose?.call();
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actions rapides
                  _buildQuickActions(context, isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // Informations client
                  _buildClientInfo(isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // Adresse
                  _buildAddressInfo(context, isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // Détails commande
                  _buildOrderDetails(isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // Articles
                  _buildItemsList(isDark),
                ],
              ),
            ),
          ),

          // Actions de mise à jour statut
          _buildStatusActions(context, isDark),
        ],
      ),
    );
  }

  /// Actions rapides
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.copy,
            label: 'Copier ID',
            color: AppColors.info,
            onTap: () => _copyOrderId(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'Appeler',
            color: AppColors.success,
            onTap: () => _callCustomer(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionButton(
            icon: Icons.navigation,
            label: 'Itinéraire',
            color: AppColors.primary,
            onTap: () => _navigateToAddress(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Informations client
  Widget _buildClientInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
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
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (order.customer.phone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    order.customer.phone!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Informations adresse - PRIORITÉ AUX COORDONNÉES GPS
  Widget _buildAddressInfo(BuildContext context, bool isDark) {
    final hasGPS = order.address.hasCoordinates;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: hasGPS
            ? Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec icône
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: hasGPS ? AppColors.primary : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emplacement de livraison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasGPS)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
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
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                        size: 16,
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${order.address.latitude!.toStringAsFixed(6)}, ${order.address.longitude!.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Cliquez sur "Itinéraire" pour ouvrir sur Google Maps',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            // Pas de GPS disponible
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppColors.warning,
                    size: 16,
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
          if (order.address.fullAddress.isNotEmpty) ...[
            Text(
              'Informations supplémentaires',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              order.address.fullAddress,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Détails commande
  Widget _buildOrderDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow('Service', order.serviceTypeName, isDark),
        _buildDetailRow('Montant', order.formattedAmount, isDark),
        _buildDetailRow('Paiement', order.paymentMethod, isDark),
        if (order.collectionDate != null)
          _buildDetailRow(
            'Collecte',
            _formatDate(order.collectionDate!),
            isDark,
          ),
        if (order.deliveryDate != null)
          _buildDetailRow(
            'Livraison',
            _formatDate(order.deliveryDate!),
            isDark,
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Liste des articles
  Widget _buildItemsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${order.items.length})',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...order.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray100)
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.isPremium
                          ? AppColors.warning.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.articleName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.categoryName != null)
                          Text(
                            item.categoryName!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    item.formattedTotalPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Actions de mise à jour statut
  Widget _buildStatusActions(BuildContext context, bool isDark) {
    final actions = _getAvailableActions();

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: actions.length == 1
            ? _buildPrimaryActionButton(actions.first, context)
            : Row(
                children: actions
                    .map((action) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: action == actions.last
                                  ? 0
                                  : AppSpacing.sm,
                            ),
                            child: _buildSecondaryActionButton(action, context),
                          ),
                        ))
                    .toList(),
              ),
      ),
    );
  }

  /// Bouton d'action primaire - Glassmorphism
  Widget _buildPrimaryActionButton(_OrderAction action, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            action.color.withOpacity(0.2),
            action.color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: action.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: action.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onStatusUpdate(action.status);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action.icon,
                  color: action.color,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  action.label,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: action.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bouton d'action secondaire - Glassmorphism
  Widget _buildSecondaryActionButton(_OrderAction action, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            action.color.withOpacity(0.2),
            action.color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: action.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: action.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onStatusUpdate(action.status);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  action.icon,
                  color: action.color,
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: action.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Actions disponibles selon le statut
  /// Basé sur les transitions valides du backend
  List<_OrderAction> _getAvailableActions() {
    switch (order.status) {
      // DRAFT → PENDING
      case OrderStatus.DRAFT:
        return [
          _OrderAction(
            label: 'Valider\nla commande',
            icon: Icons.check_circle_outline,
            color: AppColors.primary,
            status: OrderStatus.PENDING,
          ),
        ];

      // PENDING → COLLECTING
      case OrderStatus.PENDING:
        return [
          _OrderAction(
            label: 'Commencer\nla collecte',
            icon: Icons.local_shipping_outlined,
            color: AppColors.primary,
            status: OrderStatus.COLLECTING,
          ),
        ];

      // COLLECTING → COLLECTED
      case OrderStatus.COLLECTING:
        return [
          _OrderAction(
            label: 'Marquer\ncomme collectée',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            status: OrderStatus.COLLECTED,
          ),
        ];

      // COLLECTED → PROCESSING
      case OrderStatus.COLLECTED:
        return [
          _OrderAction(
            label: 'Commencer\nle traitement',
            icon: Icons.build_circle_outlined,
            color: AppColors.info,
            status: OrderStatus.PROCESSING,
          ),
        ];

      // PROCESSING → READY
      case OrderStatus.PROCESSING:
        return [
          _OrderAction(
            label: 'Marquer\ncomme prête',
            icon: Icons.done_outline,
            color: AppColors.success,
            status: OrderStatus.READY,
          ),
        ];

      // READY → DELIVERING
      case OrderStatus.READY:
        return [
          _OrderAction(
            label: 'Commencer\nla livraison',
            icon: Icons.delivery_dining_outlined,
            color: AppColors.primary,
            status: OrderStatus.DELIVERING,
          ),
        ];

      // DELIVERING → DELIVERED
      case OrderStatus.DELIVERING:
        return [
          _OrderAction(
            label: 'Confirmer\nla livraison',
            icon: Icons.done_all_outlined,
            color: AppColors.success,
            status: OrderStatus.DELIVERED,
          ),
        ];

      // DELIVERED et CANCELLED : pas d'action possible
      case OrderStatus.DELIVERED:
        return [
          _OrderAction(
            label: 'Commande livrée',
            icon: Icons.check_circle,
            color: AppColors.success,
            status: OrderStatus.DELIVERED,
            isDisabled: true,
          ),
        ];

      case OrderStatus.CANCELLED:
        return [
          _OrderAction(
            label: 'Commande annulée',
            icon: Icons.cancel,
            color: AppColors.error,
            status: OrderStatus.CANCELLED,
            isDisabled: true,
          ),
        ];

      default:
        return [];
    }
  }

  /// Copier l'ID de la commande
  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: order.id));
    Get.snackbar(
      'Copié',
      'ID de commande copié',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Appeler le client
  Future<void> _callCustomer() async {
    if (order.customer.phone == null) {
      Get.snackbar(
        'Erreur',
        'Numéro de téléphone non disponible',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri.parse('tel:${order.customer.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Navigation vers l'adresse
  Future<void> _navigateToAddress() async {
    try {
      final navigationService = Get.find<NavigationService>();

      if (order.address.hasCoordinates) {
        await navigationService.navigateToCoordinates(
          order.address.latitude!,
          order.address.longitude!,
          label: order.address.name ?? 'Adresse de livraison',
        );
      } else {
        await navigationService.navigateToAddress(order.address.fullAddress);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir la navigation',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  /// Formater une date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Modèle d'action
class _OrderAction {
  final String label;
  final IconData icon;
  final Color color;
  final OrderStatus status;
  final bool isDisabled;

  const _OrderAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.status,
    this.isDisabled = false,
  });
}
