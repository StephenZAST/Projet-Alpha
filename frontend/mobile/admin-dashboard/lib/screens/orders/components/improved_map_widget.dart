import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../constants.dart';

/// Widget de carte amélioré et robuste avec gestion correcte du zoom
class ImprovedMapWidget extends StatefulWidget {
  final LatLng? initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final Function(LatLng)? onTap;
  final Function(MapPosition, bool)? onPositionChanged;
  final double? width;
  final double? height;
  final bool showZoomControls;
  final bool showAttribution;
  final String? mapTheme; // 'light', 'dark', 'auto'

  const ImprovedMapWidget({
    Key? key,
    this.initialCenter,
    this.initialZoom = 13.0,
    this.markers = const [],
    this.onTap,
    this.onPositionChanged,
    this.width,
    this.height,
    this.showZoomControls = true,
    this.showAttribution = true,
    this.mapTheme = 'auto',
  }) : super(key: key);

  @override
  _ImprovedMapWidgetState createState() => _ImprovedMapWidgetState();
}

class _ImprovedMapWidgetState extends State<ImprovedMapWidget>
    with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _zoomAnimationController;
  
  // Constantes de zoom robustes
  static const double _minZoom = 1.0;
  static const double _maxZoom = 18.0;
  static const double _defaultZoom = 13.0;
  
  double _currentZoom = _defaultZoom;
  LatLng? _currentCenter;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = _clampZoom(widget.initialZoom);
    _currentCenter = widget.initialCenter ?? const LatLng(12.3714, -1.5197); // Ouagadougou par défaut
    
    _zoomAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialiser la carte après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _initializeMap() {
    if (_currentCenter != null && mounted) {
      try {
        _mapController.move(_currentCenter!, _currentZoom);
        setState(() {
          _isMapReady = true;
        });
      } catch (e) {
        print('Erreur lors de l\'initialisation de la carte: $e');
      }
    }
  }

  double _clampZoom(double zoom) {
    return zoom.clamp(_minZoom, _maxZoom);
  }

  void _handlePositionChanged(MapPosition position, bool hasGesture) {
    if (!mounted) return;

    try {
      final newZoom = position.zoom;
      final newCenter = position.center;

      if (newZoom != null && newCenter != null) {
        final clampedZoom = _clampZoom(newZoom);
        
        // Si le zoom dépasse les limites, corriger immédiatement
        if ((newZoom - clampedZoom).abs() > 0.01) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                _mapController.move(newCenter, clampedZoom);
              } catch (e) {
                print('Erreur lors de la correction du zoom: $e');
              }
            }
          });
        }

        // Mettre à jour l'état local
        if (mounted) {
          setState(() {
            _currentZoom = clampedZoom;
            _currentCenter = newCenter;
          });
        }

        // Appeler le callback externe si fourni
        widget.onPositionChanged?.call(
          MapPosition(
            center: newCenter,
            zoom: clampedZoom,
            bounds: position.bounds,
          ),
          hasGesture,
        );
      }
    } catch (e) {
      print('Erreur dans _handlePositionChanged: $e');
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    widget.onTap?.call(point);
  }

  String _getTileUrl(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    switch (widget.mapTheme) {
      case 'dark':
        return 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';
      case 'light':
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case 'auto':
      default:
        return brightness == Brightness.dark
            ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    switch (widget.mapTheme) {
      case 'dark':
        return AppColors.gray900;
      case 'light':
        return AppColors.gray100;
      case 'auto':
      default:
        return brightness == Brightness.dark ? AppColors.gray900 : AppColors.gray100;
    }
  }

  void _zoomIn() {
    final newZoom = _clampZoom(_currentZoom + 1);
    if (newZoom != _currentZoom && _currentCenter != null) {
      try {
        _mapController.move(_currentCenter!, newZoom);
      } catch (e) {
        print('Erreur lors du zoom in: $e');
      }
    }
  }

  void _zoomOut() {
    final newZoom = _clampZoom(_currentZoom - 1);
    if (newZoom != _currentZoom && _currentCenter != null) {
      try {
        _mapController.move(_currentCenter!, newZoom);
      } catch (e) {
        print('Erreur lors du zoom out: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: widget.width,
      height: widget.height ?? 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Carte principale
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentCenter,
                zoom: _currentZoom,
                minZoom: _minZoom,
                maxZoom: _maxZoom,
                onTap: _handleMapTap,
                onPositionChanged: _handlePositionChanged,
                // Désactiver les interactions problématiques
                enableMultiFingerGestureRace: false,
                // Limiter la vitesse de zoom pour éviter les bugs
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
              ),
              children: [
                // Couche de tuiles
                TileLayer(
                  urlTemplate: _getTileUrl(context),
                  userAgentPackageName: 'com.alpha.admin',
                  maxZoom: _maxZoom,
                  backgroundColor: _getBackgroundColor(context),
                ),
                
                // Couche de marqueurs
                if (widget.markers.isNotEmpty)
                  MarkerLayer(
                    markers: widget.markers,
                  ),
              ],
            ),

            // Indicateur de chargement
            if (!_isMapReady)
              Container(
                color: _getBackgroundColor(context).withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Chargement de la carte...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Contrôles de zoom personnalisés
            if (widget.showZoomControls && _isMapReady)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: _buildZoomControls(isDark),
              ),

            // Attribution
            if (widget.showAttribution)
              Positioned(
                bottom: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '© OpenStreetMap',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

            // Indicateur de zoom actuel (debug)
            if (widget.showZoomControls)
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.gray800.withOpacity(0.9)
                        : AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.gray600.withOpacity(0.3)
                          : AppColors.gray300.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls(bool isDark) {
    return Column(
      children: [
        _buildZoomButton(
          icon: Icons.add,
          onPressed: _currentZoom < _maxZoom ? _zoomIn : null,
          isDark: isDark,
        ),
        SizedBox(height: AppSpacing.xs),
        _buildZoomButton(
          icon: Icons.remove,
          onPressed: _currentZoom > _minZoom ? _zoomOut : null,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    final isEnabled = onPressed != null;
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.9)
            : AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDark 
              ? AppColors.gray600.withOpacity(0.3)
              : AppColors.gray300.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Center(
            child: Icon(
              icon,
              color: isEnabled
                  ? (isDark ? AppColors.textLight : AppColors.textPrimary)
                  : (isDark ? AppColors.gray600 : AppColors.gray400),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes publiques pour contrôler la carte depuis l'extérieur
  void moveToLocation(LatLng location, {double? zoom}) {
    if (mounted) {
      try {
        final targetZoom = zoom != null ? _clampZoom(zoom) : _currentZoom;
        _mapController.move(location, targetZoom);
      } catch (e) {
        print('Erreur lors du déplacement vers la location: $e');
      }
    }
  }

  void fitBounds(LatLngBounds bounds, {EdgeInsets? padding}) {
    if (mounted) {
      try {
        _mapController.fitBounds(
          bounds,
          options: FitBoundsOptions(
            padding: padding ?? EdgeInsets.all(20),
            maxZoom: _maxZoom,
          ),
        );
      } catch (e) {
        print('Erreur lors du fit bounds: $e');
      }
    }
  }

  double get currentZoom => _currentZoom;
  LatLng? get currentCenter => _currentCenter;
  bool get isMapReady => _isMapReady;
}