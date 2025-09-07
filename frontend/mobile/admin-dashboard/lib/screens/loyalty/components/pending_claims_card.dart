import '../../../utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/loyalty_controller.dart';
import '../../../models/loyalty.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class PendingClaimsCard extends StatelessWidget {
  const PendingClaimsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoyaltyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.pendingRewardClaims.isEmpty) {
        return SizedBox.shrink();
      }

      return GlassContainer(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Icon(
                      Icons.hourglass_empty_outlined,
                      color: AppColors.warning,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demandes de Récompenses en Attente',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          '${controller.pendingRewardClaims.length} demande${controller.pendingRewardClaims.length > 1 ? 's' : ''} nécessite${controller.pendingRewardClaims.length > 1 ? 'nt' : ''} votre attention',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassButton(
                    label: 'Voir Tout',
                    icon: Icons.arrow_forward_outlined,
                    variant: GlassButtonVariant.primary,
                    size: GlassButtonSize.small,
                    onPressed: () => _showAllPendingClaims(context, controller),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Liste des demandes en attente (max 3)
              Column(
                children: controller.pendingRewardClaims
                    .take(3)
                    .map((claim) =>
                        _buildClaimItem(context, isDark, claim, controller))
                    .toList(),
              ),

              if (controller.pendingRewardClaims.length > 3) ...[
                SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    'et ${controller.pendingRewardClaims.length - 3} autre${controller.pendingRewardClaims.length - 3 > 1 ? 's' : ''}...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildClaimItem(
    BuildContext context,
    bool isDark,
    RewardClaim claim,
    LoyaltyController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar utilisateur
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Informations de la demande
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        claim.user?.email ?? 'Utilisateur inconnu',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Text(
                        claim.formattedPointsUsed,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  claim.reward?.name ?? 'Récompense inconnue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      AppDateUtils.formatDateTime(claim.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Actions rapides
          Column(
            children: [
              GlassButton(
                label: '',
                icon: Icons.check,
                variant: GlassButtonVariant.success,
                size: GlassButtonSize.small,
                onPressed: () => _showApproveDialog(context, claim, controller),
              ),
              SizedBox(height: AppSpacing.xs),
              GlassButton(
                label: '',
                icon: Icons.close,
                variant: GlassButtonVariant.error,
                size: GlassButtonSize.small,
                onPressed: () => _showRejectDialog(context, claim, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllPendingClaims(
      BuildContext context, LoyaltyController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hourglass_empty_outlined,
                    color: AppColors.warning,
                    size: 28,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Demandes de Récompenses en Attente',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(() {
                  if (controller.pendingRewardClaims.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.success.withOpacity(0.7),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune demande en attente',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Toutes les demandes ont été traitées',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.pendingRewardClaims.length,
                    itemBuilder: (context, index) {
                      final claim = controller.pendingRewardClaims[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppRadius.radiusSM,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            claim.user?.email ?? 'Utilisateur inconnu',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claim.reward?.name ?? 'Récompense inconnue',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${claim.formattedPointsUsed} • ${AppDateUtils.formatDateTime(claim.createdAt)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.check, color: AppColors.success),
                                onPressed: () => _showApproveDialog(
                                    context, claim, controller),
                                tooltip: 'Approuver',
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: AppColors.error),
                                onPressed: () => _showRejectDialog(
                                    context, claim, controller),
                                tooltip: 'Rejeter',
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline,
                                    color: AppColors.info),
                                onPressed: () =>
                                    _showClaimDetails(context, claim),
                                tooltip: 'Détails',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Actualiser',
                      icon: Icons.refresh,
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => controller.fetchPendingRewardClaims(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Fermer',
                      variant: GlassButtonVariant.primary,
                      onPressed: () => Get.back(),
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

  void _showApproveDialog(
    BuildContext context,
    RewardClaim claim,
    LoyaltyController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: AppSpacing.sm),
            Text('Approuver la Demande'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir approuver cette demande ?'),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: AppRadius.radiusSM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilisateur: ${claim.user?.email ?? 'Inconnu'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('Récompense: ${claim.reward?.name ?? 'Inconnue'}'),
                  Text('Points utilisés: ${claim.formattedPointsUsed}'),
                  Text('Date: ${AppDateUtils.formatDateTime(claim.createdAt)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.approveRewardClaim(claim.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text('Approuver'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    RewardClaim claim,
    LoyaltyController controller,
  ) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Rejeter la Demande'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pourquoi rejetez-vous cette demande ?'),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Raison du rejet',
                hintText: 'Expliquez pourquoi cette demande est rejetée...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: AppRadius.radiusSM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilisateur: ${claim.user?.email ?? 'Inconnu'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('Récompense: ${claim.reward?.name ?? 'Inconnue'}'),
                  Text('Points utilisés: ${claim.formattedPointsUsed}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                controller.rejectRewardClaim(claim.id, reasonController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showClaimDetails(BuildContext context, RewardClaim claim) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 28,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Détails de la Demande',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Informations utilisateur
              _buildDetailSection(
                'Utilisateur',
                [
                  'Email: ${claim.user?.email ?? 'Inconnu'}',
                  'Nom: ${claim.user?.firstName ?? ''} ${claim.user?.lastName ?? ''}',
                ],
                Icons.person_outline,
                AppColors.primary,
              ),

              SizedBox(height: AppSpacing.lg),

              // Informations récompense
              _buildDetailSection(
                'Récompense',
                [
                  'Nom: ${claim.reward?.name ?? 'Inconnue'}',
                  'Description: ${claim.reward?.description ?? 'Aucune description'}',
                  'Type: ${claim.reward?.type.name ?? 'Inconnu'}',
                  if (claim.reward?.formattedDiscountValue.isNotEmpty == true)
                    'Valeur: ${claim.reward!.formattedDiscountValue}',
                ],
                Icons.card_giftcard,
                AppColors.success,
              ),

              SizedBox(height: AppSpacing.lg),

              // Informations transaction
              _buildDetailSection(
                'Transaction',
                [
                  'Points utilisés: ${claim.formattedPointsUsed}',
                  'Statut: ${claim.statusLabel}',
                  'Date de demande: ${AppDateUtils.formatDateTime(claim.createdAt)}',
                  if (claim.processedAt != null)
                    'Date de traitement: ${AppDateUtils.formatDateTime(claim.processedAt!)}',
                ],
                Icons.swap_horiz,
                AppColors.warning,
              ),

              SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Fermer',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
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

  Widget _buildDetailSection(
    String title,
    List<String> details,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ...details.map((detail) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  detail,
                  style: AppTextStyles.bodySmall,
                ),
              )),
        ],
      ),
    );
  }
}
