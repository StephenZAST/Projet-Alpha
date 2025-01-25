import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/affiliate.dart';
import '../../../controllers/affiliate_controller.dart';

class AffiliateFilters extends StatelessWidget {
  const AffiliateFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Barre de recherche et filtres
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.searchAffiliates,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un affilié...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                    fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Filtre par statut
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray800 : AppColors.gray100,
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Obx(() => DropdownButton<String?>(
                      value: controller.selectedStatus.value,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'Tous les statuts',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ...AffiliateStatus.values
                            .map((status) => DropdownMenuItem(
                                  value: status.toString().split('.').last,
                                  child: Text(
                                    status.label,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textLight
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                )),
                      ],
                      onChanged: controller.filterByStatus,
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.filter_list,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    )),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // Statistiques des affiliés
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildStatCard(
                      'Affiliés Actifs',
                      controller.activeAffiliates.toString(),
                      AppColors.success,
                      Icons.check_circle_outline,
                      isDark,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildStatCard(
                      'En Attente',
                      controller.pendingWithdrawals.toString(),
                      AppColors.warning,
                      Icons.access_time,
                      isDark,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildStatCard(
                      'Total Commissions',
                      '${controller.totalCommissionsPaid.toStringAsFixed(2)} €',
                      AppColors.violet,
                      Icons.monetization_on_outlined,
                      isDark,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              icon,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
