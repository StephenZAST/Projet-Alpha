import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../widgets/shared/glass_button.dart';

class PendingWithdrawalsCard extends StatelessWidget {
  const PendingWithdrawalsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.pendingWithdrawals.isEmpty) {
        return SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusMD,
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withOpacity(0.1),
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
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark, controller),
                    SizedBox(height: AppSpacing.md),
                    _buildWithdrawalsList(context, isDark, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, bool isDark, AffiliatesController controller) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: AppRadius.radiusSM,
          ),
          child: Icon(
            Icons.pending_actions,
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
                'Demandes de Retrait en Attente',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${controller.pendingWithdrawals.length} demande${controller.pendingWithdrawals.length > 1 ? 's' : ''} à traiter',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GlassButton(
          label: 'Voir tout',
          icon: Icons.arrow_forward,
          variant: GlassButtonVariant.warning,
          size: GlassButtonSize.small,
          onPressed: () => _showAllWithdrawals(context),
        ),
      ],
    );
  }

  Widget _buildWithdrawalsList(BuildContext context, bool isDark, AffiliatesController controller) {
    // Afficher seulement les 3 premières demandes
    final displayedWithdrawals = controller.pendingWithdrawals.take(3).toList();

    return Column(
      children: displayedWithdrawals.map((withdrawal) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.gray900.withOpacity(0.3)
                : Colors.white.withOpacity(0.6),
            borderRadius: AppRadius.radiusSM,
            border: Border.all(
              color: isDark 
                  ? AppColors.gray600.withOpacity(0.2)
                  : AppColors.gray300.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Avatar de l'affilié
              Container(
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
              SizedBox(width: AppSpacing.md),
              
              // Informations de la demande
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal.affiliate?.fullName ?? 'Affilié inconnu',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          withdrawal.formattedAmount,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          '•',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.gray400 : AppColors.textMuted,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatDate(withdrawal.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.gray400 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions rapides
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassButton(
                    label: '',
                    icon: Icons.check,
                    variant: GlassButtonVariant.success,
                    size: GlassButtonSize.small,
                    onPressed: () => _approveWithdrawal(withdrawal.id, controller),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  GlassButton(
                    label: '',
                    icon: Icons.close,
                    variant: GlassButtonVariant.error,
                    size: GlassButtonSize.small,
                    onPressed: () => _showRejectDialog(withdrawal.id, controller),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _approveWithdrawal(String withdrawalId, AffiliatesController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Get.theme.brightness == Brightness.dark
                ? AppColors.gray900.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 48,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Approuver la demande',
                      style: AppTextStyles.h4,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Êtes-vous sûr de vouloir approuver cette demande de retrait ?',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
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
                            label: 'Approuver',
                            variant: GlassButtonVariant.success,
                            onPressed: () {
                              controller.approveWithdrawal(withdrawalId);
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(String withdrawalId, AffiliatesController controller) {
    final reasonController = TextEditingController();
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: Get.theme.brightness == Brightness.dark
                ? AppColors.gray900.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                      size: 48,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Rejeter la demande',
                      style: AppTextStyles.h4,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.brightness == Brightness.dark
                            ? AppColors.gray800.withOpacity(0.5)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: AppRadius.radiusSM,
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Raison du rejet',
                          hintText: 'Expliquez pourquoi cette demande est rejetée...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
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
                                controller.rejectWithdrawal(withdrawalId, reasonController.text);
                                Get.back();
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
          ),
        ),
      ),
    );
  }

  void _showAllWithdrawals(BuildContext context) {
    // TODO: Implémenter une page ou dialog complet pour tous les retraits
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Get.theme.brightness == Brightness.dark
                ? AppColors.gray900.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.radiusLG,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toutes les Demandes de Retrait',
                          style: AppTextStyles.h3,
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: Text('Interface complète des retraits à implémenter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}