import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../widgets/stat_card.dart';

class UserStatsGrid extends StatelessWidget {
  const UserStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() => GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: 'Clients',
              value: controller.clientCount.toString(),
              icon: Icons.people_outline,
              color: AppColors.primary,
              subtitle: 'Total des clients',
              onTap: () => controller.filterByRole(UserRole.CLIENT),
            ),
            StatCard(
              title: 'Affiliés',
              value: controller.affiliateCount.toString(),
              icon: Icons.handshake_outlined,
              color: AppColors.accent,
              subtitle: 'Programme d\'affiliation',
              onTap: () => controller.filterByRole(UserRole.AFFILIATE),
            ),
            StatCard(
              title: 'Administrateurs',
              value: controller.adminCount.toString(),
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.error,
              subtitle: 'Équipe de gestion',
              onTap: () => controller.filterByRole(UserRole.ADMIN),
            ),
            StatCard(
              title: 'Total',
              value: controller.totalUsers.toString(),
              icon: Icons.groups_outlined,
              color: AppColors.success,
              subtitle: 'Tous les utilisateurs',
              onTap: () => controller.filterByRole(null),
            ),
          ],
        ));
  }
}
