import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:prima/models/address.dart';
import 'dart:ui' as ui;
import 'package:prima/providers/address_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/custom_map_marker.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      _streetController.text = widget.address!.street;
      _cityController.text = widget.address!.city;
      _postalCodeController.text = widget.address!.postalCode;
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
                _buildInformationTab(),
                _buildMapTab(),
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

  Widget _buildAddressForm() {
    return Column(
      children: [
        TextField(
          controller: _addressNameController,
          decoration: InputDecoration(
            labelText: 'Nom de l\'adresse',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _streetController,
          decoration: InputDecoration(
            labelText: 'Rue',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Code postal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation ?? const LatLng(48.8566, 2.3522),
              zoom: _selectedLocation != null ? 15.0 : 10.0,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.prima',
              ),
              MarkerLayer(
                markers: [
                  if (_selectedLocation != null)
                    Marker(
                      width: 50,
                      height: 50,
                      point: _selectedLocation!,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.6 + (0.4 * value),
                            child: _buildAnimatedMarker(),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapButton(
                icon: Icons.my_location,
                onTap: _getCurrentLocation,
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: Icons.search,
                onTap: () {
                  // Implémenter la recherche d'adresse
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.primaryShadow],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInformationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddressForm(),
          const SizedBox(height: 24),
          SpringButton(
            SpringButtonType.OnlyScale,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Passer à la localisation',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMarker() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [AppColors.primaryShadow],
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildAnimatedMarker() {
    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [AppColors.primaryShadow],
              ),
            ),
          ),
        ),
      ],
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
      } catch (e) {
        _showErrorSnackBar('Erreur lors de l\'enregistrement');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    if (_addressNameController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty) {
      _showErrorSnackBar('Veuillez remplir tous les champs');
      return false;
    }
    if (_selectedLocation == null) {
      _showErrorSnackBar('Veuillez sélectionner un emplacement sur la carte');
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              else ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.address != null
                      ? 'Mettre à jour l\'adresse'
                      : 'Confirmer l\'emplacement',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        onTap: _isLoading ? null : _saveAddress,
        scaleCoefficient: 0.95,
      ),
    );
  }
}