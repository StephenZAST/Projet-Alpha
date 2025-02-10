import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/delivery_controller.dart';
import '../../constants.dart';
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
                      child: Obx(() => GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(48.8566, 2.3522),
                              zoom: 12,
                            ),
                            markers: controller.markers,
                            onMapCreated: (GoogleMapController mapController) {
                              controller.mapController.value = mapController;
                            },
                            mapType: isDark ? MapType.normal : MapType.normal,
                            myLocationEnabled: true,
                            compassEnabled: true,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
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
