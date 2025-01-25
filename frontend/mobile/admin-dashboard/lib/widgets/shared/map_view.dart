import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants.dart';

class MapView extends StatefulWidget {
  final LatLng? initialPosition;
  final List<Marker>? markers;
  final double initialZoom;
  final bool interactive;
  final Function(LatLng)? onTap;
  final Widget? overlayWidget;
  final List<Widget>? controls;
  final MapController? controller;
  final double height;

  const MapView({
    Key? key,
    this.initialPosition,
    this.markers,
    this.initialZoom = 13,
    this.interactive = true,
    this.onTap,
    this.overlayWidget,
    this.controls,
    this.controller,
    this.height = 400,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
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
              mapController: _controller,
              options: MapOptions(
                initialCenter: widget.initialPosition ??
                    const LatLng(5.3484, -4.0305), // Abidjan
                initialZoom: widget.initialZoom,
                onTap: widget.onTap != null
                    ? (_, point) => widget.onTap!(point)
                    : null,
                interactionOptions: widget.interactive
                    ? const InteractionOptions()
                    : const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.alpha.admin',
                ),
                if (widget.markers != null)
                  MarkerLayer(markers: widget.markers!),
              ],
            ),
            if (widget.overlayWidget != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: widget.overlayWidget!,
              ),
            if (widget.controls != null)
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: widget.controls!
                      .map((control) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: control,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MapMarker extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  const MapMarker({
    Key? key,
    this.isSelected = false,
    this.onTap,
    this.icon = Icons.location_on,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? (isSelected ? AppColors.primary : AppColors.gray400),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon ?? Icons.location_on,
          color: Colors.white,
          size: isSelected ? 24 : 20,
        ),
      ),
    );
  }
}
