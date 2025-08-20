import 'package:admin/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../components/order_address_dialog.dart';
import '../../../../../models/address.dart';

class OrderAddressStep extends StatelessWidget {
  final OrdersController controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final addresses = controller.clientAddresses;
      // Sélection automatique stricte de l'adresse par défaut (et MAJ OrderDraft) si aucune sélection
      if ((controller.selectedAddressId.value == null ||
              controller.orderDraft.value.addressId == null) &&
          addresses.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final defaultAddress =
              addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
          controller.selectAddress(defaultAddress.id);
          controller.setSelectedAddress(defaultAddress.id);
        });
      }
      final selectedAddress = addresses
          .firstWhereOrNull((a) => a.id == controller.selectedAddressId.value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adresse de livraison',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (selectedAddress != null)
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.teal),
                title: Text(selectedAddress.name ?? ''),
                subtitle: Text(selectedAddress.fullAddress),
                trailing: IconButton(
                  icon: Icon(Icons.edit_location_alt),
                  onPressed: () async {
                    await _openAddressDialog(context, selectedAddress);
                  },
                ),
              ),
            )
          else
            Text('Aucune adresse sélectionnée.'),
          const SizedBox(height: 16),
          GlassButton(
            icon: Icons.edit_location_alt,
            label: 'Choisir ou modifier l\'adresse',
            variant: GlassButtonVariant.primary,
            onPressed: () async {
              final clientId = controller.selectedClientId.value;
              if (clientId == null) return;
              final initialAddress = selectedAddress ??
                  (controller.clientAddresses.isNotEmpty
                      ? controller.clientAddresses.first
                      : Address.empty(userId: clientId));
              await _openAddressDialog(context, initialAddress);
            },
          ),
        ],
      );
    });
  }

  Future<void> _openAddressDialog(
      BuildContext context, Address initialAddress) async {
    final orderId = controller.currentOrderId.value ?? '';
    await showDialog(
      context: context,
      builder: (ctx) => OrderAddressDialog(
        initialAddress: initialAddress,
        orderId: orderId,
        onAddressSaved: (address) {
          controller.selectAddress(address.id);
          controller.setSelectedAddress(address.id); // MAJ OrderDraft
        },
      ),
    );
  }
}
