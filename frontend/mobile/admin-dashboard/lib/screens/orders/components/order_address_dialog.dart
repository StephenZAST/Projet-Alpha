import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/widgets/glass_button.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/address.dart';
import 'package:admin/screens/orders/components/address_selection_map.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';

class OrderAddressDialog extends StatefulWidget {
  final Address initialAddress;
  final String orderId;
  final Function(Address)? onAddressSaved;

  const OrderAddressDialog({
    Key? key,
    required this.initialAddress,
    required this.orderId,
    this.onAddressSaved,
  }) : super(key: key);

  @override
  State<OrderAddressDialog> createState() => _OrderAddressDialogState();
}

class _OrderAddressDialogState extends State<OrderAddressDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final OrdersController controller = Get.find<OrdersController>();
    if (controller.orderAddressEditForm.isEmpty) {
      controller.loadOrderAddressEditForm(widget.initialAddress);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    return Dialog(
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Détails'),
                Tab(text: 'Carte'),
                Tab(text: 'Adresses du client'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAddressForm(controller),
                  AddressSelectionMap(
                    initialAddress: widget.initialAddress,
                    onAddressSelected: (address) {
                      controller.loadOrderAddressEditForm(address);
                    },
                  ),
                  ClientAddressesTab(
                    userId: widget.initialAddress.userId,
                    selectedAddress: _addressFromForm(controller),
                    onAddressSelected: (address) {
                      controller.loadOrderAddressEditForm(address);
                      _tabController.animateTo(0);
                    },
                    onAddNewAddress: () {
                      controller.clearOrderAddressEditForm();
                      _tabController.animateTo(0);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  label: 'Enregistrer',
                  variant: GlassButtonVariant.primary,
                  onPressed: () async {
                    await _onSavePressed(context, controller);
                  },
                ),
                const SizedBox(width: 12),
                GlassButton(
                  label: 'Retour',
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm(OrdersController controller) {
    return Obx(() => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nom'),
                onChanged: (v) =>
                    controller.setOrderAddressEditField('name', v),
                controller: TextEditingController(
                  text: controller.orderAddressEditForm['name'] ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Rue'),
                onChanged: (v) =>
                    controller.setOrderAddressEditField('street', v),
                controller: TextEditingController(
                  text: controller.orderAddressEditForm['street'] ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Ville'),
                onChanged: (v) =>
                    controller.setOrderAddressEditField('city', v),
                controller: TextEditingController(
                  text: controller.orderAddressEditForm['city'] ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Code postal'),
                onChanged: (v) =>
                    controller.setOrderAddressEditField('postalCode', v),
                controller: TextEditingController(
                  text: controller.orderAddressEditForm['postalCode'] ?? '',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  'Latitude: ${controller.orderAddressEditForm['gpsLatitude'] ?? ''}'),
              Text(
                  'Longitude: ${controller.orderAddressEditForm['gpsLongitude'] ?? ''}'),
            ],
          ),
        ));
  }

  Address _addressFromForm(OrdersController controller) {
    // Fournit tous les champs requis pour Address
    return Address(
      id: controller.orderAddressEditForm['id'] ?? '',
      name: controller.orderAddressEditForm['name'] ?? '',
      street: controller.orderAddressEditForm['street'] ?? '',
      city: controller.orderAddressEditForm['city'] ?? '',
      postalCode: controller.orderAddressEditForm['postalCode'] ?? '',
      gpsLatitude: controller.orderAddressEditForm['gpsLatitude'],
      gpsLongitude: controller.orderAddressEditForm['gpsLongitude'],
      userId: controller.orderAddressEditForm['userId'] ?? '',
      isDefault: controller.orderAddressEditForm['isDefault'] ?? false,
      createdAt: controller.orderAddressEditForm['createdAt'] ?? DateTime.now(),
      updatedAt: controller.orderAddressEditForm['updatedAt'] ?? DateTime.now(),
    );
  }

  Future<void> _onSavePressed(
      BuildContext context, OrdersController controller) async {
    // Validation simple
    if ((controller.orderAddressEditForm['street'] ?? '').isEmpty) {
      Get.rawSnackbar(
        messageText: const Text('Veuillez renseigner une adresse valide.'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    try {
      await controller.updateOrderAddress(widget.orderId,
          Map<String, dynamic>.from(controller.orderAddressEditForm));
      if (widget.onAddressSaved != null) {
        widget.onAddressSaved!(_addressFromForm(controller));
      }
      Navigator.of(context).pop();
      Get.rawSnackbar(
        messageText: const Text('Adresse enregistrée avec succès.'),
        backgroundColor: Colors.green,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.rawSnackbar(
        messageText: Text('Erreur lors de la sauvegarde : $e'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
