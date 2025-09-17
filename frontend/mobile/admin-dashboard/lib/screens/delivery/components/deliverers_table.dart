import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/delivery.dart';
import '../../../widgets/shared/glass_button.dart';
import 'deliverer_details_dialog.dart';

class DeliverersTable extends StatelessWidget {
  const DeliverersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
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
                        itemCount: controller.filteredDeliverers.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.gray700.withOpacity(0.3)
                              : AppColors.gray200.withOpacity(0.5),
                        ),
                        itemBuilder: (context, index) {
                          final deliverer =
                              controller.filteredDeliverers[index];
                          return _buildTableRow(
                              context, isDark, deliverer, controller, index);
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
      BuildContext context, bool isDark, DeliveryController controller) {
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
          _buildHeaderCell('Livreur', flex: 3, isDark: isDark),
          _buildHeaderCell('Contact', flex: 2, isDark: isDark),
          _buildHeaderCell('Statut', flex: 2, isDark: isDark),
          _buildHeaderCell('Performances', flex: 2, isDark: isDark),
          _buildHeaderCell('Zone', flex: 2, isDark: isDark),
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
    DeliveryUser deliverer,
    DeliveryController controller,
    int index,
  ) {
    return InkWell(
      onTap: () => _showDelivererDetails(context, deliverer),
      child: Container(
        // Effet de zébrage
        color: index % 2 == 0
            ? (isDark ? AppColors.gray900 : AppColors.gray50)
            : Colors.transparent,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Livreur (avatar, nom)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal.withOpacity(0.2),
                          AppColors.teal.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.teal.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.delivery_dining_outlined,
                      size: 20,
                      color: AppColors.teal,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deliverer.fullName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'ID: ${deliverer.id.substring(0, 8)}...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contact
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliverer.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    deliverer.phone ?? 'Non renseigné',
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Statut
            Expanded(
              flex: 2,
              child: _buildStatusBadge(deliverer.isActive, isDark),
            ),

            // Performances
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${deliverer.deliveriesToday ?? 0} livraisons',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Aujourd\'hui',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Zone
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: AppRadius.radiusXS,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  deliverer.deliveryProfile?.zone ?? 'Non assignée',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent,
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
                    onPressed: () => _showDelivererDetails(context, deliverer),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  GlassButton(
                    label: '',
                    icon: deliverer.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    variant: deliverer.isActive
                        ? GlassButtonVariant.warning
                        : GlassButtonVariant.success,
                    size: GlassButtonSize.small,
                    onPressed: () => _toggleDelivererStatus(deliverer, controller),
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
                        _handleMenuAction(value, deliverer, controller),
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
                        value: 'orders',
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 16),
                            SizedBox(width: AppSpacing.sm),
                            Text('Commandes'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: AppSpacing.sm),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reset_password',
                        child: Row(
                          children: [
                            Icon(Icons.lock_reset, size: 16, color: AppColors.warning),
                            SizedBox(width: AppSpacing.sm),
                            Text('Réinitialiser mot de passe',
                                style: TextStyle(color: AppColors.warning)),
                          ],
                        ),
                      ),
                      if (!deliverer.isActive)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              SizedBox(width: AppSpacing.sm),
                              Text('Supprimer',
                                  style: TextStyle(color: AppColors.error)),
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

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    final color = isActive ? AppColors.success : AppColors.warning;
    final text = isActive ? 'Actif' : 'Inactif';
    final icon = isActive ? Icons.check_circle : Icons.pause_circle;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusXS,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDelivererDetails(BuildContext context, DeliveryUser deliverer) {
    Get.dialog(
      DelivererDetailsDialog(deliverer: deliverer),
      barrierDismissible: true,
    );
  }

  void _toggleDelivererStatus(
      DeliveryUser deliverer, DeliveryController controller) {
    controller.toggleDelivererStatus(deliverer.id, !deliverer.isActive);
  }

  void _handleMenuAction(String action, DeliveryUser deliverer,
      DeliveryController controller) {
    switch (action) {
      case 'details':
        _showDelivererDetails(Get.context!, deliverer);
        break;
      case 'orders':
        controller.selectDeliverer(deliverer);
        // TODO: Ouvrir un dialog spécifique pour les commandes
        break;
      case 'edit':
        // TODO: Ouvrir le dialog d'édition
        break;
      case 'reset_password':
        _showResetPasswordDialog(deliverer, controller);
        break;
      case 'delete':
        _showDeleteConfirmation(deliverer, controller);
        break;
    }
  }

  void _showResetPasswordDialog(
      DeliveryUser deliverer, DeliveryController controller) {
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Réinitialiser le mot de passe',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  hintText: 'Entrez le nouveau mot de passe...',
                ),
                obscureText: true,
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
                      label: 'Réinitialiser',
                      variant: GlassButtonVariant.warning,
                      onPressed: () {
                        if (passwordController.text.isNotEmpty) {
                          controller.resetDelivererPassword(
                              deliverer.id, passwordController.text);
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
    );
  }

  void _showDeleteConfirmation(
      DeliveryUser deliverer, DeliveryController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_outlined,
                color: AppColors.error,
                size: 48,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Supprimer le livreur',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Êtes-vous sûr de vouloir supprimer ${deliverer.fullName} ? Cette action est irréversible.',
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
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        controller.deleteDeliverer(deliverer.id);
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
    );
  }
}
