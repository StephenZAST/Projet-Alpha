import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';

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
            _buildStatCard(
              title: 'Clients',
              count: controller.totalClientCount.value,
              currentCount: controller.selectedRole.value == UserRole.CLIENT
                  ? controller.users.length
                  : controller.clientCount.value,
              icon: Icons.people_outline,
              color: AppColors.primary,
              isSelected: controller.selectedRole.value == UserRole.CLIENT,
              onTap: () => controller.filterByRole(
                  controller.selectedRole.value == UserRole.CLIENT
                      ? null
                      : UserRole.CLIENT),
            ),
            _buildStatCard(
              title: 'Affiliés',
              count: controller.totalAffiliateCount.value,
              currentCount: controller.affiliateCount.value,
              icon: Icons.handshake_outlined,
              color: AppColors.accent,
              isSelected: controller.selectedRole.value == UserRole.AFFILIATE,
              onTap: () => controller.filterByRole(
                  controller.selectedRole.value == UserRole.AFFILIATE
                      ? null
                      : UserRole.AFFILIATE),
            ),
            _buildStatCard(
              title: 'Administrateurs',
              count: controller.totalAdminCount.value,
              currentCount: controller.adminCount.value,
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.error,
              isSelected: controller.selectedRole.value == UserRole.ADMIN,
              onTap: () => controller.filterByRole(
                  controller.selectedRole.value == UserRole.ADMIN
                      ? null
                      : UserRole.ADMIN),
            ),
            _buildStatCard(
              title: 'Total',
              count: controller.totalUsersCount.value,
              currentCount: controller.users.length,
              icon: Icons.groups_outlined,
              color: AppColors.success,
              isSelected: controller.selectedRole.value == null,
              onTap: () => controller.filterByRole(null),
            ),
          ],
        ));
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required int currentCount,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
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
                '$currentCount / $count',
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
