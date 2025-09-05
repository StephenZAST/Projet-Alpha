import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';

class CommissionSettings extends StatelessWidget {
  const CommissionSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration du Programme d\'Affiliation',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: defaultPadding),
        // Formulaire de configuration
        Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Taux de commission
                Text(
                  'Taux de Commission',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Configuration des commissions disponible dans une version future',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: defaultPadding),
        // Statistiques du programme
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiques du Programme',
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatTile(
                    'Affiliés Actifs',
                    controller.stats.value?.activeAffiliates.toString() ?? '0',
                    Icons.people_outline,
                    AppColors.success,
                    isDark,
                  ),
                  _buildStatTile(
                    'Commissions Totales',
                    controller.stats.value?.formattedTotalCommissions ?? '0 FCFA',
                    Icons.monetization_on_outlined,
                    AppColors.accent,
                    isDark,
                  ),
                  _buildStatTile(
                    'Demandes en Attente',
                    controller.pendingWithdrawals.length.toString(),
                    Icons.access_time,
                    AppColors.warning,
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
