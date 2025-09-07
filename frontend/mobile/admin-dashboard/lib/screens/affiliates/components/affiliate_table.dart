import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../models/affiliate.dart';
import '../../../widgets/shared/glass_button.dart';
import 'affiliate_details_dialog.dart';

class AffiliateTable extends StatelessWidget {
  const AffiliateTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.gray800.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildTableHeader(context, isDark, controller),
                Expanded(
                  child: Obx(() => ListView.separated(
                        itemCount: controller.filteredAffiliates.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.gray700.withOpacity(0.3)
                              : AppColors.gray200.withOpacity(0.5),
                        ),
                        itemBuilder: (context, index) {
                          final affiliate =
                              controller.filteredAffiliates[index];
                          return _buildTableRow(
                              context, isDark, affiliate, controller);
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(
      BuildContext context, bool isDark, AffiliatesController controller) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray900.withOpacity(0.3)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Affilié', flex: 3, isDark: isDark),
          _buildHeaderCell('Code', flex: 2, isDark: isDark),
          _buildHeaderCell('Statut', flex: 2, isDark: isDark),
          _buildHeaderCell('Commission', flex: 2, isDark: isDark),
          _buildHeaderCell('Total Gagné', flex: 2, isDark: isDark),
          _buildHeaderCell('Filleuls', flex: 1, isDark: isDark),
          _buildHeaderCell('Actions', flex: 2, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title,
      {required int flex, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.bodyBold.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    bool isDark,
    AffiliateProfile affiliate,
    AffiliatesController controller,
  ) {
    return InkWell(
      onTap: () => _showAffiliateDetails(context, affiliate),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Affilié (nom, email)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    affiliate.fullName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    affiliate.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Code d'affiliation
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusXS,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  affiliate.affiliateCode,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            // Statut
            Expanded(
              flex: 2,
              child: _buildStatusBadge(affiliate.status, isDark),
            ),

            // Commission
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    affiliate.formattedCommissionRate,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    affiliate.formattedBalance,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Total gagné
            Expanded(
              flex: 2,
              child: Text(
                affiliate.formattedTotalEarned,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Nombre de filleuls
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppRadius.radiusXS,
                ),
                child: Text(
                  affiliate.totalReferrals.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  GlassButton(
                    label: '',
                    icon: Icons.visibility_outlined,
                    variant: GlassButtonVariant.info,
                    size: GlassButtonSize.small,
                    onPressed: () => _showAffiliateDetails(context, affiliate),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  GlassButton(
                    label: '',
                    icon: affiliate.isActive ? Icons.block : Icons.check_circle,
                    variant: affiliate.isActive
                        ? GlassButtonVariant.warning
                        : GlassButtonVariant.success,
                    size: GlassButtonSize.small,
                    onPressed: () =>
                        _toggleAffiliateStatus(affiliate, controller),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      size: 18,
                    ),
                    onSelected: (value) =>
                        _handleMenuAction(value, affiliate, controller),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16),
                            SizedBox(width: AppSpacing.sm),
                            Text('Détails'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'commissions',
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 16),
                            SizedBox(width: AppSpacing.sm),
                            Text('Commissions'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'referrals',
                        child: Row(
                          children: [
                            Icon(Icons.people_outline, size: 16),
                            SizedBox(width: AppSpacing.sm),
                            Text('Filleuls'),
                          ],
                        ),
                      ),
                      if (affiliate.status == AffiliateStatus.PENDING)
                        PopupMenuItem(
                          value: 'approve',
                          child: Row(
                            children: [
                              Icon(Icons.check,
                                  size: 16, color: AppColors.success),
                              SizedBox(width: AppSpacing.sm),
                              Text('Approuver',
                                  style: TextStyle(color: AppColors.success)),
                            ],
                          ),
                        ),
                      if (affiliate.status == AffiliateStatus.ACTIVE)
                        PopupMenuItem(
                          value: 'suspend',
                          child: Row(
                            children: [
                              Icon(Icons.block,
                                  size: 16, color: AppColors.warning),
                              SizedBox(width: AppSpacing.sm),
                              Text('Suspendre',
                                  style: TextStyle(color: AppColors.warning)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AffiliateStatus status, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
        border: Border.all(
          color: status.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            color: status.color,
            size: 14,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            status.name,
            style: AppTextStyles.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAffiliateDetails(BuildContext context, AffiliateProfile affiliate) {
    Get.dialog(
      AffiliateDetailsDialog(affiliate: affiliate),
      barrierDismissible: true,
    );
  }

  void _toggleAffiliateStatus(
      AffiliateProfile affiliate, AffiliatesController controller) {
    final newStatus =
        affiliate.isActive ? AffiliateStatus.SUSPENDED : AffiliateStatus.ACTIVE;
    controller.updateAffiliateStatus(
        affiliate.id, newStatus, !affiliate.isActive);
  }

  void _handleMenuAction(String action, AffiliateProfile affiliate,
      AffiliatesController controller) {
    switch (action) {
      case 'details':
        _showAffiliateDetails(Get.context!, affiliate);
        break;
      case 'commissions':
        controller.selectAffiliate(affiliate);
        // TODO: Ouvrir un dialog spécifique pour les commissions
        break;
      case 'referrals':
        controller.selectAffiliate(affiliate);
        // TODO: Ouvrir un dialog spécifique pour les filleuls
        break;
      case 'approve':
        controller.updateAffiliateStatus(
            affiliate.id, AffiliateStatus.ACTIVE, true);
        break;
      case 'suspend':
        controller.updateAffiliateStatus(
            affiliate.id, AffiliateStatus.SUSPENDED, false);
        break;
    }
  }
}
