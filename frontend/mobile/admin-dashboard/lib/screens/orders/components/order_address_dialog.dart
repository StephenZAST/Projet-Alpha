import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/services/address_service.dart';
import 'package:admin/services/order_service.dart';
import 'package:admin/widgets/glass_button.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/address.dart';
import 'package:admin/screens/orders/components/address_selection_map.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';

class OrderAddressDialog extends StatefulWidget {
  final Address initialAddress;
  final String orderId;
  final Function(Address) onAddressSaved;

  const OrderAddressDialog({
    Key? key,
    required this.initialAddress,
    required this.orderId,
    required this.onAddressSaved,
  }) : super(key: key);

  @override
  State<OrderAddressDialog> createState() => _OrderAddressDialogState();
}

class _OrderAddressDialogState extends State<OrderAddressDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Contrôleurs pour les champs d'adresse
  late TextEditingController nameController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController postalCodeController;
  double? latitude;
  double? longitude;

  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    nameController =
        TextEditingController(text: widget.initialAddress.name ?? '');
    streetController =
        TextEditingController(text: widget.initialAddress.street);
    cityController = TextEditingController(text: widget.initialAddress.city);
    postalCodeController =
        TextEditingController(text: widget.initialAddress.postalCode ?? '');
    latitude = widget.initialAddress.gpsLatitude;
    longitude = widget.initialAddress.gpsLongitude;
    selectedAddress = widget.initialAddress;
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildAddressForm(),
                  AddressSelectionMap(
                    initialAddress: selectedAddress ?? widget.initialAddress,
                    onAddressSelected: (address) {
                      setState(() {
                        latitude = address.gpsLatitude;
                        longitude = address.gpsLongitude;
                        selectedAddress = address;
                      });
                    },
                  ),
                  // Onglet adresses du client
                  ClientAddressesTab(
                    userId: widget.initialAddress.userId,
                    selectedAddress: selectedAddress,
                    onAddressSelected: (address) {
                      setState(() {
                        nameController.text = address.name ?? '';
                        streetController.text = address.street;
                        cityController.text = address.city;
                        postalCodeController.text = address.postalCode ?? '';
                        latitude = address.gpsLatitude;
                        longitude = address.gpsLongitude;
                        selectedAddress = address;
                      });
                      _tabController.animateTo(0);
                    },
                    onAddNewAddress: () {
                      _tabController.animateTo(0);
                      nameController.clear();
                      streetController.clear();
                      cityController.clear();
                      postalCodeController.clear();
                      latitude = null;
                      longitude = null;
                      selectedAddress = null;
                      setState(() {});
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
                  onPressed: _onSavePressed,
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

  Future<void> _onSavePressed() async {
    // Validation simple
    if (selectedAddress == null) {
      Get.rawSnackbar(
        messageText: const Text('Veuillez sélectionner une adresse.'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // Toujours PATCH la commande avec l'adresse sélectionnée
      await OrderService.updateOrderAddress(
        widget.orderId,
        selectedAddress!.toJson(),
      );
      // Rafraîchir les détails de la commande ET la liste après modification
      final ordersController = Get.find<OrdersController>();
      await ordersController.fetchOrderDetails(widget.orderId);
      await ordersController.loadOrdersPage(
          status: ordersController.filterStatus.value);
      widget.onAddressSaved(selectedAddress!);
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

  Widget _buildAddressForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: streetController,
            decoration: const InputDecoration(labelText: 'Rue'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(labelText: 'Ville'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: postalCodeController,
            decoration: const InputDecoration(labelText: 'Code postal'),
          ),
          const SizedBox(height: 16),
          Text('Latitude: ${latitude ?? ''}'),
          Text('Longitude: ${longitude ?? ''}'),
        ],
      ),
    );
  }
}
