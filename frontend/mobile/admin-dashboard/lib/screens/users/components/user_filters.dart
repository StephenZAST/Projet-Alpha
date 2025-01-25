import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';

class UserFilters extends StatelessWidget {
  const UserFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.searchUsers,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                    fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray800 : AppColors.gray100,
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Obx(() => DropdownButton<UserRole?>(
                      value: controller.selectedRole.value,
                      items: [
                        DropdownMenuItem<UserRole?>(
                          value: null,
                          child: Text(
                            'Tous les rôles',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ...UserRole.values.map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.label,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                            )),
                      ],
                      onChanged: controller.filterByRole,
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.filter_list,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    )),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildStatCard(
                      'Administrateurs',
                      controller.adminCount.toString(),
                      AppColors.violet,
                      Icons.admin_panel_settings,
                      isDark,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildStatCard(
                      'Affiliés',
                      controller.affiliateCount.toString(),
                      AppColors.teal,
                      Icons.handshake,
                      isDark,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildStatCard(
                      'Clients',
                      controller.clientCount.toString(),
                      AppColors.pink,
                      Icons.people,
                      isDark,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildStatCard(
                      'Total',
                      controller.totalUsers.toString(),
                      AppColors.primary,
                      Icons.groups,
                      isDark,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              icon,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
