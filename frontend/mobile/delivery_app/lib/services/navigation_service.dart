import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🧭 Service de Navigation - Alpha Delivery App
///
/// Gère la navigation GPS et l'ouverture d'applications de cartes externes.
/// Optimisé pour les besoins des livreurs mobiles.
class NavigationService extends GetxService {
  
  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🧭 Initialisation NavigationService...');
  }
  
  // ==========================================================================
  // 🗺️ NAVIGATION GPS
  // ==========================================================================
  
  /// Navigue vers des coordonnées GPS sp��cifiques
  Future<void> navigateToCoordinates(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      debugPrint('🧭 Navigation vers coordonnées: $latitude, $longitude');
      
      // Essaie d'ouvrir Google Maps en premier
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${label != null ? '&destination_place_id=$label' : ''}'
      );
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Navigation ouverte dans Google Maps');
        
        _showSuccessMessage('Navigation ouverte dans Google Maps');
        return;
      }
      
      // Fallback vers l'URL geo: pour d'autres applications
      final geoUrl = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($label)' : ''}');
      
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Navigation ouverte dans l\'application de cartes par défaut');
        
        _showSuccessMessage('Navigation ouverte');
        return;
      }
      
      // Si aucune application n'est disponible
      throw Exception('Aucune application de navigation disponible');
      
    } catch (e) {
      debugPrint('❌ Erreur navigation vers coordonnées: $e');
      _showErrorMessage('Impossible d\'ouvrir la navigation GPS');
    }
  }
  
  /// Navigue vers une adresse textuelle
  Future<void> navigateToAddress(String address) async {
    try {
      debugPrint('🧭 Navigation vers adresse: $address');
      
      final encodedAddress = Uri.encodeComponent(address);
      
      // Essaie d'ouvrir Google Maps avec l'adresse
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress'
      );
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Navigation ouverte dans Google Maps');
        
        _showSuccessMessage('Navigation ouverte dans Google Maps');
        return;
      }
      
      // Fallback vers l'URL geo: avec recherche
      final geoUrl = Uri.parse('geo:0,0?q=$encodedAddress');
      
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Navigation ouverte dans l\'application de cartes par défaut');
        
        _showSuccessMessage('Navigation ouverte');
        return;
      }
      
      // Si aucune application n'est disponible
      throw Exception('Aucune application de navigation disponible');
      
    } catch (e) {
      debugPrint('❌ Erreur navigation vers adresse: $e');
      _showErrorMessage('Impossible d\'ouvrir la navigation GPS');
    }
  }
  
  /// Ouvre l'application de cartes avec plusieurs destinations (itinéraire optimisé)
  Future<void> navigateToMultipleDestinations(List<MapDestination> destinations) async {
    try {
      debugPrint('🧭 Navigation vers ${destinations.length} destinations');
      
      if (destinations.isEmpty) {
        throw Exception('Aucune destination fournie');
      }
      
      // Pour Google Maps, on peut créer un itinéraire avec plusieurs waypoints
      final waypoints = destinations.skip(1).map((dest) {
        if (dest.latitude != null && dest.longitude != null) {
          return '${dest.latitude},${dest.longitude}';
        } else {
          return Uri.encodeComponent(dest.address);
        }
      }).join('|');
      
      final firstDest = destinations.first;
      String destination;
      if (firstDest.latitude != null && firstDest.longitude != null) {
        destination = '${firstDest.latitude},${firstDest.longitude}';
      } else {
        destination = Uri.encodeComponent(firstDest.address);
      }
      
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}&travelmode=driving'
      );
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Itinéraire multi-destinations ouvert dans Google Maps');
        
        _showSuccessMessage('Itinéraire optimisé ouvert dans Google Maps');
        return;
      }
      
      // Fallback : ouvre juste la première destination
      if (firstDest.latitude != null && firstDest.longitude != null) {
        await navigateToCoordinates(
          firstDest.latitude!,
          firstDest.longitude!,
          label: firstDest.label,
        );
      } else {
        await navigateToAddress(firstDest.address);
      }
      
    } catch (e) {
      debugPrint('❌ Erreur navigation multi-destinations: $e');
      _showErrorMessage('Impossible d\'ouvrir l\'itinéraire optimisé');
    }
  }
  
  /// Vérifie si une application de navigation est disponible
  Future<bool> isNavigationAvailable() async {
    try {
      // Test avec Google Maps
      final googleMapsUrl = Uri.parse('https://www.google.com/maps/');
      if (await canLaunchUrl(googleMapsUrl)) {
        return true;
      }
      
      // Test avec geo: URL
      final geoUrl = Uri.parse('geo:0,0?q=test');
      if (await canLaunchUrl(geoUrl)) {
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Erreur vérification navigation: $e');
      return false;
    }
  }
  
  // ==========================================================================
  // 💬 MESSAGES UTILISATEUR
  // ==========================================================================
  
  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Navigation',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.navigation, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erreur Navigation',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  @override
  void onClose() {
    debugPrint('🧹 NavigationService nettoyé');
    super.onClose();
  }
}

/// 📍 Modèle de destination pour la navigation
class MapDestination {
  final String address;
  final double? latitude;
  final double? longitude;
  final String? label;
  
  const MapDestination({
    required this.address,
    this.latitude,
    this.longitude,
    this.label,
  });
  
  /// Vérifie si la destination a des coordonnées GPS
  bool get hasCoordinates => latitude != null && longitude != null;
  
  @override
  String toString() {
    if (hasCoordinates) {
      return 'MapDestination(lat: $latitude, lng: $longitude, label: $label)';
    } else {
      return 'MapDestination(address: $address, label: $label)';
    }
  }
}