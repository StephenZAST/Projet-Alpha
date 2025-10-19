import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/map_controller.dart' as app;
import '../../models/delivery_order.dart';
import '../../widgets/shared/glass_container.dart';
import '../../widgets/shared/order_details_bottom_sheet.dart';

/// 🗺️ Écran Carte de Livraison - Alpha Delivery App
///
/// Page map simple et fonctionnelle pour visualiser les commandes
class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  late final app.MapController controller;
  late final RxDouble bottomSheetHeight;
  late final RxBool isExpanded;

  @override
  void initState() {
    super.initState();
    debugPrint('🗺️ [DeliveryMapScreen] initState - Initialisation de l\'écran');
    
    // Initialiser les variables réactives
    bottomSheetHeight = 200.0.obs;
    isExpanded = false.obs;
    
    // Obtenir le contrôleur
    try {
      controller = Get.find<app.MapController>();
      debugPrint('✅ [DeliveryMapScreen] MapController trouvé');
    } catch (e) {
      debugPrint('❌ [DeliveryMapScreen] Erreur: MapController non trouvé - $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('🗺️ [DeliveryMapScreen] build() - Reconstruction du widget');

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: _buildHeader(controller, isDark),
          ),

          // Carte
          Expanded(
            child: GetBuilder<app.MapController>(
              builder: (ctrl) {
                debugPrint('🗺️ [DeliveryMapScreen] GetBuilder rebuild - Markers: ${ctrl.orderMarkers.length}');
                return fm.FlutterMap(
                  mapController: ctrl.mapController,
                  options: fm.MapOptions(
                    initialCenter: ctrl.currentCenter.value,
                    initialZoom: ctrl.currentZoom.value,
                    minZoom: MapConfig.minZoom,
                    maxZoom: MapConfig.maxZoom,
                    onTap: (tapPosition, point) => ctrl.onMapTap(point),
                  ),
                  children: [
                    // Tuiles de la carte
                    fm.TileLayer(
                      urlTemplate: MapConfig.osmTileUrl,
                      userAgentPackageName: 'com.alpha.delivery',
                    ),

                    // Markers des commandes
                    Obx(() => fm.MarkerLayer(
                          markers: ctrl.orderMarkers.map((om) {
                            return fm.Marker(
                              point: om.position,
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint('🎯 [DeliveryMapScreen] Marker cliqué: ${om.order.shortId}');
                                  ctrl.selectOrder(om.order);
                                  _showOrderDetails(om.order, ctrl);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: om.order.statusColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: om.isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    om.order.statusIcon,
                                    color: Colors.white,
                                    size: om.isSelected ? 24 : 20,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )),

                    // Marker position livreur
                    Obx(() {
                      if (ctrl.deliveryPosition.value == null) {
                        return const SizedBox.shrink();
                      }
                      return fm.MarkerLayer(
                        markers: [
                          fm.Marker(
                            point: ctrl.deliveryPosition.value!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delivery_dining,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Bottom sheet avec hauteur variable
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: bottomSheetHeight.value,
                child: _buildBottomSheet(
                  controller,
                  isDark,
                  isExpanded,
                  bottomSheetHeight,
                ),
              )),
        ],
      ),

      // Boutons flottants
      floatingActionButton: _buildFloatingButtons(controller),
    );
  }

  /// Header avec filtres
  Widget _buildHeader(app.MapController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: Text(
                'Carte des livraisons',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
                      child: Text('Toutes'),
                    ),
                    ...OrderStatus.values.map((status) => PopupMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, color: status.color, size: 20),
                              const SizedBox(width: 8),
                              Text(status.displayName),
                            ],
                          ),
                        )),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet avec liste et bouton expand/collapse
  Widget _buildBottomSheet(
    app.MapController controller,
    bool isDark,
    RxBool isExpanded,
    RxDouble bottomSheetHeight,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle + bouton expand/collapse
          GestureDetector(
            onTap: () {
              isExpanded.value = !isExpanded.value;
              bottomSheetHeight.value = isExpanded.value ? 500.0 : 200.0;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray600 : AppColors.gray400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Icon(
                        isExpanded.value
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        size: 20,
                      )),
                ],
              ),
            ),
          ),

          // Header avec statistiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Commandes',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${controller.visibleOrders.length}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Liste des commandes
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshOrders(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.visibleOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Aucune commande',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Les commandes assignées apparaîtront ici',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray500 : AppColors.gray500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: controller.visibleOrders.length + (controller.hasMorePages.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Dernier item = bouton "Charger plus"
                  if (index == controller.visibleOrders.length) {
                    return Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: controller.isLoadingMore.value
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => controller.loadMoreOrders(),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Charger plus'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.md,
                                    ),
                                  ),
                                ),
                        ));
                  }

                  final order = controller.visibleOrders[index];
                  return _buildOrderItem(order, isDark, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Item de commande
  Widget _buildOrderItem(
      DeliveryOrder order, bool isDark, app.MapController controller) {
    return GestureDetector(
      onTap: () {
        // Sélectionner sur la carte
        controller.selectOrder(order);
        // Afficher les détails en bottom sheet
        _showOrderDetails(order, controller);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: order.statusColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: order.statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.shortId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order.customerName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  Text(
                    order.shortAddress,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray500 : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  order.statusIcon,
                  color: order.statusColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  order.formattedAmount,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche les détails de la commande
  void _showOrderDetails(DeliveryOrder order, app.MapController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsBottomSheet(
        order: order,
        onStatusUpdate: (newStatus) {
          controller.updateOrderStatus(order.id, newStatus);
        },
        onClose: () {
          controller.clearSelection();
        },
      ),
    );
  }

  /// Boutons flottants
  Widget _buildFloatingButtons(app.MapController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'location',
          mini: true,
          backgroundColor: AppColors.primary,
          onPressed: () => controller.centerOnDeliveryPosition(),
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'fit',
          mini: true,
          backgroundColor: AppColors.secondary,
          onPressed: () => controller.fitOrdersInView(),
          child: const Icon(Icons.fit_screen, color: Colors.white),
        ),
        const SizedBox(height: 8),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            )),
      ],
    );
  }
}
