import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../models/affiliate.dart';

class AffiliateList extends StatelessWidget {
  const AffiliateList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      // Les erreurs sont gérées par le snackbar dans le controller

      if (controller.affiliates.isEmpty) {
        return Center(
          child: Text(
            'Aucun affilié trouvé',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppColors.gray800 : AppColors.gray100,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.gray700 : AppColors.gray200;
                }
                return isDark ? AppColors.gray900 : Colors.white;
              },
            ),
            columns: [
              DataColumn(
                label: Text(
                  'Nom',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Code',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Commission',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Total Gagné',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Statut',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            rows: controller.affiliates.map((affiliate) {
              final textColor =
                  isDark ? AppColors.textLight : AppColors.textPrimary;
              final mutedColor =
                  isDark ? AppColors.gray400 : AppColors.textMuted;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      affiliate.fullName,
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: textColor),
                    ),
                  ),
                  DataCell(
                    Text(
                      affiliate.email,
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: textColor),
                    ),
                  ),
                  DataCell(
                    Text(
                      affiliate.affiliateCode,
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: mutedColor),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${affiliate.commissionBalance.toStringAsFixed(2)} €',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: textColor),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${affiliate.totalEarned.toStringAsFixed(2)} €',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: textColor),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: affiliate.status.color.withOpacity(0.2),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Text(
                        affiliate.status.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: affiliate.status.color,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.verified_outlined),
                          color: affiliate.isActive
                              ? AppColors.success
                              : AppColors.gray400,
                          tooltip:
                              affiliate.isActive ? 'Désactiver' : 'Activer',
                          onPressed: () => controller.updateAffiliateStatus(
                            affiliate.id,
                            affiliate.isActive
                                ? AffiliateStatus.SUSPENDED
                                : AffiliateStatus.ACTIVE,
                            !affiliate.isActive,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.block),
                          color: affiliate.status == AffiliateStatus.SUSPENDED
                              ? AppColors.error
                              : AppColors.gray400,
                          tooltip: 'Suspendre/Réactiver',
                          onPressed: () => controller.updateAffiliateStatus(
                            affiliate.id,
                            affiliate.status == AffiliateStatus.SUSPENDED
                                ? AffiliateStatus.ACTIVE
                                : AffiliateStatus.SUSPENDED,
                            affiliate.isActive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
