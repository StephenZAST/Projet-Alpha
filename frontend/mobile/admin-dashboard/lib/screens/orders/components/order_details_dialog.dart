import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/screens/orders/new_order/components/client_details_dialog.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/order_item_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/controllers/service_type_controller.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/enums.dart';
import '../../../widgets/shared/glass_container.dart';
import 'copy_order_id_row.dart';

// ✅ IMPORT DE LA SECTION PRICING
import 'order_pricing_section.dart';

// Helpers pour l'affichage des remises
String discountLabel(String key) {
  switch (key) {
    case 'offers':
      return 'Offres spéciales';
    case 'loyalty':
      return 'Points fidélité';
    case 'promo':
      return 'Code promo';
    default:
      return key;
  }
}

String discountTotal(Map discounts) {
  try {
    final total = discounts.values.fold<num>(
        0, (sum, v) => sum + (v is num ? v : num.tryParse(v.toString()) ?? 0));
    return total.toString();
  } catch (_) {
    return '0';
  }
}

class OrderDetailsDialog extends StatefulWidget {
  final String orderId;

  const OrderDetailsDialog({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsDialogState createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildClientSection(order, bool isDark) {
    final user = order.user;

    return GlassContainer(
      variant: GlassContainerVariant.primary,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations Client',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Détails du client et coordonnées',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              _ModernActionButton(
                icon: Icons.edit,
                label: 'Modifier',
                onPressed: user == null
                    ? null
                    : () async {
                        await showDialog(
                          context: context,
                          builder: (_) => ClientDetailsDialog(client: user),
                        );
                      },
                variant: _ActionVariant.primary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _ClientInfoCard(
            user: user,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(order) {
    final address = order.address;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: Colors.teal, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adresse de livraison',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Nom : ${address?.name ?? ''}'),
                Text('Rue : ${address?.street ?? ''}'),
                Text('Ville : ${address?.city ?? ''}'),
                Text('Code postal : ${address?.postalCode ?? ''}'),
                Text(
                    'GPS : ${address?.gpsLatitude ?? ''}, ${address?.gpsLongitude ?? ''}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlassButton(
            label: 'Modifier',
            icon: Icons.edit_location_alt,
            variant: GlassButtonVariant.info,
            onPressed: address == null
                ? null
                : () async {
                    await showDialog(
                      context: Get.context!,
                      builder: (_) => OrderAddressDialog(
                        initialAddress: address,
                        orderId: order.id,
                        onAddressSaved: (_) async {
                          // Après modification, recharge les détails
                          final controller = Get.find<OrdersController>();
                          await controller.fetchOrderDetails(order.id);
                        },
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(order, BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    final serviceTypeController = Get.find<ServiceTypeController>();
    final items = order.items ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Text('Articles / Services',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              GlassButton(
                label: 'Modifier / Ajouter',
                icon: Icons.edit,
                variant: GlassButtonVariant.success,
                onPressed: () async {
                  if (controller.articles.isEmpty) {
                    await controller.loadArticles();
                  }
                  if (controller.services.isEmpty) {
                    await controller.loadServices();
                  }
                  final availableArticles = controller.articles;
                  final availableServices = controller.services;
                  final itemsPayload = await showDialog(
                    context: context,
                    builder: (_) => OrderItemEditDialog(
                      availableArticles: availableArticles,
                      availableServices: availableServices,
                    ),
                  );
                  if (itemsPayload != null && itemsPayload is List) {
                    for (var item in itemsPayload) {
                      await controller.addOrderItem(item);
                    }
                    final orderId = controller.selectedOrder.value?.id;
                    if (orderId != null) {
                      await controller.updateOrder(
                          orderId, controller.orderEditForm);
                      await controller.fetchOrderDetails(orderId);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Aucun article/service dans la commande')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                final articleName = item.article?.name ?? '';
                String serviceName = '';
                String serviceTypeLabel = '';
                String quantOrWeight = '';
                int quantity = item.quantity ?? 1;
                double? weight = item.weight;
                int unitPrice = item.unitPrice ?? 0;
                var service = item.serviceId != null
                    ? controller.services
                        .firstWhereOrNull((s) => s.id == item.serviceId)
                    : null;
                var serviceType = service != null &&
                        service.serviceTypeId != null
                    ? serviceTypeController.serviceTypes
                        .firstWhereOrNull((t) => t.id == service.serviceTypeId)
                    : null;
                if (service != null) {
                  serviceName = service.name;
                }
                if (serviceType != null) {
                  serviceTypeLabel = serviceType.pricingType == 'WEIGHT_BASED'
                      ? 'Au poids'
                      : serviceType.pricingType == 'FIXED'
                          ? "À l'article"
                          : serviceType.name;
                  if (serviceType.pricingType == 'WEIGHT_BASED') {
                    quantOrWeight = weight != null
                        ? 'Poids : ${weight.toStringAsFixed(2)} kg'
                        : '';
                  } else {
                    quantOrWeight = 'Quantité : $quantity';
                  }
                }
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (articleName.isNotEmpty)
                          Text('Article : $articleName',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Service : $serviceName'),
                        if (serviceTypeLabel.isNotEmpty)
                          Text('Type de service : $serviceTypeLabel'),
                        if (quantOrWeight.isNotEmpty) Text(quantOrWeight),
                        Text('Prix unitaire : $unitPrice FCFA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700])),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total commande : ${order.totalAmount ?? 0} FCFA',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(order, OrdersController controller) {
    return Row(
      children: [
        GlassButton(
          label: 'Annuler',
          variant: GlassButtonVariant.error,
          onPressed: () {
            // TODO: Action annulation
          },
        ),
        const SizedBox(width: 12),
        GlassButton(
          label: 'Archiver',
          variant: GlassButtonVariant.info,
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: Get.context!,
              builder: (context) => AlertDialog(
                title: Text('Archiver la commande ?'),
                content: Text(
                    'Cette action déplacera la commande dans les archives. Voulez-vous continuer ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Archiver'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              try {
                await controller.archiveOrder(order.id);
                // Affiche la notification de succès avec blur avant de fermer le dialog
                Get.closeAllSnackbars();
                Get.rawSnackbar(
                  messageText: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Commande archivée avec succès',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.withOpacity(0.85),
                  borderRadius: 16,
                  margin: EdgeInsets.all(24),
                  snackPosition: SnackPosition.TOP,
                  duration: Duration(seconds: 2),
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                  isDismissible: true,
                  overlayBlur: 2.5,
                );
                await Future.delayed(Duration(milliseconds: 800));
                Get.back(); // Ferme le dialog après la notif
              } catch (_) {}
            }
          },
        ),
      ],
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 900,
                height: MediaQuery.of(context).size.height * 0.9,
                child: GlassContainer(
                  variant: GlassContainerVariant.neutral,
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      _buildDialogHeader(isDark),
                      Expanded(
                        child: _buildDialogContent(controller, isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la Commande',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestion complète de la commande',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          _ModernCloseButton(
            onPressed: () {
              final controller = Get.find<OrdersController>();
              controller.clearOrderEditForm();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(OrdersController controller, bool isDark) {
    return Obx(() {
      final order = controller.selectedOrder.value;
      if (controller.isLoading.value ||
          order == null ||
          order.id != widget.orderId) {
        return SizedBox(
          width: 700,
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      // Initialiser le formulaire d'édition si vide
      if (controller.orderEditForm.isEmpty) {
        controller.loadOrderEditForm(order);
      }
      // ✅ CHARGER LES DONNÉES DE PRICING - TOUJOURS RECHARGER POUR ASSURER LA PERSISTANCE
      // Cela garantit que les données de pricing sont à jour même après un redémarrage de l'app
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.orderPricing.isEmpty) {
          controller.fetchOrderPricing(widget.orderId);
        }
      });
      return Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.isSubscriptionOrder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassButton(
                    label: 'Commande Abonné Premium',
                    icon: Icons.star,
                    variant: GlassButtonVariant.info,
                    onPressed: null,
                  ),
                ),
              Text('Détails de la commande',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              CopyOrderIdRow(orderId: order.id),
              const SizedBox(height: 16),
              // === SECTION PRICING & PAIEMENT ===
              buildPricingSection(context, order, controller, isDark),
              const SizedBox(height: 24),
              // Code affilié (modification possible)
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue:
                          controller.orderEditForm['affiliateCode'] ?? '',
                      decoration: InputDecoration(
                        labelText: 'Code affilié',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                      onChanged: (value) {
                        controller.setOrderEditField('affiliateCode', value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Champ note de commande
                    TextFormField(
                      initialValue:
                          controller.orderEditForm['note'] ?? order.note ?? '',
                      decoration: InputDecoration(
                        labelText: 'Note de commande',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      minLines: 2,
                      maxLines: 5,
                      style: TextStyle(fontSize: 16),
                      onChanged: (value) {
                        controller.setOrderEditField('note', value);
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              // Statut
              Obx(() {
                final selectedStatus = OrderStatus.values.firstWhereOrNull(
                  (s) => s.name == controller.orderEditForm['status'],
                );
                return DropdownButtonFormField<OrderStatus>(
                  value: selectedStatus ?? OrderStatus.PENDING,
                  decoration: InputDecoration(labelText: 'Statut'),
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(status.icon, color: status.color, size: 20),
                          SizedBox(width: 8),
                          Text(
                            status.label,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? newStatus) {
                    if (newStatus != null) {
                      controller.setOrderEditField('status', newStatus.name);
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
              // Méthode de paiement
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.orderEditForm['paymentMethod'] ?? 'CASH',
                    decoration:
                        InputDecoration(labelText: 'Méthode de paiement'),
                    items: const [
                      DropdownMenuItem(value: 'CASH', child: Text('Espèces')),
                      DropdownMenuItem(
                          value: 'ORANGE_MONEY', child: Text('Mobile Money')),
                    ],
                    onChanged: (v) =>
                        controller.setOrderEditField('paymentMethod', v),
                  )),
              const SizedBox(height: 16),
              // Date de collecte
              Obx(() => GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.orderEditForm['collectionDate'] ??
                                DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.setOrderEditField('collectionDate', picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration:
                            InputDecoration(labelText: 'Date de collecte'),
                        controller: TextEditingController(
                            text: _formatDateTime(
                                controller.orderEditForm['collectionDate'])),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              // Date de livraison
              Obx(() => GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.orderEditForm['deliveryDate'] ??
                            DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.setOrderEditField('deliveryDate', picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration:
                            InputDecoration(labelText: 'Date de livraison'),
                        controller: TextEditingController(
                            text: _formatDateTime(
                                controller.orderEditForm['deliveryDate'])),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  GlassButton(
                    label: 'Enregistrer',
                    variant: GlassButtonVariant.primary,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            // Préparer le patch : n'envoyer que les champs modifiables et non nuls
                            final patch = <String, dynamic>{};
                            final form = controller.orderEditForm;
                            if (form['affiliateCode'] != null)
                              patch['affiliateCode'] = form['affiliateCode'];
                            if (form['note'] != null)
                              patch['note'] = form['note'];
                            if (form['status'] != null)
                              patch['status'] = form['status'];
                            if (form['paymentMethod'] != null)
                              patch['paymentMethod'] = form['paymentMethod'];
                            if (form['collectionDate'] != null)
                              patch['collectionDate'] =
                                  form['collectionDate']?.toIso8601String();
                            if (form['deliveryDate'] != null)
                              patch['deliveryDate'] =
                                  form['deliveryDate']?.toIso8601String();
                            // Ajoute d'autres champs modifiables si besoin
                            try {
                              await controller.updateOrder(order.id, patch);
                              controller.clearOrderEditForm();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Commande mise à jour avec succès')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Erreur lors de la mise à jour : $e')),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    label: 'Fermer',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () {
                      controller.clearOrderEditForm();
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildClientSection(controller.selectedOrder.value, isDark),
              const SizedBox(height: 24),
              _buildAddressSection(controller.selectedOrder.value),
              const SizedBox(height: 24),
              _buildOrderItemsSection(controller.selectedOrder.value, context),
              const SizedBox(height: 24),
              _buildActionsSection(controller.selectedOrder.value, controller),
            ],
          ),
        ),
      );
    });
  }
}

// Composants modernes pour le dialog des détails de commande
enum _ActionVariant { primary, secondary, success, warning, error }

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final _ActionVariant variant;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case _ActionVariant.primary:
        return AppColors.primary;
      case _ActionVariant.secondary:
        return AppColors.gray600;
      case _ActionVariant.success:
        return AppColors.success;
      case _ActionVariant.warning:
        return AppColors.warning;
      case _ActionVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: GlassContainerVariant.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: variantColor,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: variantColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernCloseButton({required this.onPressed});

  @override
  _ModernCloseButtonState createState() => _ModernCloseButtonState();
}

class _ModernCloseButtonState extends State<_ModernCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClientInfoCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ClientInfoCard({
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildEmptyClientCard();
    }

    final fullName =
        ((user.firstName ?? '') + ' ' + (user.lastName ?? '')).trim().isEmpty
            ? 'Nom non défini'
            : ((user.firstName ?? '') + ' ' + (user.lastName ?? '')).trim();

    return Row(
      children: [
        // Avatar du client
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              fullName[0].toUpperCase(),
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),

        // Informations du client
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              if (user.phone != null && user.phone.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      user.phone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
              ],
              if (user.email != null && user.email.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyClientCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color:
            (isDark ? AppColors.gray700 : AppColors.gray200).withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color:
              (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_off,
            size: 32,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucun client associé',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Cette commande n\'a pas de client défini',
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
}
