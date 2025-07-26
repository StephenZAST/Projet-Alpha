import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/screens/orders/new_order/components/client_details_dialog.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/order_items_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import '../../../models/order.dart';
import '../../../constants.dart';
import '../../../models/enums.dart';

class OrderDetailsDialog extends StatelessWidget {
  Widget _buildClientSection(order) {
    final user = order.user;
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
                Text('Client associé',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Nom : ${user?.firstName ?? ''} ${user?.lastName ?? ''}'),
                Text('Email : ${user?.email ?? ''}'),
                Text('Téléphone : ${user?.phone ?? ''}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlassButton(
            label: 'Modifier',
            icon: Icons.edit,
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

  Widget _buildOrderItemsSection(order) {
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
                label: 'Modifier',
                icon: Icons.edit,
                variant: GlassButtonVariant.success,
                onPressed: () async {
                  // Ouvre le dialog d'édition des articles/services (stateless)
                  // Tu peux ici ouvrir un dialog dédié si besoin
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.article?.name ?? '')),
                    Text('x${item.quantity}'),
                    Text('${item.unitPrice} FCFA'),
                  ],
                );
              },
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
              Text('Détails de la commande',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('ID : ${order.id}'),
              const SizedBox(height: 16),
              // Montant total
              Obx(() => TextField(
                    decoration: InputDecoration(labelText: 'Montant total'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        controller.setOrderEditField('totalAmount', v),
                    controller: TextEditingController(
                        text: controller.orderEditForm['totalAmount'] ?? '')
                      ..selection = TextSelection.collapsed(
                          offset:
                              (controller.orderEditForm['totalAmount'] ?? '')
                                  .toString()
                                  .length),
                  )),
              const SizedBox(height: 16),
              // Code affilié
              Obx(() => TextField(
                    decoration: InputDecoration(labelText: 'Code affilié'),
                    onChanged: (v) =>
                        controller.setOrderEditField('affiliateCode', v),
                    controller: TextEditingController(
                        text: controller.orderEditForm['affiliateCode'] ?? '')
                      ..selection = TextSelection.collapsed(
                          offset:
                              (controller.orderEditForm['affiliateCode'] ?? '')
                                  .toString()
                                  .length),
                  )),
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
                    onPressed: () async {
                      // Appel du controller pour sauvegarder
                      await controller.updateOrder(order.id, {
                        'totalAmount': controller.orderEditForm['totalAmount'],
                        'affiliateCode':
                            controller.orderEditForm['affiliateCode'],
                        'status': controller.orderEditForm['status'],
                        'paymentMethod':
                            controller.orderEditForm['paymentMethod'],
                        'collectionDate': controller
                            .orderEditForm['collectionDate']
                            ?.toIso8601String(),
                        'deliveryDate': controller.orderEditForm['deliveryDate']
                            ?.toIso8601String(),
                        // Ajoute d'autres champs si besoin
                      });
                      controller.clearOrderEditForm();
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
              _buildOrderItemsSection(controller.selectedOrder.value),
              const SizedBox(height: 24),
              _buildActionsSection(controller.selectedOrder.value, controller),
            ],
          ),
        ),
      );
    });
  }
}
