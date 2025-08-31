// (Déplacement de la fonction helper après les imports)
import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/models/address.dart';
import 'package:admin/services/address_service.dart';
import 'package:admin/widgets/glass_button.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';
import 'package:admin/screens/orders/components/address_selection_map.dart';
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
  Address? selectedAddress;
  bool isLoading = false;
  int _tabIndex = 0;

  // Helper local pour remplacer firstWhereOrNull si non dispo
  T? firstWhereOrNull<T extends Object?>(List<T> list, bool Function(T) test) {
    for (var element in list) {
      if (test(element)) return element;
    }
    return null;
  }

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
      // 1. Si une adresse est déjà définie dans le draft, on la sélectionne (cas flash existant)
      final selectedId = widget.controller.draft.value.addressId;
      if (selectedId != null && addresses.any((a) => a.id == selectedId)) {
        selectedAddress = addresses.firstWhere((a) => a.id == selectedId);
      } else if (addresses.isNotEmpty) {
        // 2. Sinon, on sélectionne l'adresse par défaut ou la première
        final defaultAddress = firstWhereOrNull(
                addresses, (a) => (a as Address).isDefault == true) ??
            addresses.first;
        selectedAddress = defaultAddress;
        widget.controller.draft.value.addressId = defaultAddress.id;
        widget.controller.draft.refresh();
      } else {
        selectedAddress = null;
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedAddressId = widget.controller.draft.value.addressId;
    if (selectedAddressId != null &&
        addresses.any((a) => a.id == selectedAddressId)) {
      selectedAddress = addresses.firstWhere((a) => a.id == selectedAddressId);
    } else if (addresses.isNotEmpty) {
      selectedAddress = addresses.first;
    } else {
      selectedAddress = null;
    }

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adresse de livraison',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              DefaultTabController(
                length: 2,
                initialIndex: _tabIndex,
                child: Column(
                  children: [
                    TabBar(
                      onTap: (i) => setState(() => _tabIndex = i),
                      tabs: const [
                        Tab(text: 'Liste'),
                        Tab(text: 'Carte'),
                      ],
                    ),
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Tab 1: Liste des adresses
                          ClientAddressesTab(
                            userId: widget.controller.draft.value.userId,
                            selectedAddress: selectedAddress,
                            onAddressSelected: (address) {
                              setState(() {
                                selectedAddress = address;
                                widget.controller
                                    .setDraftField('addressId', address.id);
                              });
                            },
                            onAddNewAddress: () async {
                              if (selectedAddress != null) {
                                await _openAddressDialog(
                                    context, selectedAddress!);
                              }
                            },
                          ),
                          // Tab 2: Carte
                          AddressSelectionMap(
                            initialAddress: selectedAddress,
                            onAddressSelected: (address) {
                              setState(() {
                                selectedAddress = address;
                                widget.controller
                                    .setDraftField('addressId', address.id);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GlassButton(
                    icon: Icons.edit_location_alt,
                    label: 'Gérer les adresses',
                    variant: GlassButtonVariant.primary,
                    onPressed: () async {
                      if (selectedAddress != null) {
                        await _openAddressDialog(context, selectedAddress!);
                        await _fetchAddresses();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
  }

  Future<void> _openAddressDialog(
      BuildContext context, Address initialAddress) async {
    await showDialog(
      context: context,
      builder: (ctx) => OrderAddressDialog(
        initialAddress: initialAddress,
        orderId: '', // Pas d'orderId pour le flow flash
        onAddressSaved: (address) async {
          widget.controller.setDraftField('addressId', address.id);
          await _fetchAddresses(); // Rafraîchir la liste après modification
        },
      ),
    );
  }
}
