import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class UsersFilterButton extends StatelessWidget {
  const UsersFilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() => PopupMenuButton<UserRole?>(
          icon: Icon(
            Icons.filter_list,
            color: controller.selectedRole.value != null
                ? AppColors.primary
                : null,
          ),
          onSelected: controller.filterByRole,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: null,
              child: Text('Tous les utilisateurs'),
            ),
            _buildMenuItem(
              value: UserRole.CLIENT,
              title: 'Clients',
              icon: Icons.people_outline,
              color: AppColors.primary,
              isSelected: controller.selectedRole.value == UserRole.CLIENT,
            ),
            _buildMenuItem(
              value: UserRole.AFFILIATE,
              title: 'Affiliés',
              icon: Icons.handshake_outlined,
              color: AppColors.accent,
              isSelected: controller.selectedRole.value == UserRole.AFFILIATE,
            ),
            _buildMenuItem(
              value: UserRole.ADMIN,
              title: 'Administrateurs',
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.error,
              isSelected: controller.selectedRole.value == UserRole.ADMIN,
            ),
          ],
        ));
  }

  PopupMenuItem<UserRole?> _buildMenuItem({
    required UserRole value,
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? color : null),
          const SizedBox(width: 8),
          Text(title),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check, color: color),
          ],
        ],
      ),
    );
  }
}
