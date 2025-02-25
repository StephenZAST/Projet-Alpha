import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/delivery_controller.dart';
import '../../constants.dart';
import '../../services/map_service.dart';
import 'components/delivery_stats_card.dart';
import 'components/delivery_filters.dart';
import 'components/delivery_list.dart';

class DeliveryDashboardScreen extends StatelessWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeliveryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          // Carte et statistiques (2/3 de l'écran)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                DeliveryStatsCard(),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusMD,
                      child: Obx(() => FlutterMap(
                            mapController: controller.mapController.value,
                            options: MapOptions(
                              center: MapService.defaultCenter,
                              zoom: MapService.defaultZoom,
                              interactiveFlags: InteractiveFlag.all,
                            ),
                            children: [
                              MapService.baseMapTile,
                              MarkerLayer(
                                markers: controller.markers.value,
                              ),
                              PolylineLayer(
                                polylines: controller.routes.value,
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Liste des livraisons (1/3 de l'écran)
          Expanded(
            child: Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              margin: EdgeInsets.only(left: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  DeliveryFilters(),
                  Expanded(child: DeliveryList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
