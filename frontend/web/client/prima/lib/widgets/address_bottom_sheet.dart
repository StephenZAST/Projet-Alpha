import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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

  const AddressBottomSheet({
    Key? key,
    this.address,
    this.onBack,
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
  LatLng? _selectedLocation;
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
        _selectedLocation = LatLng(
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
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.primaryShadow],
            ),
            tabs: const [
              Tab(text: 'Informations'),
              Tab(text: 'Localisation'),
            ],
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
                  selectedLocation: _selectedLocation,
                  mapController: _mapController,
                  onCurrentLocation: _getCurrentLocation,
                  onSearchAddress: () {},
                  onConfirmLocation: _saveAddress,
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
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation!, 15.0);
      });
    } catch (e) {
      _showErrorSnackBar('Impossible de récupérer la position actuelle');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_validateForm()) {
      setState(() => _isLoading = true);
      try {
        final addressProvider = context.read<AddressProvider>();
        if (widget.address != null) {
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
            isDefault: false,
          );
        }
        Navigator.pop(context);
        BottomSheetManager().showCustomBottomSheet(
          context: context,
          builder: (context) => AddressListBottomSheet(
            onSelected: (selectedAddress) {
              // Handle the selected address if needed
            },
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Erreur lors de l\'enregistrement');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    List<String> errors = [];

    if (_addressNameController.text.isEmpty) {
      errors.add('Le nom de l\'adresse est requis');
    }

    if (_cityController.text.isEmpty) {
      errors.add('La ville est requise');
    }

    if (_selectedLocation == null) {
      errors.add('La localisation GPS est requise');
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Champs requis manquants'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors
                  .map((error) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(error)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
