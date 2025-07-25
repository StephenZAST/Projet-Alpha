import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../controllers/address_controller.dart';

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
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(
                        color: AppColors.borderLight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusLG,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _selectedAddress?.gpsLatitude != null
                                  ? LatLng(
                                      _selectedAddress!.gpsLatitude!,
                                      _selectedAddress!.gpsLongitude!,
                                    )
                                  : const LatLng(5.3484, -4.0305),
                              zoom: _currentZoom,
                              onPositionChanged: (pos, hasGesture) {
                                if (pos.zoom != null) {
                                  double clamped =
                                      pos.zoom!.clamp(_minZoom, _maxZoom);
                                  if (clamped != pos.zoom) {
                                    _mapController.move(
                                        _mapController.center, clamped);
                                  }
                                  setState(() {
                                    _currentZoom = clamped;
                                  });
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.alpha.admin',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (_selectedAddress != null &&
                                      _selectedAddress!.gpsLatitude != null &&
                                      _selectedAddress!.gpsLongitude != null)
                                    Marker(
                                      point: LatLng(
                                        _selectedAddress!.gpsLatitude!,
                                        _selectedAddress!.gpsLongitude!,
                                      ),
                                      width: 36,
                                      height: 44,
                                      builder: (context) => Icon(
                                        Icons.place,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          // Boutons overlay (ajout et centrer)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                if (widget.onAddNewAddress != null)
                                  AppButton(
                                    icon: Icons.add_location_alt,
                                    label: 'Nouvelle adresse',
                                    onPressed: widget.onAddNewAddress!,
                                    variant: AppButtonVariant.secondary,
                                  ),
                                if (_selectedAddress != null) ...[
                                  const SizedBox(height: 8),
                                  _GlassyMapButton(
                                    icon: Icons.center_focus_strong,
                                    label: 'Centrer',
                                    onPressed: () =>
                                        _centerOnAddress(_selectedAddress!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Card d'adresse épurée et moderne
                          if (_selectedAddress != null)
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedAddress?.name ??
                                                'Sans nom',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_selectedAddress?.street != null)
                                            Text(
                                              _selectedAddress!.street,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                      color: AppColors
                                                          .textSecondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          Text(
                                            [
                                              _selectedAddress?.city,
                                              _selectedAddress?.postalCode,
                                            ].where((e) => e != null).join(' '),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: AppColors
                                                        .textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
