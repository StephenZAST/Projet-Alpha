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
              Text('Gestion Livreurs', style: AppTextStyles.h1),
              SizedBox(height: AppSpacing.lg),
              // Tabs
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(tabs: [
                        Tab(text: 'Livreurs'),
                        Tab(text: 'Livraisons Actives'),
                        Tab(text: 'Statistiques'),
                      ]),
                      Expanded(
                        child: TabBarView(children: [
                          // Livreurs
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                DeliverersTable(),
                              ],
                            ),
                          ),

                          // Livraisons actives
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                DeliveryList(),
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
                        ]),
                      )
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
