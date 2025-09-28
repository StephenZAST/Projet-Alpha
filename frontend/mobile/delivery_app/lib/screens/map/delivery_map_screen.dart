import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/map_controller.dart';
import '../../models/delivery_order.dart';
import '../../widgets/shared/glass_container.dart';
import '../../widgets/cards/order_card_mobile.dart';

/// 🗺️ Écran Carte de Livraison - Alpha Delivery App
///
/// Interface mobile-first pour visualiser les commandes sur une carte.
/// Fonctionnalités : markers commandes, position livreur, sélection zones, navigation.
class DeliveryMapScreen extends StatelessWidget {
  const DeliveryMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MapController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: Stack(
        children: [
          // =================================================================
          // 🗺️ CARTE PRINCIPALE
          // =================================================================
          _buildMap(controller, isDark),

          // =================================================================
          // 📱 INTERFACE OVERLAY
          // =================================================================
          SafeArea(
            child: Column(
              children: [
                // Header avec filtres
                _buildHeader(controller, isDark),

                const Spacer(),

                // Bottom sheet avec liste des commandes
                _buildBottomSheet(controller, isDark),
              ],
            ),
          ),

          // =================================================================
          // 🎯 BOUTONS FLOTTANTS
          // =================================================================
          _buildFloatingButtons(controller, isDark),
        ],
      ),
    );
  }

  /// 🗺️ Widget carte principale
  Widget _buildMap(MapController controller, bool isDark) {
    return Obx(() => flutter_map.FlutterMap(
          mapController: controller.mapController,
          options: flutter_map.MapOptions(
            center: controller.currentCenter.value,
            zoom: controller.currentZoom.value,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
            onTap: (tapPosition, point) => controller.onMapTap(point),
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                controller.onMapMove(position.center!, position.zoom!);
              }
            },
          ),
          children: [
            // Tuiles de la carte
            flutter_map.TileLayer(
              urlTemplate: MapConfig.osmTileUrl,
              userAgentPackageName: 'com.alpha.delivery',
              maxZoom: MapConfig.maxZoom,
            ),

            // Markers des commandes
            flutter_map.MarkerLayer(
              markers: controller.orderMarkers.map((orderMarker) {
                return flutter_map.Marker(
                  point: orderMarker.position,
                  width: 40,
                  height: 40,
                  child: _buildOrderMarker(
                    orderMarker.order,
                    orderMarker.isSelected,
                    controller,
                  ),
                );
              }).toList(),
            ),

            // Marker position livreur
            if (controller.deliveryPosition.value != null)
              flutter_map.MarkerLayer(
                markers: [
                  flutter_map.Marker(
                    point: controller.deliveryPosition.value!,
                    width: 50,
                    height: 50,
                    child: _buildDeliveryMarker(isDark),
                  ),
                ],
              ),

            // Cercle de zone sélectionnée
            if (controller.selectedZone.value != null)
              flutter_map.CircleLayer(
                circles: [
                  flutter_map.CircleMarker(
                    point: controller.selectedZone.value!.center,
                    radius: controller.selectedZone.value!.radius,
                    color: AppColors.primary.withOpacity(0.2),
                    borderColor: AppColors.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
          ],
        ));
  }

  /// 📱 Header avec filtres et actions
  Widget _buildHeader(MapController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Bouton retour
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),

            // Titre
            Expanded(
              child: Text(
                'Carte des livraisons',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Filtres rapides
            Obx(() => PopupMenuButton<OrderStatus?>(
                  icon: Icon(
                    Icons.filter_list,
                    color: controller.statusFilter.value != null
                        ? AppColors.primary
                        : (isDark ? AppColors.gray400 : AppColors.gray500),
                  ),
                  onSelected: (status) => controller.setStatusFilter(status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('Toutes les commandes'),
                    ),
                    ...OrderStatus.values.map((status) => PopupMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, color: status.color, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Text(status.displayName),
                            ],
                          ),
                        )),
                  ],
                )),

            // Menu actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
              onSelected: (value) => _handleMenuAction(value, controller),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: AppSpacing.sm),
                      Text('Actualiser'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'center_position',
                  child: Row(
                    children: [
                      Icon(Icons.my_location),
                      SizedBox(width: AppSpacing.sm),
                      Text('Ma position'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'select_zone',
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_unchecked),
                      SizedBox(width: AppSpacing.sm),
                      Text('Sélectionner zone'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Bottom sheet avec liste des commandes
  Widget _buildBottomSheet(MapController controller, bool isDark) {
    return Obx(() => DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardBgDark.withOpacity(0.95)
                    : AppColors.cardBgLight.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.lg),
                  topRight: Radius.circular(AppSpacing.lg),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.3),
                ),
                boxShadow: AppShadows.large,
              ),
              child: Column(
                children: [
                  // Handle du draggable
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray600 : AppColors.gray400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header avec statistiques
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Commandes visibles',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Text(
                            '${controller.visibleOrders.length}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des commandes
                  Expanded(
                    child: controller.visibleOrders.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            itemCount: controller.visibleOrders.length,
                            itemBuilder: (context, index) {
                              final order = controller.visibleOrders[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: OrderCardMobile(
                                  order: order,
                                  onTap: () => controller.selectOrder(order),
                                  onStatusUpdate: (newStatus) => controller
                                      .updateOrderStatus(order.id, newStatus),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  /// 🎯 Boutons flottants
  Widget _buildFloatingButtons(MapController controller, bool isDark) {
    return Positioned(
      right: AppSpacing.md,
      bottom: 120, // Au-dessus du bottom sheet
      child: Column(
        children: [
          // Bouton ma position
          FloatingActionButton(
            heroTag: 'my_location',
            mini: true,
            backgroundColor: AppColors.primary,
            onPressed: () => controller.centerOnDeliveryPosition(),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Bouton zoom sur commandes
          FloatingActionButton(
            heroTag: 'fit_orders',
            mini: true,
            backgroundColor: AppColors.secondary,
            onPressed: () => controller.fitOrdersInView(),
            child: const Icon(Icons.fit_screen, color: Colors.white),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Bouton actualiser
          Obx(() => FloatingActionButton(
                heroTag: 'refresh',
                mini: true,
                backgroundColor: controller.isLoading.value
                    ? AppColors.gray400
                    : AppColors.success,
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.refreshOrders(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
              )),
        ],
      ),
    );
  }

  /// 📍 Marker de commande
  Widget _buildOrderMarker(
    DeliveryOrder order,
    bool isSelected,
    MapController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.selectOrder(order),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        decoration: BoxDecoration(
          color: order.status.color,
          borderRadius: BorderRadius.circular(isSelected ? 25 : 20),
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected ? AppShadows.large : AppShadows.medium,
        ),
        child: Icon(
          order.status.icon,
          color: Colors.white,
          size: isSelected ? 24 : 20,
        ),
      ),
    );
  }

  /// 🚚 Marker position livreur
  Widget _buildDeliveryMarker(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.large,
      ),
      child: const Icon(
        Icons.delivery_dining,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// 📭 État vide
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 60,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucune commande visible',
              style: AppTextStyles.h4.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Déplacez la carte ou ajustez les filtres pour voir les commandes',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎬 Gestion des actions du menu
  void _handleMenuAction(String action, MapController controller) {
    switch (action) {
      case 'refresh':
        controller.refreshOrders();
        break;
      case 'center_position':
        controller.centerOnDeliveryPosition();
        break;
      case 'select_zone':
        controller.startZoneSelection();
        break;
    }
  }
}
