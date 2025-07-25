import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/screens/orders/new_order/components/client_details_dialog.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/order_items_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import '../../../models/order.dart';
import '../../../constants.dart';

class OrderDetailsDialog extends StatefulWidget {
  final Order order;
  const OrderDetailsDialog({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    // Format: yyyy-MM-dd HH:mm
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  late TextEditingController totalAmountController;
  late TextEditingController affiliateCodeController;
  late TextEditingController statusController;
  late TextEditingController paymentMethodController;
  late TextEditingController collectionDateController;
  late TextEditingController deliveryDateController;
  // Ajoute d'autres contrôleurs selon les besoins

  @override
  void initState() {
    super.initState();
    _refreshControllers(widget.order);
    // Écoute les changements sur la commande sélectionnée pour rafraîchir l'affichage
    final OrdersController ordersController = Get.find<OrdersController>();
    ever<Order?>(ordersController.selectedOrder, (order) {
      if (order != null && order.id == widget.order.id) {
        setState(() {
          _refreshControllers(order);
        });
      }
    });
  }

  void _refreshControllers(Order order) {
    totalAmountController =
        TextEditingController(text: order.totalAmount.toString());
    affiliateCodeController =
        TextEditingController(text: order.affiliateCode ?? '');
    statusController = TextEditingController(text: order.status);
    paymentMethodController =
        TextEditingController(text: order.paymentMethod.name);
    collectionDateController =
        TextEditingController(text: order.collectionDate?.toString() ?? '');
    deliveryDateController =
        TextEditingController(text: order.deliveryDate?.toString() ?? '');
    // ... autres contrôleurs
  }

  @override
  void dispose() {
    totalAmountController.dispose();
    affiliateCodeController.dispose();
    statusController.dispose();
    paymentMethodController.dispose();
    collectionDateController.dispose();
    deliveryDateController.dispose();
    // ... autres dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Détails de la commande',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildGeneralInfoForm(),
              const SizedBox(height: 24),
              _buildClientSection(),
              const SizedBox(height: 24),
              _buildAddressSection(),
              const SizedBox(height: 24),
              _buildOrderItemsSection(),
              const SizedBox(height: 24),
              _buildActionsSection(),
              const SizedBox(height: 32),
              GlassButton(
                label: 'Enregistrer les modifications',
                variant: GlassButtonVariant.primary,
                onPressed: _saveOrderInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations générales',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: totalAmountController,
          decoration: InputDecoration(labelText: 'Montant total'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: affiliateCodeController,
          decoration: InputDecoration(labelText: 'Code affilié'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: statusController,
          decoration: InputDecoration(labelText: 'Statut'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: paymentMethodController.text.isNotEmpty
              ? paymentMethodController.text
              : 'CASH',
          decoration: InputDecoration(labelText: 'Méthode de paiement'),
          items: const [
            DropdownMenuItem(value: 'CASH', child: Text('Espèces')),
            DropdownMenuItem(
                value: 'ORANGE_MONEY', child: Text('Mobile Money')),
          ],
          onChanged: (value) {
            if (value != null) {
              paymentMethodController.text = value;
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: widget.order.collectionDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: widget.order.collectionDate != null
                    ? TimeOfDay.fromDateTime(widget.order.collectionDate!)
                    : TimeOfDay.now(),
              );
              if (time != null) {
                final dt = DateTime(picked.year, picked.month, picked.day,
                    time.hour, time.minute);
                collectionDateController.text = _formatDateTime(dt);
                setState(() {});
              }
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: collectionDateController,
              decoration: InputDecoration(labelText: 'Date de collecte'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: widget.order.deliveryDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: widget.order.deliveryDate != null
                    ? TimeOfDay.fromDateTime(widget.order.deliveryDate!)
                    : TimeOfDay.now(),
              );
              if (time != null) {
                final dt = DateTime(picked.year, picked.month, picked.day,
                    time.hour, time.minute);
                deliveryDateController.text = _formatDateTime(dt);
                setState(() {});
              }
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: deliveryDateController,
              decoration: InputDecoration(labelText: 'Date de livraison'),
            ),
          ),
        ),
      ],
    );
    // Removed unreachable duplicate widget builder methods to fix dead code and unused declaration errors.
  }

  Future<void> _saveOrderInfo() async {
    // TODO: Appeler le service pour mettre à jour la commande
    // Afficher un snackbar de succès
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(child: Text('Informations commande mises à jour')),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  Widget _buildClientSection() {
    final user = widget.order.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainTextColor =
        isDark ? AppColors.textLight : AppColors.textPrimary;
    final Color secondaryTextColor =
        isDark ? AppColors.gray200 : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client associé',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: mainTextColor)),
                const SizedBox(height: 8),
                Text('Nom : ${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: mainTextColor)),
                Text('Email : ${user?.email ?? ''}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: secondaryTextColor)),
                Text('Téléphone : ${user?.phone ?? ''}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: secondaryTextColor)),
                const SizedBox(height: 8),
                GlassButton(
                  label: 'Voir / Modifier le client',
                  icon: Icons.edit,
                  variant: GlassButtonVariant.secondary,
                  onPressed: () async {
                    // Ouvre le dialog client (User non-null requis)
                    if (user != null) {
                      await Get.dialog(ClientDetailsDialog(client: user));
                    } else {
                      Get.rawSnackbar(
                        messageText:
                            Text('Aucun client associé à cette commande.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    final address = widget.order.address;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(color: AppColors.info.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: AppColors.info, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adresse de livraison',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Nom : ${address?.name ?? ''}',
                    style: AppTextStyles.bodyMedium),
                Text('Rue : ${address?.street ?? ''}',
                    style: AppTextStyles.bodySmallSecondary),
                Text('Ville : ${address?.city ?? ''}',
                    style: AppTextStyles.bodySmallSecondary),
                Text('Code postal : ${address?.postalCode ?? ''}',
                    style: AppTextStyles.bodySmallSecondary),
                Text(
                    'GPS : ${address?.gpsLatitude ?? ''}, ${address?.gpsLongitude ?? ''}',
                    style: AppTextStyles.bodySmallSecondary),
                const SizedBox(height: 8),
                GlassButton(
                  label: 'Voir / Modifier l\'adresse',
                  icon: Icons.edit_location_alt,
                  variant: GlassButtonVariant.info,
                  onPressed: () async {
                    if (address != null) {
                      final controller = Get.find<OrdersController>();
                      await Get.dialog(OrderAddressDialog(
                        initialAddress: address,
                        orderId: widget.order.id,
                        onAddressSaved: (updatedAddress) async {
                          await controller.fetchOrderDetails(widget.order.id);
                          setState(() {});
                        },
                      ));
                    } else {
                      Get.rawSnackbar(
                        messageText: Text(
                            'Impossible d\'éditer l\'adresse : informations manquantes.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    final items = widget.order.items ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(color: AppColors.success.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shopping_cart, color: AppColors.success, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Articles / Services',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  Text('Aucun article/service dans la commande',
                      style: AppTextStyles.bodySmallSecondary)
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
                          Expanded(
                              child: Text(item.article?.name ?? '',
                                  style: AppTextStyles.bodyMedium)),
                          Text('x${item.quantity}',
                              style: AppTextStyles.bodySmallSecondary),
                          Text('${item.unitPrice} FCFA',
                              style: AppTextStyles.bodySmallSecondary),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 8),
                GlassButton(
                  label: 'Voir / Modifier les articles/services',
                  icon: Icons.edit,
                  variant: GlassButtonVariant.success,
                  onPressed: () async {
                    // Ouvre le dialog d'édition des articles/services
                    await Get.dialog(
                      OrderItemsEditDialog(items: items),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        GlassButton(
          label: 'Annuler la commande',
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
        // ... autres actions rapides
      ],
    );
  }
}

/* Removed duplicate _buildOrderItemsSection function that caused 'Undefined name widget' error. */
