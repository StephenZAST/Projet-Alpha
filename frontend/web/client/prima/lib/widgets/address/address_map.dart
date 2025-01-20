import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/address/custom_map_marker.dart';
import 'package:spring_button/spring_button.dart';
import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressMap extends StatefulWidget {
  final LatLng? selectedLocation;
  final MapController mapController;
  final Function(LatLng) onLocationSelected;
  final VoidCallback onCurrentLocation;
  final VoidCallback onSearchAddress;
  final VoidCallback onConfirmLocation;
  final bool isLoading;

  const AddressMap({
    Key? key,
    this.selectedLocation,
    required this.mapController,
    required this.onLocationSelected,
    required this.onCurrentLocation,
    required this.onSearchAddress,
    required this.onConfirmLocation,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AddressMap> createState() => _AddressMapState();
}

class _AddressMapState extends State<AddressMap> {
  LatLng? _currentSelectedLocation;

  @override
  void initState() {
    super.initState();
    _currentSelectedLocation = widget.selectedLocation;
  }

  @override
  void didUpdateWidget(AddressMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      setState(() {
        _currentSelectedLocation = widget.selectedLocation;
      });
      _updateMapLocation();
    }
  }

  void _updateMapLocation() {
    if (_currentSelectedLocation != null) {
      widget.mapController.move(
        _currentSelectedLocation!,
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapboxToken = dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '';

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.selectedLocation ??
                const LatLng(5.3484, -4.0305), // Abidjan
            initialZoom: 15,
            onTap: (_, point) {
              widget.onLocationSelected(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
              additionalOptions: {
                'accessToken': mapboxToken,
                'id': 'streets-v11',
              },
            ),
            MarkerLayer(
              markers: [
                if (widget.selectedLocation != null)
                  Marker(
                    point: widget.selectedLocation!,
                    width: 80,
                    height: 80,
                    child: const CustomMapMarker(),
                  ),
              ],
            ),
          ],
        ),
        if (_currentSelectedLocation != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            top: MediaQuery.of(context).size.height * 0.4 - 40,
            child: const CustomMapMarker(),
          ),
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
    return const CustomMapMarker();
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
          const Text(
            'Confirmer l\'emplacement',
            style: TextStyle(
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
