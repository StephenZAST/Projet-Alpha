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

      // Afficher le message d'absence ET la pagination si besoin
      if (controller.users.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aucun utilisateur trouvé',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (controller.totalPages.value > 1)
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: PaginationControls(
                  currentPage: (controller.currentPage.value < 1)
                      ? 1
                      : controller.currentPage.value,
                  totalPages: (controller.totalPages.value < 1)
                      ? 1
                      : controller.totalPages.value,
                  itemsPerPage:
                      [10, 25, 50, 100].contains(controller.itemsPerPage.value)
                          ? controller.itemsPerPage.value
                          : 10,
                  totalItems: controller.totalUsers.value < 0
                      ? 0
                      : controller.totalUsers.value,
                  onNextPage: controller.nextPage,
                  onPreviousPage: controller.previousPage,
                  onItemsPerPageChanged: (value) =>
                      controller.setItemsPerPage(value),
                ),
              ),
          ],
        );
      }

      // Affiche la grille des utilisateurs reçus du backend, sans aucun filtrage local
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
          if (controller.totalPages.value > 1)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: PaginationControls(
                currentPage: (controller.currentPage.value < 1)
                    ? 1
                    : controller.currentPage.value,
                totalPages: (controller.totalPages.value < 1)
                    ? 1
                    : controller.totalPages.value,
                itemsPerPage:
                    [10, 25, 50, 100].contains(controller.itemsPerPage.value)
                        ? controller.itemsPerPage.value
                        : 10,
                totalItems: controller.totalUsers.value < 0
                    ? 0
                    : controller.totalUsers.value,
                onNextPage: controller.nextPage,
                onPreviousPage: controller.previousPage,
                onItemsPerPageChanged: (value) =>
                    controller.setItemsPerPage(value),
              ),
            ),
        ],
      );
    });
  }
}
