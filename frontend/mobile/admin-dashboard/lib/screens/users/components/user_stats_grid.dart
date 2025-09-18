import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../widgets/shared/glass_container.dart';

class UserStatsGrid extends StatelessWidget {
  const UserStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context,
              isDark,
              title: 'Clients',
              count: controller.selectedRoleString.value == 'CLIENT'
                  ? controller.totalUsers.value
                  : controller.totalClientCount.value,
              currentCount: controller.selectedRoleString.value == 'CLIENT'
                  ? controller.users.length
                  : controller.clientCount.value,
              icon: Icons.people_outline,
              color: AppColors.primary,
              lightColor: AppColors.primaryLight,
              isSelected: controller.selectedRoleString.value == 'CLIENT',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'CLIENT';
                controller.filterByRole(isSelected ? null : UserRole.CLIENT);
              },
            ),
            _buildStatCard(
              context,
              isDark,
              title: 'Affiliés',
              count: controller.selectedRoleString.value == 'AFFILIATE'
                  ? controller.totalUsers.value
                  : controller.totalAffiliateCount.value,
              currentCount: controller.selectedRoleString.value == 'AFFILIATE'
                  ? controller.users.length
                  : controller.affiliateCount.value,
              icon: Icons.handshake_outlined,
              color: AppColors.orange,
              lightColor: AppColors.orangeLight,
              isSelected: controller.selectedRoleString.value == 'AFFILIATE',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'AFFILIATE';
                controller.filterByRole(isSelected ? null : UserRole.AFFILIATE);
              },
            ),
            _buildStatCard(
              context,
              isDark,
              title: 'Administrateurs',
              count: controller.selectedRoleString.value == 'ADMIN'
                  ? controller.totalUsers.value
                  : controller.totalAdminCount.value,
              currentCount: controller.selectedRoleString.value == 'ADMIN'
                  ? controller.users.length
                  : controller.adminCount.value,
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.violet,
              lightColor: AppColors.violetLight,
              isSelected: controller.selectedRoleString.value == 'ADMIN',
              onTap: () {
                final isSelected =
                    controller.selectedRoleString.value == 'ADMIN';
                controller.filterByRole(isSelected ? null : UserRole.ADMIN);
              },
            ),
            _buildStatCard(context, isDark,
                title: 'Total',
                count: controller.selectedRoleString.value == 'ALL'
                    ? controller.totalUsers.value
                    : controller.totalUsersCount.value,
                currentCount: controller.users.length,
                icon: Icons.groups_outlined,
                color: AppColors.success,
                lightColor: AppColors.successLight,
                isSelected: controller.selectedRoleString.value == 'ALL',
                onTap: () {
              controller.filterByRole(null);
            }),
          ],
        ));
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required int count,
    required int currentCount,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusMD,
          child: Stack(
            children: [
              // Gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(isSelected ? 0.15 : 0.1),
                        lightColor.withOpacity(isSelected ? 0.1 : 0.05),
                      ],
                    ),
                    borderRadius: AppRadius.radiusMD,
                    border: isSelected
                        ? Border.all(color: color.withOpacity(0.3), width: 2)
                        : null,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 24,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              currentCount.toString(),
                              style: AppTextStyles.h2.copyWith(
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            if (count != currentCount) ...[
                              Text(
                                ' / $count',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Hover effect
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: AppRadius.radiusMD,
                    hoverColor: color.withOpacity(0.05),
                    splashColor: color.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
