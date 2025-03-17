import 'package:admin/screens/users/components/user_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';
import '../../../widgets/shared/pagination_controls.dart';
import 'user_grid_item.dart';

class UserGrid extends StatelessWidget {
  const UserGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor().clamp(2, 4);

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.users.isEmpty) {
        return Center(
          child: Text(
            'Aucun utilisateur trouvé',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: controller.users.length,
              itemBuilder: (context, index) {
                final user = controller.users[index];
                return UserGridItem(
                  user: user,
                  onEdit: (user) => Get.dialog(
                    UserEditDialog(user: user),
                    barrierDismissible: false,
                  ),
                  onDelete: (user) => controller.deleteUser(
                    user.id,
                    user.fullName,
                  ),
                );
              },
            ),
          ),
          _buildPagination(context),
        ],
      );
    });
  }

  Widget _buildPagination(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: PaginationControls(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        itemsPerPage: controller.itemsPerPage.value,
        totalItems: controller.totalUsers.value,
        onNextPage: controller.nextPage,
        onPreviousPage: controller.previousPage,
        onItemsPerPageChanged: (value) => controller.setItemsPerPage(value),
      ),
    );
  }
}
