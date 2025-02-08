import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';

class UserStats extends StatelessWidget {
  final controller = Get.find<UsersController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            context,
            "Clients",
            controller.clientCount.toString(),
            Icons.people_outline,
            AppColors.success,
          ),
          _buildStatCard(
            context,
            "Affiliés",
            controller.affiliateCount.toString(),
            Icons.person_add_outlined,
            AppColors.accent,
          ),
          _buildStatCard(
            context,
            "Admins",
            controller.adminCount.toString(),
            Icons.admin_panel_settings_outlined,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count,
      IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: AppSpacing.sm),
        Text(
          count,
          style: AppTextStyles.h2.copyWith(color: color),
        ),
        Text(
          title,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
