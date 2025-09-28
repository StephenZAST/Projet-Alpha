import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

import '../constants.dart';

/// 📍 Service de Géolocalisation - Alpha Delivery App
///
/// Gère la géolocalisation du livreur avec permissions,
/// suivi en temps réel et optimisation de la batterie.
class LocationService extends GetxService {
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================

  final GetStorage _storage = GetStorage();

  // États observables
  final _currentPosition = Rxn<Position>();
  final _isLocationEnabled = false.obs;
  final _isTracking = false.obs;
  final _lastKnownPosition = Rxn<Position>();

  // Configuration
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Mise à jour tous les 10 mètres
  );

  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================

  Position? get currentPosition => _currentPosition.value;
  bool get isLocationEnabled => _isLocationEnabled.value;
  bool get isTracking => _isTracking.value;
  Position? get lastKnownPosition => _lastKnownPosition.value;

  // Getters observables
  Rxn<Position> get currentPositionRx => _currentPosition;
  RxBool get isLocationEnabledRx => _isLocationEnabled;
  RxBool get isTrackingRx => _isTracking;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('📍 Initialisation LocationService...');

    // Charge la dernière position connue
    await _loadLastKnownPosition();

    // Vérifie les permissions et services
    await _checkLocationStatus();

    debugPrint('✅ LocationService initialisé');
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  /// Charge la dernière position sauvegardée
  Future<void> _loadLastKnownPosition() async {
    try {
      final savedPosition =
          _storage.read<Map<String, dynamic>>(StorageKeys.lastLocation);

      if (savedPosition != null) {
        _lastKnownPosition.value = Position(
          latitude: savedPosition['latitude'],
          longitude: savedPosition['longitude'],
          timestamp: DateTime.parse(savedPosition['timestamp']),
          accuracy: savedPosition['accuracy'],
          altitude: savedPosition['altitude'] ?? 0.0,
          altitudeAccuracy: savedPosition['altitudeAccuracy'] ?? 0.0,
          heading: savedPosition['heading'] ?? 0.0,
          headingAccuracy: savedPosition['headingAccuracy'],
          speed: savedPosition['speed'] ?? 0.0,
          speedAccuracy: savedPosition['speedAccuracy'] ?? 0.0,
        );

        debugPrint('📍 Dernière position chargée: ${_lastKnownPosition.value}');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement de la position: $e');
    }
  }

  /// Sauvegarde la position actuelle
  Future<void> _saveCurrentPosition(Position position) async {
    try {
      await _storage.write(StorageKeys.lastLocation, {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.toIso8601String(),
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'altitudeAccuracy': position.altitudeAccuracy,
        'heading': position.heading,
        'headingAccuracy': position.headingAccuracy,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
      });
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde de position: $e');
    }
  }

  // ==========================================================================
  // 🔐 GESTION DES PERMISSIONS
  // ==========================================================================

  /// Vérifie le statut de la géolocalisation
  Future<void> _checkLocationStatus() async {
    try {
      // Vérifie si le service de localisation est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _isLocationEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        debugPrint('⚠️ Service de localisation désactivé');
        return;
      }

      // Vérifie les permissions
      final permission = await Geolocator.checkPermission();
      debugPrint('📍 Permission actuelle: $permission');
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du statut: $e');
    }
  }

  /// Demande les permissions de géolocalisation
  Future<LocationPermissionResult> requestLocationPermission() async {
    try {
      debugPrint('📍 Demande de permission de géolocalisation...');

      // Vérifie si le service est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult.serviceDisabled;
      }

      // Vérifie la permission actuelle
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult.deniedForever;
      }

      _isLocationEnabled.value = true;
      debugPrint('✅ Permission de géolocalisation accordée');
      return LocationPermissionResult.granted;
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande de permission: $e');
      return LocationPermissionResult.error;
    }
  }

  /// Ouvre les paramètres de l'application
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ouverture des paramètres: $e');
    }
  }

  // ==========================================================================
  // 📍 GÉOLOCALISATION
  // ==========================================================================

  /// Obtient la position actuelle
  Future<Position?> getCurrentPosition() async {
    try {
      debugPrint('📍 Récupération de la position actuelle...');

      // Vérifie les permissions
      final permissionResult = await requestLocationPermission();
      if (permissionResult != LocationPermissionResult.granted) {
        debugPrint('❌ Permission refusée: $permissionResult');
        return null;
      }

      // Obtient la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: AppDefaults.locationTimeout,
      );

      _currentPosition.value = position;
      _lastKnownPosition.value = position;

      // Sauvegarde la position
      await _saveCurrentPosition(position);

      debugPrint(
          '✅ Position obtenue: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de position: $e');
      return null;
    }
  }

  /// Démarre le suivi de position en temps réel
  Future<bool> startTracking() async {
    try {
      if (_isTracking.value) {
        debugPrint('⚠️ Suivi déjà en cours');
        return true;
      }

      debugPrint('📍 Démarrage du suivi de position...');

      // Vérifie les permissions
      final permissionResult = await requestLocationPermission();
      if (permissionResult != LocationPermissionResult.granted) {
        debugPrint('❌ Permission refusée pour le suivi');
        return false;
      }

      // Démarre le stream de position
      Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
        (Position position) {
          _onPositionUpdate(position);
        },
        onError: (error) {
          debugPrint('❌ Erreur dans le stream de position: $error');
          _isTracking.value = false;
        },
        onDone: () {
          debugPrint('📍 Stream de position terminé');
          _isTracking.value = false;
        },
      );

      _isTracking.value = true;
      debugPrint('✅ Suivi de position démarré');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors du démarrage du suivi: $e');
      return false;
    }
  }

  /// Arrête le suivi de position
  void stopTracking() {
    if (_isTracking.value) {
      _isTracking.value = false;
      debugPrint('🛑 Suivi de position arrêté');
    }
  }

  /// Gère les mises à jour de position
  void _onPositionUpdate(Position position) {
    _currentPosition.value = position;
    _lastKnownPosition.value = position;

    // Sauvegarde périodique
    _saveCurrentPosition(position);

    // Log périodique (toutes les 5 mises à jour pour éviter le spam)
    if (position.timestamp.second % 5 == 0) {
      debugPrint(
          '📍 Position mise à jour: ${position.latitude}, ${position.longitude}');
    }
  }

  // ==========================================================================
  // 📏 CALCULS DE DISTANCE
  // ==========================================================================

  /// Calcule la distance entre deux points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calcule la distance depuis la position actuelle
  double? calculateDistanceFromCurrent(double latitude, double longitude) {
    final current = _currentPosition.value ?? _lastKnownPosition.value;
    if (current == null) return null;

    return calculateDistance(
      current.latitude,
      current.longitude,
      latitude,
      longitude,
    );
  }

  /// Formate une distance en texte lisible
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // ==========================================================================
  // 🎯 MÉTHODES UTILITAIRES
  // ==========================================================================

  /// Vérifie si une position est dans un rayon donné
  bool isWithinRadius(
    double centerLat,
    double centerLng,
    double radius, {
    Position? position,
  }) {
    final pos = position ?? _currentPosition.value ?? _lastKnownPosition.value;
    if (pos == null) return false;

    final distance = calculateDistance(
      pos.latitude,
      pos.longitude,
      centerLat,
      centerLng,
    );

    return distance <= radius;
  }

  /// Obtient la précision de la position actuelle
  double? get currentAccuracy => _currentPosition.value?.accuracy;

  /// Vérifie si la position est suffisamment précise
  bool get isAccurate {
    final accuracy = currentAccuracy;
    return accuracy != null && accuracy <= AppDefaults.locationAccuracy;
  }

  /// Obtient l'âge de la dernière position
  Duration? get lastPositionAge {
    final position = _currentPosition.value ?? _lastKnownPosition.value;
    if (position == null) return null;

    return DateTime.now().difference(position.timestamp);
  }

  /// Vérifie si la position est récente
  bool get isPositionRecent {
    final age = lastPositionAge;
    return age != null && age.inMinutes < 5;
  }
}

/// 🏷️ Résultat de demande de permission
enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

/// 📍 Extension pour Position
extension PositionExtension on Position {
  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
      'heading': heading,
      'headingAccuracy': headingAccuracy,
      'speed': speed,
      'speedAccuracy': speedAccuracy,
    };
  }

  /// Formate la position pour l'affichage
  String get formatted {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Vérifie si la position est valide
  bool get isValid {
    return latitude.abs() <= 90 && longitude.abs() <= 180;
  }
}
