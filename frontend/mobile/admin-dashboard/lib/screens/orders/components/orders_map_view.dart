import 'package:admin/models/order_map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/order_map_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../models/enums.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'order_map_filters.dart';
import 'order_map_marker.dart';
import 'order_map_info_panel.dart';
import 'order_map_details_dialog.dart';

class OrdersMapView extends StatefulWidget {
  @override
  _OrdersMapViewState createState() => _OrdersMapViewState();
}

class _OrdersMapViewState extends State<OrdersMapView>
    with TickerProviderStateMixin {
  late OrderMapController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrderMapController());
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: double.infinity,
            child: Column(
              children: [
                // Header avec statistiques et contrôles
                _buildMapHeader(isDark),
                SizedBox(height: AppSpacing.md),

                // Zone principale avec carte et panneau d'informations
                Expanded(
                  child: Row(
                    children: [
                      // Panneau de filtres (gauche)
                      Container(
                        width: 320,
                        child: OrderMapFilters(),
                      ),
                      SizedBox(width: AppSpacing.md),

                      // Zone carte principale
                      Expanded(
                        flex: 3,
                        child: _buildMapContainer(isDark),
                      ),
                      SizedBox(width: AppSpacing.md),

                      // Panneau d'informations (droite)
                      Container(
                        width: 300,
                        child: OrderMapInfoPanel(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapHeader(bool isDark) {
    return Obx(() {
      final stats = controller.quickStats;

      return GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            // Titre et contrôles
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.map,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carte des Commandes',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Visualisation géographique des commandes',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMapControls(),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    stats['total']?.toString() ?? '0',
                    Icons.receipt,
                    AppColors.primary,
                    isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'En cours',
                    stats['processing']?.toString() ?? '0',
                    Icons.pending_actions,
                    AppColors.warning,
                    isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Livrées',
                    stats['delivered']?.toString() ?? '0',
                    Icons.check_circle,
                    AppColors.success,
                    isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Flash',
                    stats['flash']?.toString() ?? '0',
                    Icons.flash_on,
                    AppColors.accent,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMapControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton clusters
        Obx(() => _buildControlButton(
          icon: controller.showClusters.value ? Icons.scatter_plot : Icons.scatter_plot_outlined,
          label: 'Clusters',
          isActive: controller.showClusters.value,
          onPressed: controller.toggleClusters,
        )),
        SizedBox(width: AppSpacing.sm),

        // Bouton heatmap
        Obx(() => _buildControlButton(
          icon: controller.showHeatmap.value ? Icons.whatshot : Icons.whatshot_outlined,
          label: 'Heatmap',
          isActive: controller.showHeatmap.value,
          onPressed: controller.toggleHeatmap,
        )),
        SizedBox(width: AppSpacing.sm),

        // Bouton auto-refresh
        Obx(() => _buildControlButton(
          icon: controller.autoRefresh.value ? Icons.autorenew : Icons.refresh,
          label: 'Auto',
          isActive: controller.autoRefresh.value,
          onPressed: controller.toggleAutoRefresh,
        )),
        SizedBox(width: AppSpacing.sm),

        // Bouton thème de la carte
        Obx(() => _buildThemeButton()),
        SizedBox(width: AppSpacing.sm),

        // Bouton actualiser
        _buildControlButton(
          icon: Icons.refresh,
          label: 'Actualiser',
          onPressed: controller.refresh,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive 
                ? AppColors.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isActive 
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            color: isActive 
                ? AppColors.primary
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.gray400
                    : AppColors.gray600),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(isDark);
      }

      if (controller.hasError.value) {
        return _buildErrorState(isDark);
      }

      if (controller.mapOrders.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return _buildMapWidget(isDark);
    });
  }

  Widget _buildLoadingState(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chargement de la carte...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Récupération des commandes avec coordonnées GPS',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Réessayer',
              icon: Icons.refresh,
              onPressed: controller.refresh,
              variant: GlassButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande trouvée',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Aucune commande avec coordonnées GPS ne correspond aux filtres sélectionnés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Réinitialiser les filtres',
              icon: Icons.filter_alt_off,
              onPressed: controller.clearFilters,
              variant: GlassButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWidget(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lg,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Carte OpenStreetMap réelle
            Obx(() => FlutterMap(
              options: MapOptions(
                center: controller.mapCenter.value != null 
                    ? LatLng(
                        controller.mapCenter.value!.latitude,
                        controller.mapCenter.value!.longitude,
                      )
                    : LatLng(12.3714, -1.5197), // Ouagadougou par défaut
                zoom: controller.mapZoom.value,
                minZoom: 3.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  // Désélectionner la commande si on clique sur la carte
                  controller.deselectOrder();
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    controller.updateMapCenter(OrderCoordinates(
                      latitude: position.center!.latitude,
                      longitude: position.center!.longitude,
                    ));
                    controller.updateMapZoom(position.zoom!);
                  }
                },
              ),
              children: [
                // Couche de tuiles OpenStreetMap
                TileLayer(
                  urlTemplate: controller.getMapTileUrl(context),
                  userAgentPackageName: 'com.alpha.admin',
                  maxZoom: 18,
                  backgroundColor: controller.isMapDark(context) ? AppColors.gray900 : AppColors.gray100,
                ),
                
                // Marqueurs des commandes
                MarkerLayer(
                  markers: controller.mapOrders.map((order) {
                    return Marker(
                      point: LatLng(
                        order.coordinates.latitude,
                        order.coordinates.longitude,
                      ),
                      width: 40,
                      height: 40,
                      builder: (context) => GestureDetector(
                        onTap: () => _handleMarkerTap(order),
                        child: OrderMapMarker(
                          order: order,
                          onTap: () => _handleMarkerTap(order),
                          isSelected: controller.selectedOrder.value?.id == order.id,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            )),

            // Contrôles de zoom personnalisés
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _buildZoomControls(isDark),
            ),

            // Légende
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              child: _buildMapLegend(isDark),
            ),

            // Attribution OpenStreetMap
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
          ],
        ),
      ),
    );
  }

  Widget _buildMapGrid(bool isDark) {
    return CustomPaint(
      size: Size.infinite,
      painter: MapGridPainter(
        color: isDark 
            ? AppColors.gray700.withOpacity(0.3)
            : AppColors.gray300.withOpacity(0.5),
      ),
    );
  }

  Widget _buildZoomControls(bool isDark) {
    return Column(
      children: [
        GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.xs),
          borderRadius: AppRadius.sm,
          child: IconButton(
            icon: Icon(Icons.add, size: 20),
            onPressed: () {
              controller.updateMapZoom(controller.mapZoom.value + 1);
            },
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.xs),
          borderRadius: AppRadius.sm,
          child: IconButton(
            icon: Icon(Icons.remove, size: 20),
            onPressed: () {
              controller.updateMapZoom((controller.mapZoom.value - 1).clamp(1.0, 20.0));
            },
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMapLegend(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Légende',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildLegendItem('En attente', AppColors.warning, isDark),
          _buildLegendItem('En cours', AppColors.primary, isDark),
          _buildLegendItem('Livrée', AppColors.success, isDark),
          _buildLegendItem('Flash', AppColors.accent, isDark),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires pour le positionnement des marqueurs
  double _calculateMarkerX(double longitude) {
    // Simulation du calcul de position X basé sur la longitude
    // Dans une vraie implémentation, cela dépendrait de la projection de la carte
    return (longitude + 180) * 2; // Exemple simplifié
  }

  double _calculateMarkerY(double latitude) {
    // Simulation du calcul de position Y basé sur la latitude
    // Dans une vraie implémentation, cela dépendrait de la projection de la carte
    return (90 - latitude) * 2; // Exemple simplifié
  }

  void _handleMarkerTap(order) {
    controller.selectOrder(order);
    
    // Ouvrir le dialog de détails spécifique à la carte
    Get.dialog(
      OrderMapDetailsDialog(order: order),
    );
  }

  Widget _buildThemeButton() {
    IconData getThemeIcon() {
      switch (controller.mapTheme.value) {
        case 'light':
          return Icons.light_mode;
        case 'dark':
          return Icons.dark_mode;
        case 'auto':
        default:
          return Icons.brightness_auto;
      }
    }

    String getThemeLabel() {
      switch (controller.mapTheme.value) {
        case 'light':
          return 'Carte claire';
        case 'dark':
          return 'Carte sombre';
        case 'auto':
        default:
          return 'Thème auto';
      }
    }

    return PopupMenuButton<String>(
      onSelected: (String theme) {
        controller.setMapTheme(theme);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'auto',
          child: Row(
            children: [
              Icon(Icons.brightness_auto, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Automatique'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'light',
          child: Row(
            children: [
              Icon(Icons.light_mode, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Clair'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'dark',
          child: Row(
            children: [
              Icon(Icons.dark_mode, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Sombre'),
            ],
          ),
        ),
      ],
      child: Tooltip(
        message: getThemeLabel(),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            getThemeIcon(),
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray400
                : AppColors.gray600,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Painter pour la grille de fond de la carte
class MapGridPainter extends CustomPainter {
  final Color color;

  MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Lignes verticales
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Lignes horizontales
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}