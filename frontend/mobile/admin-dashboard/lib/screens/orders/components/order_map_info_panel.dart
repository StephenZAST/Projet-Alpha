import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../controllers/order_map_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../models/enums.dart';
import 'order_map_details_dialog.dart';

class OrderMapInfoPanel extends StatefulWidget {
  @override
  _OrderMapInfoPanelState createState() => _OrderMapInfoPanelState();
}

class _OrderMapInfoPanelState extends State<OrderMapInfoPanel>
    with SingleTickerProviderStateMixin {
  late OrderMapController controller;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrderMapController>();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 100, 0),
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
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Informations',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Contenu
                Expanded(
                  child: Obx(() {
                    if (controller.selectedOrder.value != null) {
                      return _buildSelectedOrderInfo(isDark);
                    } else {
                      return _buildGeneralInfo(isDark);
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedOrderInfo(bool isDark) {
    final order = controller.selectedOrder.value!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la commande sélectionnée
          Row(
            children: [
              Expanded(
                child: Text(
                  'Commande sélectionnée',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  size: 20,
                ),
                onPressed: controller.deselectOrder,
                tooltip: 'Fermer',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Informations de base
          _buildInfoCard(
            'Informations générales',
            [
              _buildInfoRow('ID', '#${order.id.substring(0, 8)}...', Icons.receipt, isDark),
              _buildInfoRow('Statut', _getStatusLabel(order.status), Icons.info, isDark, 
                  statusColor: _getStatusColor(order.status)),
              _buildInfoRow('Type', order.isFlashOrder ? 'Flash' : 'Normale', 
                  order.isFlashOrder ? Icons.flash_on : Icons.receipt_long, isDark,
                  statusColor: order.isFlashOrder ? AppColors.accent : null),
              if (order.totalAmount != null)
                _buildInfoRow('Montant', '${order.totalAmount!.toStringAsFixed(0)} FCFA', 
                    Icons.attach_money, isDark, statusColor: AppColors.success),
              _buildInfoRow('Paiement', _getPaymentMethodLabel(order.paymentMethod), 
                  Icons.payment, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.md),

          // Informations client
          _buildInfoCard(
            'Client',
            [
              _buildInfoRow('Nom', order.client.fullName, Icons.person, isDark),
              _buildInfoRow('Email', order.client.email, Icons.email, isDark),
              if (order.client.phone != null)
                _buildInfoRow('Téléphone', order.client.phone!, Icons.phone, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.md),

          // Adresse
          _buildInfoCard(
            'Adresse de livraison',
            [
              _buildInfoRow('Nom', order.address.name ?? 'Sans nom', Icons.label, isDark),
              _buildInfoRow('Rue', order.address.street, Icons.location_on, isDark),
              _buildInfoRow('Ville', order.address.city, Icons.location_city, isDark),
              if (order.address.postalCode != null)
                _buildInfoRow('Code postal', order.address.postalCode!, Icons.markunread_mailbox, isDark),
              _buildInfoRow('Coordonnées', 
                  '${order.coordinates.latitude.toStringAsFixed(6)}, ${order.coordinates.longitude.toStringAsFixed(6)}', 
                  Icons.gps_fixed, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.md),

          // Service
          _buildInfoCard(
            'Service',
            [
              _buildInfoRow('Type', order.serviceType.name, Icons.build, isDark),
              if (order.serviceType.description != null)
                _buildInfoRow('Description', order.serviceType.description!, Icons.description, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.md),

          // Dates
          _buildInfoCard(
            'Dates',
            [
              _buildInfoRow('Création', _formatDate(order.createdAt), Icons.schedule, isDark),
              if (order.collectionDate != null)
                _buildInfoRow('Collecte', _formatDate(order.collectionDate!), Icons.local_shipping, isDark),
              if (order.deliveryDate != null)
                _buildInfoRow('Livraison', _formatDate(order.deliveryDate!), Icons.delivery_dining, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.md),

          // Articles
          _buildInfoCard(
            'Articles (${order.itemsCount})',
            [
              _buildInfoRow('Nombre d\'articles', order.itemsCount.toString(), Icons.inventory, isDark),
              if (order.totalWeight > 0)
                _buildInfoRow('Poids total', '${order.totalWeight.toStringAsFixed(2)} kg', Icons.scale, isDark),
            ],
            isDark,
          ),
          SizedBox(height: AppSpacing.lg),

          // Actions
          Column(
            children: [
              GlassButton(
                label: 'Voir les détails',
                icon: Icons.visibility,
                onPressed: () => _showOrderDetails(order.id),
                variant: GlassButtonVariant.primary,
                fullWidth: true,
              ),
              SizedBox(height: AppSpacing.sm),
              GlassButton(
                label: 'Centrer sur la carte',
                icon: Icons.center_focus_strong,
                onPressed: () => _centerOnOrder(order),
                variant: GlassButtonVariant.secondary,
                fullWidth: true,
              ),
              SizedBox(height: AppSpacing.sm),
              GlassButton(
                label: 'Ouvrir dans Google Maps',
                icon: Icons.open_in_new,
                onPressed: () => _openInGoogleMaps(order),
                variant: GlassButtonVariant.secondary,
                fullWidth: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques générales
          Text(
            'Statistiques de la carte',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Stats rapides
          Obx(() {
            final stats = controller.quickStats;
            return _buildInfoCard(
              'Résumé',
              [
                _buildInfoRow('Total commandes', stats['total']?.toString() ?? '0', 
                    Icons.receipt, isDark, statusColor: AppColors.primary),
                _buildInfoRow('En cours', stats['processing']?.toString() ?? '0', 
                    Icons.pending_actions, isDark, statusColor: AppColors.warning),
                _buildInfoRow('Livrées', stats['delivered']?.toString() ?? '0', 
                    Icons.check_circle, isDark, statusColor: AppColors.success),
                _buildInfoRow('Flash', stats['flash']?.toString() ?? '0', 
                    Icons.flash_on, isDark, statusColor: AppColors.accent),
              ],
              isDark,
            );
          }),
          SizedBox(height: AppSpacing.md),

          // Statistiques détaillées
          Obx(() {
            final mapStats = controller.mapStats.value;
            if (mapStats != null) {
              return _buildInfoCard(
                'Détails par statut',
                mapStats.byStatus.entries.map((entry) =>
                  _buildInfoRow(
                    _getStatusLabel(entry.key),
                    entry.value.toString(),
                    Icons.circle,
                    isDark,
                    statusColor: _getStatusColor(entry.key),
                  )
                ).toList(),
                isDark,
              );
            }
            return SizedBox.shrink();
          }),
          SizedBox(height: AppSpacing.md),

          // Statistiques géographiques
          Obx(() {
            final geoStats = controller.geoStats.value;
            if (geoStats != null) {
              return _buildInfoCard(
                'Répartition géographique',
                [
                  _buildInfoRow('Villes', geoStats.totalCities.toString(), 
                      Icons.location_city, isDark),
                  _buildInfoRow('Commandes totales', geoStats.totalOrders.toString(), 
                      Icons.receipt, isDark),
                  _buildInfoRow('Montant total', '${geoStats.totalAmount.toStringAsFixed(0)} FCFA', 
                      Icons.attach_money, isDark, statusColor: AppColors.success),
                ],
                isDark,
              );
            }
            return SizedBox.shrink();
          }),
          SizedBox(height: AppSpacing.lg),

          // Instructions
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Comment utiliser la carte',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '• Cliquez sur un marqueur pour voir les détails\n'
                  '• Utilisez les filtres pour affiner la vue\n'
                  '• Les couleurs indiquent le statut des commandes\n'
                  '• Les badges ⚡ indiquent les commandes flash',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, bool isDark) {
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark, {Color? statusColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: statusColor ?? (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor ?? (isDark ? AppColors.textLight : AppColors.textPrimary),
                fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(String orderId) {
    final order = controller.selectedOrder.value;
    if (order != null) {
      Get.dialog(
        OrderMapDetailsDialog(order: order),
      );
    }
  }

  void _centerOnOrder(order) {
    controller.updateMapCenter(order.coordinates);
    controller.updateMapZoom(15.0);
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'Collecte';
      case 'COLLECTED':
        return 'Collecté';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prêt';
      case 'DELIVERING':
        return 'En livraison';
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openInGoogleMaps(order) async {
    final lat = order.coordinates.latitude;
    final lng = order.coordinates.longitude;
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