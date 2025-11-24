import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/services/location_service.dart';

/// 🗺️ Widget de Sélection de Localisation - Alpha Client App
///
/// Widget premium pour sélectionner une localisation sur une carte OpenStreetMap
/// avec recherche d'adresses et géolocalisation.
class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final Function(double latitude, double longitude, String address) onLocationSelected;
  final bool showCurrentLocationButton;

  const LocationPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.onLocationSelected,
    this.showCurrentLocationButton = true,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  late LatLng _selectedLocation;
  String _selectedAddress = '';
  List<LocationSuggestion> _searchSuggestions = [];
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  bool _showSuggestions = false;
  bool _isAddressCardExpanded = false;
  bool _isReloadingMap = false;

  // Paris par défaut
  static const LatLng _defaultLocation = LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _selectedAddress = widget.initialAddress ?? '';
      _searchController.text = _selectedAddress;
    } else {
      _selectedLocation = _defaultLocation;
      _selectedAddress = 'Paris, France';
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    // Éviter de rechercher "Position GPS" ou des coordonnées
    if (query.contains('Position GPS') || 
        query.contains(',') && query.split(',').length == 2) {
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
      });
      return;
    }
    
    if (query.length >= 3) {
      _searchAddresses(query);
    } else {
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
      });
    }
  }

  Future<void> _searchAddresses(String query) async {
    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final suggestions = await LocationService.searchAddresses(query);
      if (mounted) {
        setState(() {
          _searchSuggestions = suggestions;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchSuggestions.clear();
          _isSearching = false;
        });
      }
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    setState(() {
      _selectedLocation = LatLng(suggestion.latitude, suggestion.longitude);
      _selectedAddress = suggestion.formattedAddress;
      _searchController.text = suggestion.formattedAddress;
      _showSuggestions = false;
    });

    _mapController.move(_selectedLocation, 15.0);
    widget.onLocationSelected(
      suggestion.latitude,
      suggestion.longitude,
      suggestion.formattedAddress,
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _showSuggestions = false;
    });

    _reverseGeocode(point);
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final suggestion = await LocationService.reverseGeocode(
        point.latitude,
        point.longitude,
      );

      if (suggestion != null && mounted) {
        setState(() {
          _selectedAddress = suggestion.displayName;
          _searchController.text = suggestion.displayName;
        });

        widget.onLocationSelected(
          point.latitude,
          point.longitude,
          suggestion.displayName,
        );
      } else {
        // Fallback : utiliser les coordonnées comme adresse
        final address = '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        if (mounted) {
          setState(() {
            _selectedAddress = address;
            _searchController.text = address;
          });

          widget.onLocationSelected(
            point.latitude,
            point.longitude,
            address,
          );
        }
      }
    } catch (e) {
      // Géocodage inverse échoué, utiliser les coordonnées
      final address = '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _searchController.text = address;
        });

        widget.onLocationSelected(
          point.latitude,
          point.longitude,
          address,
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final result = await LocationService.getCurrentPosition();
      
      if (result.isSuccess && mounted) {
        final location = LatLng(result.latitude!, result.longitude!);
        setState(() {
          _selectedLocation = location;
        });

        _mapController.move(location, 16.0);
        await _reverseGeocode(location);
      } else if (mounted) {
        _showErrorSnackBar(result.error ?? 'Impossible d\'obtenir votre position');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la géolocalisation: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  /// 🔄 Recharger la carte (utile en cas de bug d'affichage)
  Future<void> _reloadMap() async {
    setState(() {
      _isReloadingMap = true;
    });

    try {
      // Attendre un court délai pour permettre au widget de se reconstruire
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Forcer la reconstruction du widget
        setState(() {
          _isReloadingMap = false;
        });
        
        // Recentrer la carte sur la position sélectionnée
        _mapController.move(_selectedLocation, 13.0);
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Carte rechargée avec succès',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors du rechargement de la carte: ${e.toString()}');
        setState(() {
          _isReloadingMap = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 CORRECTION: Forcer la carte à toujours utiliser le thème clair
    // Le thème sombre de Stadia Maps ne fonctionne pas correctement en déploiement
    // Solution: utiliser toujours OpenStreetMap en thème clair
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Carte
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _selectedLocation,
                zoom: 13.0,
                onTap: _onMapTap,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  // 🔑 Toujours utiliser OpenStreetMap en thème clair
                  // Cela garantit que la carte fonctionne correctement
                  // peu importe le thème de l'application (clair ou sombre)
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.alphapressing.customers',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Barre de recherche
            Positioned(
              top: 16,
              left: 16,
              right: widget.showCurrentLocationButton ? 72 : 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.medium,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une adresse...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary(context),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary(context),
                        ),
                        suffixIcon: _isSearching
                            ? Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondary(context),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _showSuggestions = false;
                                      });
                                    },
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface(context),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onTap: () {
                        if (_searchSuggestions.isNotEmpty) {
                          setState(() {
                            _showSuggestions = true;
                          });
                        }
                      },
                    ),
                  ),

                  // Suggestions de recherche
                  if (_showSuggestions && _searchSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Column(
                        children: _searchSuggestions.take(5).map((suggestion) {
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: Text(
                              suggestion.formattedAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Boutons d'action (géolocalisation + rechargement)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Bouton de rechargement de la carte
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.medium,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isReloadingMap ? null : _reloadMap,
                        child: Center(
                          child: _isReloadingMap
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  if (widget.showCurrentLocationButton) ...[
                    const SizedBox(height: 8),
                    // Bouton de géolocalisation
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isLoadingCurrentLocation ? null : _getCurrentLocation,
                          child: Center(
                            child: _isLoadingCurrentLocation
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  )
                                : Icon(
                                    Icons.my_location,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Informations de l'adresse sélectionnée - Version compacte et rétractable
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAddressCardExpanded = !_isAddressCardExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: AppAnimations.medium,
                  curve: AppAnimations.slideIn,
                  padding: EdgeInsets.all(_isAddressCardExpanded ? 16 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // En-tête toujours visible
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adresse sélectionnée',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textPrimary(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!_isAddressCardExpanded)
                                  Text(
                                    _selectedAddress.isNotEmpty 
                                        ? _selectedAddress.length > 30 
                                            ? '${_selectedAddress.substring(0, 30)}...'
                                            : _selectedAddress
                                        : 'Tapez pour voir les détails',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isAddressCardExpanded ? 0.5 : 0,
                            duration: AppAnimations.medium,
                            child: Icon(
                              Icons.expand_more,
                              color: AppColors.textSecondary(context),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      
                      // Contenu détaillé (visible seulement quand étendu)
                      if (_isAddressCardExpanded) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAddress.isNotEmpty 
                                    ? _selectedAddress 
                                    : 'Aucune adresse sélectionnée',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.gps_fixed,
                                    color: AppColors.success,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                                      'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: AppColors.info,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Tapez sur la carte pour changer la position',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// 🗺️ Dialog de Sélection de Localisation
class LocationPickerDialog extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final String title;

  const LocationPickerDialog({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    this.title = 'Sélectionner la localisation',
  }) : super(key: key);

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
    _selectedAddress = widget.initialAddress ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Widget de sélection de localisation
              Expanded(
                child: LocationPickerWidget(
                  initialLatitude: widget.initialLatitude,
                  initialLongitude: widget.initialLongitude,
                  initialAddress: widget.initialAddress,
                  onLocationSelected: (latitude, longitude, address) {
                    setState(() {
                      _selectedLatitude = latitude;
                      _selectedLongitude = longitude;
                      _selectedAddress = address;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Annuler',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PremiumButton(
                      text: 'Confirmer',
                      onPressed: _selectedLatitude != null && _selectedLongitude != null
                          ? () {
                              Navigator.of(context).pop({
                                'latitude': _selectedLatitude,
                                'longitude': _selectedLongitude,
                                'address': _selectedAddress,
                              });
                            }
                          : null,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}