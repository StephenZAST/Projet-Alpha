import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../types/user_search_filter.dart';

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
              count: controller.selectedRoleString.value == 'CLIENT'
                  ? controller.totalUsers.value // total filtré (toutes pages)
                  : controller.totalClientCount.value, // total global
              currentCount: controller.selectedRoleString.value == 'CLIENT'
                  ? controller.users.length // affichés sur la page courante
                  : controller.clientCount.value, // total global
              icon: Icons.people_outline,
              color: AppColors.primary,
              isSelected: controller.selectedRoleString.value == 'CLIENT',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'CLIENT';
                controller.filterByRole(isSelected ? null : UserRole.CLIENT);
              },
            ),
            _buildStatCard(
              title: 'Affiliés',
              count: controller.selectedRoleString.value == 'AFFILIATE'
                  ? controller.totalUsers.value
                  : controller.totalAffiliateCount.value,
              currentCount: controller.selectedRoleString.value == 'AFFILIATE'
                  ? controller.users.length
                  : controller.affiliateCount.value,
              icon: Icons.handshake_outlined,
              color: AppColors.accent,
              isSelected: controller.selectedRoleString.value == 'AFFILIATE',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'AFFILIATE';
                controller.filterByRole(isSelected ? null : UserRole.AFFILIATE);
              },
            ),
            _buildStatCard(
              title: 'Administrateurs',
              count: controller.selectedRoleString.value == 'ADMIN'
                  ? controller.totalUsers.value
                  : controller.totalAdminCount.value,
              currentCount: controller.selectedRoleString.value == 'ADMIN'
                  ? controller.users.length
                  : controller.adminCount.value,
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.error,
              isSelected: controller.selectedRoleString.value == 'ADMIN',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'ADMIN';
                controller.filterByRole(isSelected ? null : UserRole.ADMIN);
              },
            ),
            _buildStatCard(
              title: 'Total',
              count: controller.selectedRoleString.value == 'all'
                  ? controller.totalUsers.value
                  : controller.totalUsersCount.value,
              currentCount: controller.users.length,
              icon: Icons.groups_outlined,
              color: AppColors.success,
              isSelected: controller.selectedRoleString.value == 'all',
              onTap: () {
                controller.filterByRole(null);
              },
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
