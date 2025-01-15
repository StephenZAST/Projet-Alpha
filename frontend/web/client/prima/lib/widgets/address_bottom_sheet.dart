import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// Importer LatLng de latlong2 avec un alias
import 'package:latlong2/latlong.dart' as latlong2;
// Importer LatLng de mapbox_gl avec un alias
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import 'package:prima/models/address.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:prima/widgets/address_list_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:prima/widgets/address/address_form.dart';
import 'package:prima/widgets/address/address_map.dart';

class AddressBottomSheet extends StatefulWidget {
  final Address? address;
  final VoidCallback? onBack;
  final bool isEditing;

  const AddressBottomSheet({
    Key? key,
    this.address,
    this.onBack,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet>
    with SingleTickerProviderStateMixin {
  final _addressNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  // Utiliser le type LatLng de latlong2
  latlong2.LatLng? _selectedLocation;
  bool _isLoading = false;
  late TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.address != null) {
      _addressNameController.text = widget.address!.name;
      _streetController.text = widget.address!.street!;
      _cityController.text = widget.address!.city;
      _postalCodeController.text = widget.address!.postalCode!;
      if (widget.address!.latitude != null &&
          widget.address!.longitude != null) {
        _selectedLocation = latlong2.LatLng(
          widget.address!.latitude!,
          widget.address!.longitude!,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text('Informations'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Localisation'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AddressForm(
                  addressNameController: _addressNameController,
                  streetController: _streetController,
                  cityController: _cityController,
                  postalCodeController: _postalCodeController,
                  onNext: () => _tabController.animateTo(1),
                ),
                AddressMap(
                  selectedLocation: _selectedLocation != null
                      ? mapbox.LatLng(_selectedLocation!.latitude,
                          _selectedLocation!.longitude)
                      : null,
                  mapController: _mapController,
                  onLocationSelected: (location) {
                    setState(() {
                      _selectedLocation = latlong2.LatLng(
                          location.latitude, location.longitude);
                    });
                  },
                  onCurrentLocation: _getCurrentLocation,
                  onSearchAddress: () {},
                  onConfirmLocation: () {
                    final errors = _validateForm();
                    if (errors.isEmpty) {
                      _saveAddress();
                    } else {
                      _showValidationDialog(errors);
                    }
                  },
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack ?? () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            widget.address != null ? 'Modifier l\'adresse' : 'Nouvelle adresse',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('L\'accès à la localisation est nécessaire');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(
            'Veuillez activer la localisation dans les paramètres de l\'appareil');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation =
          latlong2.LatLng(position.latitude, position.longitude);

      // Mettre à jour l'emplacement sélectionné
      setState(() {
        _selectedLocation = newLocation;
      });

      // Déplacer la carte vers le nouvel emplacement
      _mapController.move(newLocation, 15.0);

      // Important: Notifier le widget AddressMap du changement de location
      if (mounted) {
        // Utiliser la callback onLocationSelected pour synchroniser l'état
        setState(() {
          _selectedLocation = newLocation;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Impossible de récupérer la position actuelle');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_validateForm().isEmpty) {
      setState(() => _isLoading = true);
      try {
        final addressProvider = context.read<AddressProvider>();

        if (widget.isEditing && widget.address != null) {
          await addressProvider.updateAddress(
            id: widget.address!.id,
            name: _addressNameController.text,
            street: _streetController.text,
            city: _cityController.text,
            postalCode: _postalCodeController.text,
            latitude: _selectedLocation?.latitude,
            longitude: _selectedLocation?.longitude,
            isDefault: widget.address!.isDefault,
          );
        } else {
          await addressProvider.addAddress(
            name: _addressNameController.text,
            street: _streetController.text,
            city: _cityController.text,
            postalCode: _postalCodeController.text,
            latitude: _selectedLocation?.latitude,
            longitude: _selectedLocation?.longitude,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          if (widget.onBack != null) {
            widget.onBack!();
          }
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de l\'enregistrement');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  List<String> _validateForm() {
    final errors = <String>[];

    if (_addressNameController.text.isEmpty) {
      errors.add('Le nom de l\'adresse est requis');
    }
    if (_cityController.text.isEmpty) {
      errors.add('La ville est requise');
    }
    if (_selectedLocation == null) {
      errors.add('Veuillez sélectionner un emplacement sur la carte');
    }

    return errors;
  }

  void _showValidationDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              const Text('Champs manquants'),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors
                  .map((error) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
