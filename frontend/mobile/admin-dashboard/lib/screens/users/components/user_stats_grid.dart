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
            _buildStatsCard(
              title: 'Clients',
              count: controller.totalClientCount.value,
              icon: Icons.people_outline,
              color: AppColors.primary,
              onTap: () => controller.filterByRole(UserRole.CLIENT),
              isSelected: controller.selectedRole.value == UserRole.CLIENT,
            ),
            _buildStatsCard(
              title: 'Affiliés',
              count: controller.totalAffiliateCount.value,
              icon: Icons.handshake_outlined,
              color: AppColors.accent,
              onTap: () => controller.filterByRole(UserRole.AFFILIATE),
              isSelected: controller.selectedRole.value == UserRole.AFFILIATE,
            ),
            _buildStatsCard(
              title: 'Administrateurs',
              count: controller.totalAdminCount.value,
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.error,
              onTap: () => controller.filterByRole(UserRole.ADMIN),
              isSelected: controller.selectedRole.value == UserRole.ADMIN,
            ),
            _buildStatsCard(
              title: 'Total',
              count: controller.totalUserCount.value,
              icon: Icons.groups_outlined,
              color: AppColors.success,
              onTap: () => controller.filterByRole(null),
              isSelected: controller.selectedRole.value == null,
            ),
          ],
        ));
  }

  Widget _buildStatsCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 16),
                ],
              ),
              Spacer(),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
