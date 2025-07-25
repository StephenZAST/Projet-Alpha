import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../constants.dart';
import '../../../services/order_service.dart';
import 'address_selection_map.dart';

class AddressEditDialog extends StatefulWidget {
  final Address? address;
  final String orderId;
  const AddressEditDialog({Key? key, this.address, required this.orderId})
      : super(key: key);

  @override
  State<AddressEditDialog> createState() => _AddressEditDialogState();
}

class _AddressEditDialogState extends State<AddressEditDialog> {
  late TextEditingController nameController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController postalCodeController;
  late double? latitude;
  late double? longitude;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.address?.name ?? '');
    streetController =
        TextEditingController(text: widget.address?.street ?? '');
    cityController = TextEditingController(text: widget.address?.city ?? '');
    postalCodeController =
        TextEditingController(text: widget.address?.postalCode ?? '');
    latitude = widget.address?.gpsLatitude;
    longitude = widget.address?.gpsLongitude;
  }

  @override
  void dispose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  void _onAddressSelected(Address address) {
    setState(() {
      nameController.text = address.name ?? '';
      streetController.text = address.street;
      cityController.text = address.city;
      postalCodeController.text = address.postalCode ?? '';
      latitude = address.gpsLatitude;
      longitude = address.gpsLongitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Modifier l\'adresse',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AddressSelectionMap(
                initialAddress: widget.address,
                onAddressSelected: _onAddressSelected,
                onAddNewAddress: () {
                  // TODO: ouvrir un dialogue pour ajouter une nouvelle adresse
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Rue'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Ville'),
              ),
              TextField(
                controller: postalCodeController,
                decoration: InputDecoration(labelText: 'Code postal'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text('GPS : ${latitude ?? '-'}, ${longitude ?? '-'}',
                      style: AppTextStyles.bodySmallSecondary),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    label: 'Enregistrer',
                    variant: GlassButtonVariant.primary,
                    onPressed: () async {
                      final addressData = {
                        'id': widget.address?.id ?? '',
                        'name': nameController.text,
                        'street': streetController.text,
                        'city': cityController.text,
                        'postalCode': postalCodeController.text,
                        'gpsLatitude': latitude,
                        'gpsLongitude': longitude,
                        'isDefault': widget.address?.isDefault ?? false,
                        'userId': widget.address?.userId ?? '',
                      };
                      // Appel PATCH vers le backend
                      final success = await OrderService.updateOrderAddress(
                          widget.orderId, addressData);
                      if (success) {
                        Get.snackbar(
                          'Succès',
                          'Adresse modifiée avec succès',
                          backgroundColor: AppColors.success,
                          colorText: AppColors.textLight,
                          snackPosition: SnackPosition.TOP,
                          duration: Duration(seconds: 2),
                        );
                        final updated = Address(
                          id: widget.address?.id ?? '',
                          name: nameController.text,
                          street: streetController.text,
                          city: cityController.text,
                          postalCode: postalCodeController.text,
                          gpsLatitude: latitude,
                          gpsLongitude: longitude,
                          isDefault: widget.address?.isDefault ?? false,
                          createdAt:
                              widget.address?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                          userId: widget.address?.userId ?? '',
                        );
                        Navigator.of(context).pop(updated);
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Échec de la modification de l\'adresse',
                          backgroundColor: AppColors.error,
                          colorText: AppColors.textLight,
                          snackPosition: SnackPosition.TOP,
                          duration: Duration(seconds: 3),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
