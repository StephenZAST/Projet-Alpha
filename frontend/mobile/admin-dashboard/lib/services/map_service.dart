import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapService {
  static const String mapStyle =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  // Vous pouvez aussi utiliser des styles personnalisés comme :
  // static const String mapStyle = 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';

  static final defaultCenter = LatLng(48.8566, 2.3522); // Paris
  static const defaultZoom = 13.0;

  static TileLayer get baseMapTile => TileLayer(
        urlTemplate: mapStyle,
        userAgentPackageName: 'com.alpha.admin',
        additionalOptions: {
          'accessToken':
              const String.fromEnvironment('MAP_TOKEN', defaultValue: ''),
        },
      );

  static Marker createMarker({
    required LatLng point,
    required String key,
    required Function() onTap,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.location_on,
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
      ),
    );
  }
}
