import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

/// 🧭 Service de Navigation GPS - Alpha Delivery App
///
/// Gère la navigation externe vers Google Maps, Apple Maps
/// et autres applications de navigation.
class NavigationService extends GetxService {
  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🧭 Initialisation NavigationService...');
    debugPrint('✅ NavigationService initialisé');
  }

  // ==========================================================================
  // 🗺️ NAVIGATION VERS ADRESSES
  // ==========================================================================

  /// Ouvre la navigation vers une adresse dans l'app de navigation par défaut
  Future<bool> navigateToAddress(String address) async {
    try {
      debugPrint('🧭 Navigation vers: $address');

      // Encode l'adresse pour l'URL
      final encodedAddress = Uri.encodeComponent(address);

      // Essaie d'abord Google Maps
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      // Fallback vers l'app de cartes par défaut
      final defaultMapsUrl = 'geo:0,0?q=$encodedAddress';

      if (await canLaunchUrl(Uri.parse(defaultMapsUrl))) {
        await launchUrl(
          Uri.parse(defaultMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur navigation vers adresse: $e');
      return false;
    }
  }

  /// Ouvre la navigation vers des coordonnées GPS
  Future<bool> navigateToCoordinates(double latitude, double longitude,
      {String? label}) async {
    try {
      debugPrint('🧭 Navigation vers: $latitude, $longitude');

      // URL Google Maps avec coordonnées
      String googleMapsUrl;
      if (label != null) {
        final encodedLabel = Uri.encodeComponent(label);
        googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($encodedLabel)';
      } else {
        googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      }

      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      // Fallback vers geo: URI
      final geoUrl = 'geo:$latitude,$longitude';

      if (await canLaunchUrl(Uri.parse(geoUrl))) {
        await launchUrl(
          Uri.parse(geoUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur navigation vers coordonnées: $e');
      return false;
    }
  }

  /// Ouvre la navigation avec itinéraire depuis la position actuelle
  Future<bool> navigateFromCurrentLocation(
    double destinationLat,
    double destinationLng, {
    String? destinationLabel,
    NavigationMode mode = NavigationMode.driving,
  }) async {
    try {
      debugPrint(
          '🧭 Navigation depuis position actuelle vers: $destinationLat, $destinationLng');

      // Mode de transport pour Google Maps
      String travelMode;
      switch (mode) {
        case NavigationMode.driving:
          travelMode = 'driving';
          break;
        case NavigationMode.walking:
          travelMode = 'walking';
          break;
        case NavigationMode.bicycling:
          travelMode = 'bicycling';
          break;
        case NavigationMode.transit:
          travelMode = 'transit';
          break;
      }

      // URL Google Maps avec itinéraire
      final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1'
          '&destination=$destinationLat,$destinationLng'
          '&travelmode=$travelMode';

      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      // Fallback vers navigation simple
      return await navigateToCoordinates(destinationLat, destinationLng,
          label: destinationLabel);
    } catch (e) {
      debugPrint('❌ Erreur navigation depuis position actuelle: $e');
      return false;
    }
  }

  // ==========================================================================
  // 📋 COPIE D'ADRESSES
  // ==========================================================================

  /// Copie une adresse dans le presse-papiers
  Future<bool> copyAddressToClipboard(String address) async {
    try {
      await Clipboard.setData(ClipboardData(text: address));
      debugPrint('📋 Adresse copiée: $address');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur copie adresse: $e');
      return false;
    }
  }

  /// Copie des coordonnées GPS dans le presse-papiers
  Future<bool> copyCoordinatesToClipboard(
      double latitude, double longitude) async {
    try {
      final coordinates = '$latitude, $longitude';
      await Clipboard.setData(ClipboardData(text: coordinates));
      debugPrint('📋 Coordonnées copiées: $coordinates');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur copie coordonnées: $e');
      return false;
    }
  }

  // ==========================================================================
  // 🔗 LIENS DIRECTS VERS APPLICATIONS
  // ==========================================================================

  /// Ouvre Google Maps directement
  Future<bool> openGoogleMaps(double latitude, double longitude,
      {String? label}) async {
    try {
      // URL scheme Google Maps
      final googleMapsApp = 'comgooglemaps://?q=$latitude,$longitude';

      if (await canLaunchUrl(Uri.parse(googleMapsApp))) {
        await launchUrl(
          Uri.parse(googleMapsApp),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      // Fallback vers version web
      return await navigateToCoordinates(latitude, longitude, label: label);
    } catch (e) {
      debugPrint('❌ Erreur ouverture Google Maps: $e');
      return false;
    }
  }

  /// Ouvre Apple Maps (iOS uniquement)
  Future<bool> openAppleMaps(double latitude, double longitude,
      {String? label}) async {
    try {
      // URL scheme Apple Maps
      String appleMapsUrl = 'http://maps.apple.com/?ll=$latitude,$longitude';
      if (label != null) {
        final encodedLabel = Uri.encodeComponent(label);
        appleMapsUrl += '&q=$encodedLabel';
      }

      if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur ouverture Apple Maps: $e');
      return false;
    }
  }

  /// Ouvre Waze
  Future<bool> openWaze(double latitude, double longitude) async {
    try {
      // URL scheme Waze
      final wazeUrl =
          'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';

      if (await canLaunchUrl(Uri.parse(wazeUrl))) {
        await launchUrl(
          Uri.parse(wazeUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur ouverture Waze: $e');
      return false;
    }
  }

  // ==========================================================================
  // 🎯 MÉTHODES UTILITAIRES
  // ==========================================================================

  /// Affiche un sélecteur d'applications de navigation
  Future<bool> showNavigationOptions(
    double latitude,
    double longitude, {
    String? label,
    String? address,
  }) async {
    try {
      // Cette méthode pourrait ouvrir un bottom sheet avec les options
      // Pour l'instant, on utilise la navigation par défaut

      if (address != null) {
        return await navigateToAddress(address);
      } else {
        return await navigateToCoordinates(latitude, longitude, label: label);
      }
    } catch (e) {
      debugPrint('❌ Erreur options de navigation: $e');
      return false;
    }
  }

  /// Vérifie si une application de navigation est disponible
  Future<bool> isNavigationAppAvailable(NavigationApp app) async {
    try {
      String url;

      switch (app) {
        case NavigationApp.googleMaps:
          url = 'comgooglemaps://';
          break;
        case NavigationApp.appleMaps:
          url = 'http://maps.apple.com/';
          break;
        case NavigationApp.waze:
          url = 'waze://';
          break;
      }

      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint('❌ Erreur vérification app navigation: $e');
      return false;
    }
  }

  /// Formate une adresse pour l'affichage
  String formatAddressForDisplay(String street, String city,
      {String? postalCode}) {
    final parts = <String>[street, city];
    if (postalCode != null && postalCode.isNotEmpty) {
      parts.add(postalCode);
    }
    return parts.join(', ');
  }

  /// Formate des coordonnées pour l'affichage
  String formatCoordinatesForDisplay(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

/// 🏷️ Modes de navigation
enum NavigationMode {
  driving,
  walking,
  bicycling,
  transit,
}

/// 🏷️ Applications de navigation
enum NavigationApp {
  googleMaps,
  appleMaps,
  waze,
}
