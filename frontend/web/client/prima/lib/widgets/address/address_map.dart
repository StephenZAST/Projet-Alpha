import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/address/custom_map_marker.dart';
import 'package:spring_button/spring_button.dart';
import 'dart:ui' as ui;

class AddressMap extends StatefulWidget {
  // Changed to StatefulWidget
  final LatLng? selectedLocation;
  final MapController mapController;
  final Function(LatLng) onLocationSelected; // Added callback
  final VoidCallback onCurrentLocation;
  final VoidCallback onSearchAddress;
  final VoidCallback onConfirmLocation;
  final bool isLoading;

  const AddressMap({
    Key? key,
    this.selectedLocation,
    required this.mapController,
    required this.onLocationSelected, // New required parameter
    required this.onCurrentLocation,
    required this.onSearchAddress,
    required this.onConfirmLocation,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AddressMap> createState() => _AddressMapState();
}

class _AddressMapState extends State<AddressMap> {
  MapboxMapController? _mapboxController;
  LatLng? _currentSelectedLocation;

  @override
  void initState() {
    super.initState();
    _currentSelectedLocation = widget.selectedLocation;
  }

  @override
  void didUpdateWidget(AddressMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour _currentSelectedLocation quand selectedLocation change
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      setState(() {
        _currentSelectedLocation = widget.selectedLocation;
      });
      _updateMapLocation();
    }
  }

  void _updateMapLocation() {
    if (_currentSelectedLocation != null && _mapboxController != null) {
      _mapboxController!.moveCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentSelectedLocation!.latitude,
              _currentSelectedLocation!.longitude),
          15.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: MapboxMap(
            accessToken: 'VOTRE_TOKEN_MAPBOX',
            initialCameraPosition: CameraPosition(
              target: _currentSelectedLocation ?? const LatLng(48.8566, 2.3522),
              zoom: 15.0,
            ),
            onMapCreated: (MapboxMapController controller) {
              _mapboxController = controller;
            },
            onMapClick: (Point<double> point, LatLng coordinates) {
              setState(() {
                _currentSelectedLocation = coordinates;
              });
              widget.onLocationSelected(coordinates);
            },
            styleString: 'mapbox://styles/mapbox/streets-v11',
          ),
        ),
        if (_currentSelectedLocation != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            top: MediaQuery.of(context).size.height * 0.4 - 40,
            child: const CustomMapMarker(),
          ),
        // Contrôles de la carte avec fond semi-transparent
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.my_location,
                onTap: widget.onCurrentLocation,
                tooltip: 'Ma position',
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.search,
                onTap: widget.onSearchAddress,
                tooltip: 'Rechercher une adresse',
              ),
            ],
          ),
        ),
        // Bouton de confirmation avec fond semi-transparent
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildConfirmationButton(context),
        ),
      ],
    );
  }

  void updateLocation(LatLng location) {
    setState(() {
      _currentSelectedLocation = location;
    });
    widget.onLocationSelected(location);
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            gradient: AppColors.primaryGradient.scale(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: onTap,
        scaleCoefficient: 0.95,
      ),
    );
  }

  Widget _buildLocationMarker() {
    return const CustomMapMarker(); // Utiliser le composant existant au lieu de recréer l'animation
  }

  Widget _buildConfirmationButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SpringButton(
            SpringButtonType.OnlyScale,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.scale(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildSaveButtonContent(),
            ),
            onTap: widget.isLoading ? null : widget.onConfirmLocation,
            scaleCoefficient: 0.95,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
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
            'Confirmer l\'emplacement',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
