import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/address.dart';
import '../../../controllers/address_controller.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../orders/components/address_selection_map.dart';

class AddressEditDialog extends StatefulWidget {
  final Address? initialAddress;
  final String userId;
  final void Function(Address) onAddressSaved;

  const AddressEditDialog({
    Key? key,
    this.initialAddress,
    required this.userId,
    required this.onAddressSaved,
  }) : super(key: key);

  @override
  State<AddressEditDialog> createState() => _AddressEditDialogState();
}

class _AddressEditDialogState extends State<AddressEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _gpsController = TextEditingController();
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _nameController.text = widget.initialAddress!.name ?? '';
      _cityController.text = widget.initialAddress!.city;
      _streetController.text = widget.initialAddress!.street;
      _postalCodeController.text = widget.initialAddress!.postalCode ?? '';
      _latitude = widget.initialAddress!.gpsLatitude;
      _longitude = widget.initialAddress!.gpsLongitude;
      if (_latitude != null && _longitude != null) {
        _gpsController.text = '$_latitude,$_longitude';
      }
    }
  }

  void _onPasteGps() {
    final text = _gpsController.text.trim();
    final parts = text.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0]);
      final lng = double.tryParse(parts[1]);
      if (lat != null && lng != null) {
        setState(() {
          _latitude = lat;
          _longitude = lng;
        });
        Get.snackbar('Coordonnées GPS', 'Coordonnées appliquées à la carte',
            backgroundColor: AppColors.success, colorText: Colors.white);
      } else {
        Get.snackbar('Erreur', 'Coordonnées GPS invalides',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Erreur', 'Format attendu: latitude,longitude',
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() ||
        _latitude == null ||
        _longitude == null) {
      Get.snackbar('Erreur',
          'Veuillez remplir tous les champs et sélectionner un emplacement sur la carte.',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    final addressData = {
      'user_id': widget.userId,
      'name': _nameController.text,
      'city': _cityController.text,
      'street': _streetController.text,
      'postal_code': _postalCodeController.text,
      'gps_latitude': _latitude,
      'gps_longitude': _longitude,
      'is_default': true,
    };
    final addressController = Get.find<AddressController>();
    final address = await addressController.createAddress(addressData);
    if (address != null) {
      widget.onAddressSaved(address);
      Get.back();
      Get.snackbar('Succès', 'Adresse enregistrée',
          backgroundColor: AppColors.success, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajouter / Modifier l\'adresse', style: AppTextStyles.h3),
                SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'Nom de l\'adresse (ex: Domicile, Bureau)'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nom requis' : null,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'Ville'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ville requise' : null,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(labelText: 'Rue'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Rue requise' : null,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(labelText: 'Code postal'),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gpsController,
                        decoration: InputDecoration(
                            labelText: 'Coordonnées GPS (lat,lon)'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    GlassButton(
                      label: 'Utiliser',
                      variant: GlassButtonVariant.info,
                      onPressed: _onPasteGps,
                      size: GlassButtonSize.small,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Text('Sélectionner l\'emplacement sur la carte :',
                    style: AppTextStyles.bodyMedium),
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 220,
                  child: AddressSelectionMap(
                    initialAddress: _latitude != null && _longitude != null
                        ? Address(
                            id: '',
                            name: _nameController.text,
                            city: _cityController.text,
                            street: _streetController.text,
                            userId: widget.userId,
                            isDefault: true,
                            postalCode: _postalCodeController.text,
                            gpsLatitude: _latitude,
                            gpsLongitude: _longitude,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          )
                        : null,
                    onAddressSelected: (address) {
                      setState(() {
                        _latitude = address.gpsLatitude;
                        _longitude = address.gpsLongitude;
                        _gpsController.text =
                            '${address.gpsLatitude},${address.gpsLongitude}';
                      });
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                    SizedBox(width: AppSpacing.md),
                    GlassButton(
                      label: 'Enregistrer',
                      variant: GlassButtonVariant.primary,
                      onPressed: _onSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
