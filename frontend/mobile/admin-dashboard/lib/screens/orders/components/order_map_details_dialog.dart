import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../models/enums.dart';
import '../../../models/order_map.dart';
import 'copy_text_button.dart';

class OrderMapDetailsDialog extends StatefulWidget {
  final OrderMapData order;

  const OrderMapDetailsDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _OrderMapDetailsDialogState createState() => _OrderMapDetailsDialogState();
}

class _OrderMapDetailsDialogState extends State<OrderMapDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: 600),
        child: GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      _getStatusIcon(widget.order.status),
                      color: _getStatusColor(widget.order.status),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Commande #${widget.order.id.substring(0, 8)}...',
                              style: AppTextStyles.h3.copyWith(
                                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            CopyTextButton(
                              text: widget.order.id,
                              tooltip: 'Copier l\'ID de la commande',
                              iconSize: 16,
                            ),
                            if (widget.order.isFlashOrder) ...[
                              SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: AppColors.accent.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flash_on,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'FLASH',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _getStatusLabel(widget.order.status),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getStatusColor(widget.order.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Contenu
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations générales
                      _buildInfoSection(
                        'Informations générales',
                        [
                          CopyTextRow(
                            label: 'ID complet',
                            text: widget.order.id,
                            isDark: isDark,
                            prefixIcon: Icons.receipt,
                          ),
                          _buildInfoRow('Statut', _getStatusLabel(widget.order.status), isDark, 
                              statusColor: _getStatusColor(widget.order.status)),
                          if (widget.order.totalAmount != null)
                            _buildInfoRow('Montant total', '${widget.order.totalAmount!.toStringAsFixed(0)} FCFA', isDark, 
                                statusColor: AppColors.success),
                          _buildInfoRow('Méthode de paiement', _getPaymentMethodLabel(widget.order.paymentMethod), isDark),
                          _buildInfoRow('Date de création', _formatDate(widget.order.createdAt), isDark),
                          if (widget.order.collectionDate != null)
                            _buildInfoRow('Date de collecte', _formatDate(widget.order.collectionDate!), isDark),
                          if (widget.order.deliveryDate != null)
                            _buildInfoRow('Date de livraison', _formatDate(widget.order.deliveryDate!), isDark),
                          if (widget.order.affiliateCode != null)
                            CopyTextRow(
                              label: 'Code affilié',
                              text: widget.order.affiliateCode!,
                              isDark: isDark,
                              prefixIcon: Icons.card_giftcard,
                            ),
                        ],
                        isDark,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Informations client
                      _buildInfoSection(
                        'Client',
                        [
                          CopyTextRow(
                            label: 'Nom complet',
                            text: widget.order.client.fullName,
                            isDark: isDark,
                            prefixIcon: Icons.person,
                          ),
                          CopyTextRow(
                            label: 'Email',
                            text: widget.order.client.email,
                            isDark: isDark,
                            prefixIcon: Icons.email,
                          ),
                          if (widget.order.client.phone != null)
                            CopyTextRow(
                              label: 'Téléphone',
                              text: widget.order.client.phone!,
                              isDark: isDark,
                              prefixIcon: Icons.phone,
                            ),
                        ],
                        isDark,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Adresse de livraison
                      _buildInfoSection(
                        'Adresse de livraison',
                        [
                          if (widget.order.address.name != null && widget.order.address.name!.isNotEmpty)
                            _buildInfoRow('Nom de l\'adresse', widget.order.address.name!, isDark),
                          _buildInfoRow('Rue', widget.order.address.street, isDark),
                          _buildInfoRow('Ville', widget.order.address.city, isDark),
                          if (widget.order.address.postalCode != null)
                            _buildInfoRow('Code postal', widget.order.address.postalCode!, isDark),
                          _buildInfoRow('Coordonnées GPS', 
                              '${widget.order.coordinates.latitude.toStringAsFixed(6)}, ${widget.order.coordinates.longitude.toStringAsFixed(6)}', 
                              isDark),
                        ],
                        isDark,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Service
                      _buildInfoSection(
                        'Service',
                        [
                          _buildInfoRow('Type de service', widget.order.serviceType.name, isDark),
                          if (widget.order.serviceType.description != null)
                            _buildInfoRow('Description', widget.order.serviceType.description!, isDark),
                        ],
                        isDark,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Articles
                      if (widget.order.items.isNotEmpty)
                        _buildItemsSection(widget.order.items, isDark),
                    ],
                  ),
                ),
              ),

              // Actions
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GlassButton(
                        label: 'Voir détails complets',
                        icon: Icons.open_in_new,
                        onPressed: () {
                          Get.back(); // Fermer ce dialog
                          // Ouvrir le dialog complet des détails de commande
                          final ordersController = Get.find<OrdersController>();
                          ordersController.fetchOrderDetails(widget.order.id);
                          // Le dialog complet s'ouvrira automatiquement via l'écran principal
                        },
                        variant: GlassButtonVariant.secondary,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      GlassButton(
                        label: 'Google Maps',
                        icon: Icons.map,
                        onPressed: _openInGoogleMaps,
                        variant: GlassButtonVariant.secondary,
                      ),
                    ],
                  ),
                  GlassButton(
                    label: 'Fermer',
                    onPressed: () => Get.back(),
                    variant: GlassButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.gray100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {Color? statusColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: statusColor ?? (isDark ? AppColors.textLight : AppColors.textPrimary),
                fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<OrderMapItem> items, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.gray100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Articles (${items.length})',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              if (widget.order.totalWeight > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Poids total: ${widget.order.totalWeight.toStringAsFixed(2)} kg',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...items.map((item) => _buildItemRow(item, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderMapItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray700.withOpacity(0.3)
            : AppColors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.article.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.isPremium) ...[
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.article.description != null && item.article.description!.isNotEmpty)
                  Text(
                    item.article.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                if (item.weight != null && item.weight! > 0)
                  Text(
                    'Poids: ${item.weight!.toStringAsFixed(2)} kg',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Qté: ${item.quantity}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                '${item.unitPrice.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total: ${item.totalPrice.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'COLLECTING':
        return AppColors.info;
      case 'COLLECTED':
        return AppColors.success.withOpacity(0.8);
      case 'PROCESSING':
        return AppColors.primary;
      case 'READY':
        return AppColors.accent;
      case 'DELIVERING':
        return Color(0xFFFF7043);
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule;
      case 'COLLECTING':
        return Icons.local_shipping;
      case 'COLLECTED':
        return Icons.inventory;
      case 'PROCESSING':
        return Icons.settings;
      case 'READY':
        return Icons.check_circle;
      case 'DELIVERING':
        return Icons.delivery_dining;
      case 'DELIVERED':
        return Icons.done_all;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'Collecte en cours';
      case 'COLLECTED':
        return 'Collecté';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prêt pour livraison';
      case 'DELIVERING':
        return 'En cours de livraison';
      case 'DELIVERED':
        return 'Livré';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
        return 'Espèces';
      case 'ORANGE_MONEY':
        return 'Orange Money';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openInGoogleMaps() async {
    final lat = widget.order.coordinates.latitude;
    final lng = widget.order.coordinates.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir Google Maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'ouverture de Google Maps: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
}