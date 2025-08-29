import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/models/address.dart';
import 'package:admin/services/address_service.dart';
import 'package:flutter/material.dart';

class FlashAddressStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashAddressStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashAddressStep> createState() => _FlashAddressStepState();
}

class _FlashAddressStepState extends State<FlashAddressStep> {
  List<Address> addresses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    final userId = widget.controller.draft.value.userId;
    if (userId != null) {
      addresses = await AddressService.getAddressesByUser(userId);
    }
    setState(() => isLoading = false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final selectedAddressId = widget.controller.draft.value.addressId;
    Address? selectedAddress;
    if (addresses.isNotEmpty) {
      selectedAddress = addresses.firstWhere(
        (a) => a.id == selectedAddressId,
        orElse: () => addresses.first,
      );
    }

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
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
                Text('Aucune adresse disponible ou sélectionnée.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.edit_location_alt),
                label: Text('Choisir ou modifier l\'adresse'),
                onPressed: () async {
                  final initialAddress = selectedAddress ??
                      (addresses.isNotEmpty ? addresses.first : null);
                  if (initialAddress != null) {
                    await _openAddressDialog(context, initialAddress);
                  }
                },
              ),
            ],
          );
  }

  Future<void> _openAddressDialog(
      BuildContext context, dynamic initialAddress) async {
    // TODO: Remplacer par le dialog adapté pour le flow flash
    // Après sélection, mettre à jour le draft flash
    // Exemple : controller.setDraftField('addressId', address.id);
  }
}
