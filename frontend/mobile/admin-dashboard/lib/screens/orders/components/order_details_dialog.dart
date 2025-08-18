import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/screens/orders/new_order/components/client_details_dialog.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/order_item_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/controllers/service_type_controller.dart';
import '../../../models/enums.dart';
import 'copy_order_id_row.dart';

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

class OrderDetailsDialog extends StatelessWidget {
  Widget _buildClientSection(order) {
    final user = order.user;
    // final OrdersController controller = Get.find<OrdersController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  user == null
                      ? 'Aucun client'
                      : ((user.firstName ?? '') + ' ' + (user.lastName ?? ''))
                              .trim()
                              .isEmpty
                          ? 'Aucun client'
                          : ((user.firstName ?? '') +
                                  ' ' +
                                  (user.lastName ?? ''))
                              .trim(),
                ),
                Text(user?.phone ?? ''),
                Text(user?.email ?? ''),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlassButton(
            label: 'Voir / Modifier',
            variant: GlassButtonVariant.info,
            onPressed: user == null
                ? null
                : () async {
                    await showDialog(
                      context: Get.context!,
                      builder: (_) => ClientDetailsDialog(client: user),
                    );
                  },
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
          label: 'Dupliquer',
          variant: GlassButtonVariant.info,
          onPressed: () {
            // TODO: Action duplication
          },
        ),
      ],
    );
  }

  final String orderId;
  const OrderDetailsDialog({Key? key, required this.orderId}) : super(key: key);

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    return Obx(() {
      final order = controller.selectedOrder.value;
      if (controller.isLoading.value || order == null || order.id != orderId) {
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
              // Montant total (non modifiable, couleur dynamique)
              Obx(() {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : Colors.black87;
                final bgColor = isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.withOpacity(0.08);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sous-total
                    Text('Sous-total',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.orderEditForm['subtotal']?.toString() ?? '',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Remises (discounts)
                    Text('Remises',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (_) {
                        final discounts = controller.orderEditForm['discounts'];
                        if (discounts is Map) {
                          final entries = discounts.entries.toList();
                          if (entries.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...entries.map<Widget>((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(discountLabel(e.key),
                                              style:
                                                  TextStyle(color: textColor)),
                                          Text('-${e.value} FCFA',
                                              style:
                                                  TextStyle(color: textColor)),
                                        ],
                                      ),
                                    )),
                                Divider(
                                    height: 12,
                                    color: bgColor.withOpacity(0.5)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total remises',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor)),
                                    Text('-${discountTotal(discounts)} FCFA',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor)),
                                  ],
                                ),
                              ],
                            );
                          }
                        }
                        // fallback: simple montant
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (discounts?.toString() ?? '0'),
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Montant total
                    Text('Montant total',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.orderEditForm['totalAmount']?.toString() ??
                            '',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
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
              _buildClientSection(controller.selectedOrder.value),
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
