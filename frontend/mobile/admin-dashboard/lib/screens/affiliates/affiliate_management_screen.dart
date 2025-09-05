import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/affiliates_controller.dart';
import '../../widgets/shared/pagination_controls.dart';
import 'components/affiliate_list.dart';
import 'components/affiliate_filters.dart';
import 'components/withdrawal_requests.dart';
import 'components/commission_settings.dart';

class AffiliateManagementScreen extends StatefulWidget {
  @override
  _AffiliateManagementScreenState createState() =>
      _AffiliateManagementScreenState();
}

class _AffiliateManagementScreenState extends State<AffiliateManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AffiliatesController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller = Get.put(AffiliatesController());
    controller.fetchAffiliates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des Affiliés',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: defaultPadding),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    isDark ? AppColors.gray400 : AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Liste des affiliés'),
                  Tab(text: 'Demandes de retrait'),
                  Tab(text: 'Paramètres'),
                ],
              ),
              SizedBox(height: defaultPadding),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Liste des affiliés
                    Column(
                      children: [
                        AffiliateFilters(),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          child: AffiliateList(),
                        ),
                        Obx(() => PaginationControls(
                              currentPage: controller.currentPage.value,
                              totalPages: controller.totalPages.value,
                              itemsPerPage: controller.itemsPerPage.value,
                              totalItems: controller.totalAffiliates.value,
                              onNextPage: controller.nextPage,
                              onPreviousPage: controller.previousPage,
                              onItemsPerPageChanged: controller.setItemsPerPage,
                            )),
                      ],
                    ),
                    // Demandes de retrait
                    WithdrawalRequests(),
                    // Paramètres des commissions
                    CommissionSettings(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
