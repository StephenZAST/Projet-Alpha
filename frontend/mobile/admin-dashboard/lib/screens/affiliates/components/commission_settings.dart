import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliate_controller.dart';

class CommissionSettings extends StatelessWidget {
  const CommissionSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateController>();
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
                TextFormField(
                  initialValue: controller.commissionRate.value.toString(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Entrez le taux de commission',
                    suffixText: '%',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      controller.commissionRate.value =
                          double.tryParse(value) ?? 0.0;
                    }
                  },
                ),
                SizedBox(height: defaultPadding),
                // Points de fidélité
                Text(
                  'Points de Fidélité par Parrainage',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  initialValue: controller.rewardPoints.value.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Entrez les points de fidélité',
                    suffixText: 'points',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      controller.rewardPoints.value = int.tryParse(value) ?? 0;
                    }
                  },
                ),
                SizedBox(height: defaultPadding * 2),
                // Bouton de sauvegarde
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Enregistrer les modifications'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () {
                        controller.updateCommissionSettings(
                          controller.commissionRate.value,
                          controller.rewardPoints.value,
                        );
                      },
                    ),
                  ],
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
                    controller.activeAffiliates.toString(),
                    Icons.people_outline,
                    AppColors.success,
                    isDark,
                  ),
                  _buildStatTile(
                    'Commissions Totales',
                    '${controller.totalCommissionsPaid.toStringAsFixed(2)} €',
                    Icons.monetization_on_outlined,
                    AppColors.accent,
                    isDark,
                  ),
                  _buildStatTile(
                    'Demandes en Attente',
                    controller.pendingWithdrawals.toString(),
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
