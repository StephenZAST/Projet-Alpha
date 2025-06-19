import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_button.dart';

class MapSelectionDialog extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  const MapSelectionDialog(
      {Key? key, this.initialLatitude, this.initialLongitude})
      : super(key: key);

  @override
  State<MapSelectionDialog> createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<MapSelectionDialog>
    with SingleTickerProviderStateMixin {
  late double latitude;
  late double longitude;
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    latitude = widget.initialLatitude ?? 5.3484;
    longitude = widget.initialLongitude ?? -4.0305;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _bounceAnimation = Tween<double>(begin: 0, end: -20)
        .chain(CurveTween(curve: Curves.elasticInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      latitude = latLng.latitude;
      longitude = latLng.longitude;
    });
    _controller.forward(from: 0);
    Get.snackbar('Emplacement sélectionné',
        'Coordonnées: ${latLng.latitude}, ${latLng.longitude}',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Sélectionner un emplacement sur la carte',
                  style: AppTextStyles.h3),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude),
                  zoom: 14,
                  onTap: (tapPosition, latLng) => _onMapTap(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.alpha.admin',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        width: 50,
                        height: 50,
                        builder: (context) => AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          ),
                          child: Icon(Icons.location_on,
                              color: AppColors.primary, size: 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GlassButton(
                    label: 'Valider l\'emplacement',
                    variant: GlassButtonVariant.primary,
                    onPressed: () {
                      Get.back(result: LatLng(latitude, longitude));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
