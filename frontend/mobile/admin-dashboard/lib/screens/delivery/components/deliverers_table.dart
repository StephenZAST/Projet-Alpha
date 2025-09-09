import 'package:admin/screens/delivery/components/glass_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../models/delivery.dart';
import '../../../widgets/shared/glass_container.dart';

class DeliverersTable extends StatelessWidget {
  const DeliverersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeliveryController controller = Get.find<DeliveryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return GlassContainer(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final List<DeliveryUser> list = controller.filteredDeliverers;

      if (list.isEmpty) {
        return GlassContainer(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 48, color: AppColors.gray400),
              SizedBox(height: AppSpacing.md),
              Text('Aucun livreur trouvé', style: AppTextStyles.bodyLarge),
              SizedBox(height: AppSpacing.lg),
              GlassContainer(
                onTap: () => controller.loadDeliverers(),
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh,
                        color: isDark ? AppColors.gray200 : AppColors.gray700),
                    SizedBox(width: AppSpacing.sm),
                    Text('Rafraîchir', style: AppTextStyles.bodyLarge),
                  ],
                ),
              )
            ],
          ),
        );
      }

      return GlassContainer(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildHeader(context, isDark),
            SizedBox(height: AppSpacing.sm),
            ...list.map((deliverer) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildDelivererRow(context, deliverer, isDark),
                )),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return GlassListItem(
      isHeader: true,
      leading: SizedBox(width: 40), // Placeholder for avatar
      title: Text('Livreur'),
      trailingWidgets: [
        Expanded(flex: 2, child: Center(child: Text('Statut'))),
        Expanded(flex: 2, child: Center(child: Text('Courses (Jour)'))),
        Expanded(flex: 1, child: Center(child: Text('Actions'))),
      ],
    );
  }

  Widget _buildDelivererRow(
      BuildContext context, DeliveryUser deliverer, bool isDark) {
    return GlassListItem(
      onTap: () {
        // TODO: Show deliverer details dialog
      },
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: Text(
          deliverer.fullName.substring(0, 1).toUpperCase(),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(deliverer.fullName, style: AppTextStyles.bodyLarge),
      subtitle: Text(deliverer.email, style: AppTextStyles.bodySmallSecondary),
      trailingWidgets: [
        Expanded(
            flex: 2,
            child:
                Center(child: _buildStatusBadge(deliverer.isActive, isDark))),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              '${deliverer.deliveriesToday ?? 0}',
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                // TODO: Handle actions
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'view',
                  child: Text('Voir les détails'),
                ),
                PopupMenuItem<String>(
                  value: 'toggle_status',
                  child: Text(deliverer.isActive ? 'Désactiver' : 'Activer'),
                ),
              ],
              icon: Icon(Icons.more_vert,
                  color: isDark ? AppColors.gray300 : AppColors.gray600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    final color = isActive ? AppColors.success : AppColors.warning;
    final text = isActive ? 'Actif' : 'Inactif';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
