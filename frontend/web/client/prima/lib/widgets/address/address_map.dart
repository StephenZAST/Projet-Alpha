import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/custom_map_marker.dart';
import 'package:spring_button/spring_button.dart';
import 'dart:ui' as ui;

class AddressMap extends StatelessWidget {
  final LatLng? selectedLocation;
  final MapController mapController;
  final VoidCallback onCurrentLocation;
  final VoidCallback onSearchAddress;
  final VoidCallback onConfirmLocation;
  final bool isLoading;

  const AddressMap({
    Key? key,
    this.selectedLocation,
    required this.mapController,
    required this.onCurrentLocation,
    required this.onSearchAddress,
    required this.onConfirmLocation,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: selectedLocation ?? const LatLng(48.8566, 2.3522),
              zoom: selectedLocation != null ? 15.0 : 10.0,
              onTap: (_, point) {
                // setState(() {
                //   _selectedLocation = point;
                // });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.prima',
              ),
              MarkerLayer(
                markers: [
                  if (selectedLocation != null)
                    Marker(
                      width: 80,
                      height: 80,
                      point: selectedLocation!,
                      child: _buildLocationMarker(),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Contrôles de la carte avec fond semi-transparent
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.my_location,
                onTap: onCurrentLocation,
                tooltip: 'Ma position',
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.search,
                onTap: onSearchAddress,
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
            color: Colors.white.withOpacity(0.9),
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            // Cercle externe animé
            Center(
              child: Container(
                width: 60 * value,
                height: 60 * value,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Cercle intermédiaire
            Center(
              child: Container(
                width: 40 * value,
                height: 40 * value,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Marqueur central
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
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
            onTap: isLoading ? null : onConfirmLocation,
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
        if (isLoading)
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
