import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../models/delivery.dart';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../widgets/shared/glass_button.dart';

class DelivererDetailsDialog extends StatelessWidget {
  final DeliveryUser deliverer;

  const DelivererDetailsDialog({
    Key? key,
    required this.deliverer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<DeliveryController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray200.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDelivererInfoCard(context, isDark),
                          SizedBox(height: AppSpacing.lg),
                          _buildPerformanceCard(context, isDark, controller),
                          SizedBox(height: AppSpacing.lg),
                          _buildVehicleInfoCard(context, isDark),
                          SizedBox(height: AppSpacing.xl),
                          _buildActions(context, controller),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withOpacity(0.1),
            AppColors.teal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
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
              size: 40,
              color: AppColors.teal,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deliverer.fullName,
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildStatusBadge(deliverer.isActive),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.info,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '${deliverer.deliveriesToday ?? 0} livraisons aujourd\'hui',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelivererInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations personnelles',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoGrid(context, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, bool isDark) {
    final infoItems = [
      {'label': 'ID', 'value': deliverer.id, 'icon': Icons.fingerprint},
      {'label': 'Email', 'value': deliverer.email, 'icon': Icons.email_outlined},
      {'label': 'Téléphone', 'value': deliverer.phone ?? 'Non renseigné', 'icon': Icons.phone_outlined},
      {'label': 'Zone', 'value': deliverer.deliveryProfile?.zone ?? 'Non assignée', 'icon': Icons.location_on_outlined},
      {'label': 'Statut', 'value': deliverer.statusLabel, 'icon': Icons.info_outlined},
      {'label': 'Créé le', 'value': _formatDate(deliverer.createdAt), 'icon': Icons.calendar_today_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final item = infoItems[index];
        return _buildInfoItem(
          context,
          isDark,
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildInfoItem(BuildContext context, bool isDark, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
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
          Icon(
            icon,
            size: 16,
            color: AppColors.primary.withOpacity(0.7),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context, bool isDark, DeliveryController controller) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Performances',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() {
            final stats = controller.selectedDelivererStats.value;
            if (stats == null) {
              return Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.gray900.withOpacity(0.3)
                      : Colors.white.withOpacity(0.6),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Chargement des statistiques...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total livraisons',
                    '${stats.totalDeliveries}',
                    Icons.local_shipping_outlined,
                    AppColors.info,
                    isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatItem(
                    'Taux de réussite',
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.check_circle_outline,
                    AppColors.success,
                    isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatItem(
                    'Temps moyen',
                    stats.formattedAverageTime,
                    Icons.timer_outlined,
                    AppColors.warning,
                    isDark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations véhicule',
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
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
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Les informations détaillées du véhicule seront disponibles prochainement.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, DeliveryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Fermer',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SizedBox(width: AppSpacing.md),
        GlassButton(
          label: 'Voir Commandes',
          icon: Icons.local_shipping_outlined,
          variant: GlassButtonVariant.info,
          onPressed: () {
            controller.selectDeliverer(deliverer);
            Navigator.of(context).pop();
            // TODO: Ouvrir la vue des commandes du livreur
          },
        ),
        SizedBox(width: AppSpacing.md),
        GlassButton(
          label: deliverer.isActive ? 'Désactiver' : 'Activer',
          icon: deliverer.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
          variant: deliverer.isActive ? GlassButtonVariant.warning : GlassButtonVariant.success,
          onPressed: () {
            controller.toggleDelivererStatus(deliverer.id, !deliverer.isActive);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? AppColors.success : AppColors.warning;
    final text = isActive ? 'Actif' : 'Inactif';
    final icon = isActive ? Icons.check_circle : Icons.pause_circle;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}