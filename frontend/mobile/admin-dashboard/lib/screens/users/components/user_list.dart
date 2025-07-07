import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import 'user_list_item.dart';
import '../../../widgets/shared/pagination_controls.dart';

class UserList extends StatelessWidget {
  final controller = Get.find<UsersController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: TextStyle(color: AppColors.error),
          ),
        );
      }

      // Afficher le message d'absence ET la pagination si besoin
      if (controller.users.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aucun utilisateur trouvé'),
            if (controller.totalPages.value > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                  onPreviousPage: controller.previousPage,
                  onNextPage: controller.nextPage,
                  onItemsPerPageChanged: (value) =>
                      controller.setItemsPerPage(value),
                ),
              ),
          ],
        );
      }

      // Affiche la liste des utilisateurs reçus du backend, sans aucun filtrage local
      return ListView.builder(
        itemCount: controller.users.length +
            ((controller.totalPages.value > 1)
                ? 1
                : 0), // +1 pour la pagination si nécessaire
        itemBuilder: (context, index) {
          if (index < controller.users.length) {
            return UserListItem(user: controller.users[index]);
          } else {
            // Pagination intégrée directement ici
            final currentPage = (controller.currentPage.value < 1)
                ? 1
                : controller.currentPage.value;
            final totalPages = (controller.totalPages.value < 1)
                ? 1
                : controller.totalPages.value;
            final itemsPerPage =
                [10, 25, 50, 100].contains(controller.itemsPerPage.value)
                    ? controller.itemsPerPage.value
                    : 10;
            final totalUsers = controller.totalUsers.value < 0
                ? 0
                : controller.totalUsers.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: PaginationControls(
                currentPage: currentPage,
                totalPages: totalPages,
                itemsPerPage: itemsPerPage,
                totalItems: totalUsers,
                onPreviousPage: controller.previousPage,
                onNextPage: controller.nextPage,
                onItemsPerPageChanged: (value) =>
                    controller.setItemsPerPage(value),
              ),
            );
          }
        },
      );
    });
  }
}
