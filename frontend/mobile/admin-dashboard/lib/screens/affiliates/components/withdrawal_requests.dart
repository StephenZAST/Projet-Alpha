import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliate_controller.dart';
import '../../../models/affiliate.dart';

class WithdrawalRequests extends StatelessWidget {
  const WithdrawalRequests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec statistiques
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demandes en attente',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Obx(() => Text(
                          '${controller.pendingWithdrawals} demande(s)',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.warning,
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total payé',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Obx(() => Text(
                          '${controller.totalCommissionsPaid.toStringAsFixed(2)} €',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.success,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: defaultPadding),
        // Liste des demandes
        Expanded(
          child: Container(
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

              if (controller.withdrawalRequests.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune demande de retrait en attente',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.withdrawalRequests.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final request = controller.withdrawalRequests[index];
                  return ListTile(
                    title: Text(
                      'Demande de ${request.amount.toStringAsFixed(2)} €',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'ID: ${request.id}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.textMuted,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.check_circle_outline),
                          label: Text('Approuver'),
                          style: TextButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.success.withOpacity(0.1)
                                : Colors.transparent,
                            foregroundColor: AppColors.success,
                          ),
                          onPressed: () =>
                              controller.approveWithdrawal(request.id),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        TextButton.icon(
                          icon: Icon(Icons.cancel_outlined),
                          label: Text('Rejeter'),
                          style: TextButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.error.withOpacity(0.1)
                                : Colors.transparent,
                            foregroundColor: AppColors.error,
                          ),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: Text('Rejeter la demande'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        'Veuillez indiquer la raison du rejet'),
                                    SizedBox(height: AppSpacing.md),
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Raison du rejet',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) => controller
                                          .rejectionReason.value = value,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Annuler'),
                                    onPressed: () => Get.back(),
                                  ),
                                  TextButton(
                                    child: Text('Confirmer'),
                                    onPressed: () {
                                      if (controller
                                          .rejectionReason.value.isNotEmpty) {
                                        controller.rejectWithdrawal(
                                          request.id,
                                          controller.rejectionReason.value,
                                        );
                                        Get.back();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
