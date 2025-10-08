import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// 🗺️ Service de Géolocalisation - Alpha Client App
///
/// Service pour gérer la géolocalisation et le géocodage
/// avec OpenStreetMap (Nominatim) sans clé API requise.
class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _timeout = Duration(seconds: 10);

  /// 📍 Obtenir la position actuelle de l'utilisateur
  static Future<LocationResult> getCurrentPosition() async {
    try {
      // Vérifier les permissions
      final permission = await _checkLocationPermission();
      if (!permission.isGranted) {
        return LocationResult.error(permission.message);
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: _timeout,
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return LocationResult.error('Impossible d\'obtenir votre position: ${e.toString()}');
    }
  }

  /// 🔍 Rechercher des adresses par texte (géocodage)
  static Future<List<LocationSuggestion>> searchAddresses(String query) async {
    if (query.trim().length < 3) {
      return [];
    }

    // Éviter de rechercher "Position GPS" qui cause des erreurs CORS
    if (query.trim() == 'Position GPS' || query.contains('Position GPS')) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = '$_nominatimBaseUrl/search?q=$encodedQuery&format=json&limit=5&addressdetails=1&countrycodes=fr';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'AlphaPressing/1.0.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.map((result) => LocationSuggestion.fromNominatim(result)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur lors de la recherche d\'adresses: $e');
      return [];
    }
  }

  /// 🗺️ Géocodage inverse (coordonnées vers adresse)
  static Future<LocationSuggestion?> reverseGeocode(double latitude, double longitude) async {
    try {
      // Essayer d'abord avec Nominatim
      final nominatimResult = await _tryNominatimReverse(latitude, longitude);
      if (nominatimResult != null) {
        return nominatimResult;
      }

      // Fallback : créer une suggestion basique avec les coordonnées
      print('[LocationService] Fallback: utilisation des coordonnées comme adresse');
      return LocationSuggestion(
        displayName: '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
        latitude: latitude,
        longitude: longitude,
        city: null,
        postalCode: null,
        street: 'Position GPS',
      );
    } catch (e) {
      print('[LocationService] Erreur lors du géocodage inverse: $e');
      
      // Retourner une suggestion basique même en cas d'erreur
      return LocationSuggestion(
        displayName: '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
        latitude: latitude,
        longitude: longitude,
        city: null,
        postalCode: null,
        street: 'Position GPS',
      );
    }
  }

  /// 🌐 Tentative de géocodage inverse avec Nominatim
  static Future<LocationSuggestion?> _tryNominatimReverse(double latitude, double longitude) async {
    try {
      final url = '$_nominatimBaseUrl/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1&accept-language=fr';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'AlphaPressing/1.0.0',
          'Accept': 'application/json',
          'Accept-Language': 'fr,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return LocationSuggestion.fromNominatim(result);
      }
      
      print('[LocationService] Nominatim échoué: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[LocationService] Erreur Nominatim: $e');
      return null;
    }
  }

  /// 🔐 Vérifier et demander les permissions de localisation
  static Future<PermissionResult> _checkLocationPermission() async {
    try {
      // Vérifier si le service de localisation est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return PermissionResult.error('Le service de localisation est désactivé');
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return PermissionResult.error('Permission de localisation refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return PermissionResult.error(
          'Permission de localisation refusée définitivement. Veuillez l\'activer dans les paramètres.'
        );
      }

      return PermissionResult.success();
    } catch (e) {
      return PermissionResult.error('Erreur lors de la vérification des permissions: ${e.toString()}');
    }
  }

  /// 📏 Calculer la distance entre deux points (en mètres)
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// 📏 Formater la distance pour l'affichage
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}

/// 📍 Résultat d'opération de localisation
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? error;

  LocationResult._({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.error,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory LocationResult.error(String error) {
    return LocationResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// 🔐 Résultat de vérification des permissions
class PermissionResult {
  final bool isGranted;
  final String message;

  PermissionResult._({
    required this.isGranted,
    required this.message,
  });

  factory PermissionResult.success() {
    return PermissionResult._(
      isGranted: true,
      message: 'Permission accordée',
    );
  }

  factory PermissionResult.error(String message) {
    return PermissionResult._(
      isGranted: false,
      message: message,
    );
  }
}

/// 🏠 Suggestion d'adresse depuis Nominatim
class LocationSuggestion {
  final String displayName;
  final String? houseNumber;
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.displayName,
    this.houseNumber,
    this.street,
    this.city,
    this.postalCode,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  /// 📊 Conversion depuis Nominatim JSON
  factory LocationSuggestion.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      houseNumber: address['house_number'],
      street: address['road'] ?? address['street'],
      city: address['city'] ?? address['town'] ?? address['village'],
      postalCode: address['postcode'],
      country: address['country'],
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
    );
  }

  /// 🏠 Adresse formatée pour l'affichage
  String get formattedAddress {
    final parts = <String>[];
    
    if (houseNumber != null && street != null) {
      parts.add('$houseNumber $street');
    } else if (street != null) {
      parts.add(street!);
    }
    
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    } else if (city != null) {
      parts.add(city!);
    }
    
    return parts.join(', ');
  }

  /// 🏠 Adresse courte pour les listes
  String get shortAddress {
    if (city != null) {
      return city!;
    }
    return displayName.split(',').first;
  }

  /// 🏠 Rue complète (numéro + nom)
  String get fullStreet {
    if (houseNumber != null && street != null) {
      return '$houseNumber $street';
    }
    return street ?? '';
  }
}