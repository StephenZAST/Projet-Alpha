// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../controllers/address_controller.dart';
import 'improved_map_widget.dart';

class AddressSelectionMap extends StatefulWidget {
  final Address? initialAddress;
  final Function(Address) onAddressSelected;
  final VoidCallback? onAddNewAddress;

  const AddressSelectionMap({
    Key? key,
    this.initialAddress,
    required this.onAddressSelected,
    this.onAddNewAddress,
  }) : super(key: key);

  @override
  _AddressSelectionMapState createState() => _AddressSelectionMapState();
}

class _AddressSelectionMapState extends State<AddressSelectionMap> {
  final MapController _mapController = MapController();
  Address? _selectedAddress;
  final addressController = Get.find<AddressController>();

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedAddress?.gpsLatitude != null &&
          _selectedAddress?.gpsLongitude != null) {
        _centerOnAddress(_selectedAddress!);
      }
    });
  }

  void _centerOnAddress(Address address) {
    if (address.gpsLatitude != null && address.gpsLongitude != null) {
      _mapController.move(
        LatLng(address.gpsLatitude!, address.gpsLongitude!),
        15.0,
      );
    }
  }

  double _currentZoom = 13.0;
  final double _minZoom = 3.0;
  final double _maxZoom = 19.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Carte améliorée et robuste
                      ImprovedMapWidget(
                        height: 320,
                        initialCenter: _selectedAddress?.gpsLatitude != null
                            ? LatLng(
                                _selectedAddress!.gpsLatitude!,
                                _selectedAddress!.gpsLongitude!,
                              )
                            : const LatLng(12.3714, -1.5197), // Ouagadougou par défaut
                        initialZoom: 15.0,
                        markers: [
                          if (_selectedAddress != null &&
                              _selectedAddress!.gpsLatitude != null &&
                              _selectedAddress!.gpsLongitude != null)
                            Marker(
                              point: LatLng(
                                _selectedAddress!.gpsLatitude!,
                                _selectedAddress!.gpsLongitude!,
                              ),
                              width: 40,
                              height: 50,
                              builder: (context) => _ModernMapMarker(
                                color: AppColors.primary,
                                borderColor: AppColors.primary.withOpacity(0.8),
                                isSelected: true,
                              ),
                            ),
                        ],
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture && position.zoom != null) {
                            setState(() {
                              _currentZoom = position.zoom!;
                            });
                          }
                        },
                        showZoomControls: true,
                        showAttribution: true,
                        mapTheme: 'auto',
                      ),

                      // Boutons overlay (ajout et centrer)
                      Positioned(
                        top: 16,
                        right: 60, // Décalé pour éviter les contrôles de zoom
                        child: Column(
                          children: [
                            if (widget.onAddNewAddress != null)
                              _GlassyMapButton(
                                icon: Icons.add_location_alt,
                                label: 'Nouvelle',
                                onPressed: widget.onAddNewAddress!,
                              ),
                            if (_selectedAddress != null) ...[
                              const SizedBox(height: 8),
                              _GlassyMapButton(
                                icon: Icons.center_focus_strong,
                                label: 'Centrer',
                                onPressed: () => _centerOnAddress(_selectedAddress!),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Card d'adresse épurée et moderne
                      if (_selectedAddress != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _buildAddressCard(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Liste d'adresses retirée pour simplifier l'UX, la gestion se fera dans un onglet dédié.
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône d'adresse
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          
          // Informations d'adresse
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedAddress?.name ?? 'Sans nom',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedAddress?.street != null) ...[
                  SizedBox(height: 2),
                  Text(
                    _selectedAddress!.street,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_selectedAddress?.city != null || _selectedAddress?.postalCode != null) ...[
                  SizedBox(height: 2),
                  Text(
                    [
                      _selectedAddress?.city,
                      _selectedAddress?.postalCode,
                    ].where((e) => e != null && e.isNotEmpty).join(' '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Bouton Google Maps
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openInGoogleMaps(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.info,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openInGoogleMaps() {
    final lat = _selectedAddress?.gpsLatitude;
    final lng = _selectedAddress?.gpsLongitude;
    if (lat != null && lng != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      try {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir Google Maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    }
  }
}

// Marqueur moderne type Google Maps (pointu)
class _ModernMapMarker extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool isSelected;
  const _ModernMapMarker({
    required this.color,
    required this.borderColor,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 40),
      painter: _MapMarkerPainter(
          color: color, borderColor: borderColor, isSelected: isSelected),
    );
  }
}

class _MapMarkerPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool isSelected;
  _MapMarkerPainter(
      {required this.color,
      required this.borderColor,
      required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double border = isSelected ? 3.0 : 2.0;

    // Ombre
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(width / 2, height - 8), width: 18, height: 8),
        shadowPaint);

    // Forme du marqueur (goutte)
    final path = ui.Path();
    path.moveTo(width / 2, height);
    path.quadraticBezierTo(width, height * 0.6, width / 2, 8);
    path.quadraticBezierTo(0, height * 0.6, width / 2, height);

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, markerPaint);

    // Bordure
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = border;
    canvas.drawPath(path, borderPaint);

    // Point central
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(width / 2, height * 0.38), isSelected ? 5.5 : 4.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bouton glassy moderne pour la map
class _GlassyMapButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _GlassyMapButton(
      {required this.icon,
      required this.label,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.22),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
