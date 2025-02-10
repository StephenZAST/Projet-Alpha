import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import '../constants.dart';

class DirectionsService {
  final directions = GoogleMapsDirections(
    apiKey: Environment.googleMapsApiKey,
  );

  Future<DirectionsResponse?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await directions.getDirections(
        '${origin.latitude},${origin.longitude}',
        '${destination.latitude},${destination.longitude}',
        travelMode: TravelMode.driving,
      );

      if (response.isOkay) {
        return response;
      }
      return null;
    } catch (e) {
      print('[DirectionsService] Error: $e');
      return null;
    }
  }

  void dispose() {
    directions.dispose();
  }
}
