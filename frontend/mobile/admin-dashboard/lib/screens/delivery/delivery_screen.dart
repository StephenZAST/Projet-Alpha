import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/delivery_controller.dart';
// import '../../widgets/shared/glass_container.dart';
import 'components/deliverers_table.dart';
import 'components/delivery_list.dart';
import 'components/delivery_stats_card.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late DeliveryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DeliveryController>()) {
      controller = Get.find<DeliveryController>();
    } else {
      controller = Get.put(DeliveryController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des Livreurs',
                      style: AppTextStyles.h1.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gérez vos livreurs et suivez les livraisons en cours',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal avec tabs
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.gray600,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delivery_dining, size: 18),
                                SizedBox(width: AppSpacing.xs),
                                Text('Livreurs'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_shipping, size: 18),
                                SizedBox(width: AppSpacing.xs),
                                Text('Livraisons'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.analytics, size: 18),
                                SizedBox(width: AppSpacing.xs),
                                Text('Statistiques'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Livreurs
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: DeliverersTable(),
                                  ),
                                ],
                              ),
                            ),

                            // Livraisons actives
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: DeliveryList(),
                                  ),
                                ],
                              ),
                            ),

                            // Statistiques
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  DeliveryStatsCard(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
