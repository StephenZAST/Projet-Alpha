import 'package:admin/models/affiliate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/affiliates_controller.dart';
import '../../widgets/shared/glass_button.dart';
import 'components/affiliate_stats_grid.dart';
import 'components/affiliate_table.dart';
import 'components/affiliate_filters.dart';
import 'components/pending_withdrawals_card.dart';

class AffiliatesScreen extends StatefulWidget {
  const AffiliatesScreen({Key? key}) : super(key: key);

  @override
  State<AffiliatesScreen> createState() => _AffiliatesScreenState();
}

class _AffiliatesScreenState extends State<AffiliatesScreen> {
  late AffiliatesController controller;

  @override
  void initState() {
    super.initState();
    print('[AffiliatesScreen] initState: Initialisation');

    // S'assurer que le contrôleur existe et est unique
    if (Get.isRegistered<AffiliatesController>()) {
      controller = Get.find<AffiliatesController>();
    } else {
      controller = Get.put(AffiliatesController(), permanent: true);
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
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),

              // Statistiques
              AffiliateStatsGrid(),
              SizedBox(height: AppSpacing.lg),

              // Demandes de retrait en attente (si il y en a)
              Obx(() {
                if (controller.pendingWithdrawals.isNotEmpty) {
                  return Column(
                    children: [
                      PendingWithdrawalsCard(),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }
                return SizedBox.shrink();
              }),

              // Filtres et recherche
              AffiliateFilters(),
              SizedBox(height: AppSpacing.md),

              // Table des affiliés
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Chargement des affiliés...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredAffiliates.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }

                  return AffiliateTable();
                }),
              ),

              // Pagination
              SizedBox(height: AppSpacing.md),
              _buildPagination(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Affiliés',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
                  controller.isLoading.value
                      ? 'Chargement...'
                      : '${controller.totalAffiliates.value} affilié${controller.totalAffiliates.value > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Niveaux',
              icon: Icons.military_tech_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showAffiliateLevels(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Retraits',
              icon: Icons.account_balance_wallet_outlined,
              variant: GlassButtonVariant.secondary,
              onPressed: () => _showWithdrawalsDialog(context),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.primary,
              size: GlassButtonSize.small,
              onPressed: () {
                print('[AffiliatesScreen] Bouton Actualiser cliqué');
                controller.refreshAll();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun affilié trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.searchQuery.value.isNotEmpty ||
                    controller.selectedStatus.value != null
                ? 'Aucun affilié ne correspond à vos critères de recherche'
                : 'Aucun affilié n\'est encore enregistré dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller.searchQuery.value.isNotEmpty ||
              controller.selectedStatus.value != null)
            GlassButton(
              label: 'Effacer les filtres',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller.searchQuery.value = '';
                controller.selectedStatus.value = null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.gray800.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.chevron_left,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: '',
                  icon: Icons.chevron_right,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showAffiliateLevels(BuildContext context) {
    // Affiche les niveaux d'affiliation selon la configuration backend (constants.ts)
    final commissionLevels = [
      {
        'name': 'BRONZE',
        'minEarnings': 0,
        'commissionRate': 10,
      },
      {
        'name': 'SILVER',
        'minEarnings': 100000,
        'commissionRate': 12,
      },
      {
        'name': 'GOLD',
        'minEarnings': 500000,
        'commissionRate': 15,
      },
      {
        'name': 'PLATINUM',
        'minEarnings': 1000000,
        'commissionRate': 18,
      },
    ];

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Niveaux d\'Affiliation',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              Column(
                children: commissionLevels.map((level) {
                  return ListTile(
                    leading:
                        Icon(Icons.military_tech, color: AppColors.primary),
                    title: Text(level['name'].toString()),
                    subtitle: Text(
                        'Min. gains: ${level['minEarnings'].toString()} FCFA'),
                    trailing: Text(
                        '${level['commissionRate'].toString()}% commission'),
                  );
                }).toList(),
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalsDialog(BuildContext context) {
    // TODO: Implémenter le dialog des retraits
    Get.dialog(
      Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                'Demandes de Retrait',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingWithdrawals.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.withdrawals.isEmpty) {
                    return Center(child: Text('Aucune demande de retrait'));
                  }

                  return ListView.builder(
                    itemCount: controller.withdrawals.length,
                    itemBuilder: (context, index) {
                      final withdrawal = controller.withdrawals[index];
                      return ListTile(
                        title: Text(withdrawal.formattedAmount),
                        subtitle: Text(withdrawal.statusLabel),
                        trailing: withdrawal.status == WithdrawalStatus.PENDING
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check,
                                        color: AppColors.success),
                                    onPressed: () => controller
                                        .approveWithdrawal(withdrawal.id),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: AppColors.error),
                                    onPressed: () =>
                                        _showRejectDialog(withdrawal.id),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(String withdrawalId) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rejeter la demande',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Raison du rejet',
                  hintText: 'Expliquez pourquoi cette demande est rejetée...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Rejeter',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        if (reasonController.text.isNotEmpty) {
                          controller.rejectWithdrawal(
                              withdrawalId, reasonController.text);
                          Get.back();
                          Get.back(); // Fermer aussi le dialog des retraits
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
