import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';
import '../../../widgets/pagination_controls.dart';

class UsersPagination extends StatelessWidget {
  const UsersPagination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Obx(() {
        // Sécurisation des valeurs pour éviter les ArgumentError
        final currentPage =
            controller.currentPage.value < 1 ? 1 : controller.currentPage.value;
        final totalPages =
            controller.totalPages.value < 1 ? 1 : controller.totalPages.value;
        final itemsPerPage = controller.itemsPerPage.value < 1
            ? 10
            : controller.itemsPerPage.value;
        final totalItems =
            controller.totalUsers.value < 0 ? 0 : controller.totalUsers.value;
        final itemCount =
            controller.users.length < 0 ? 0 : controller.users.length;

        return PaginationControls(
          currentPage: currentPage,
          totalPages: totalPages,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
          itemCount: itemCount,
          totalItems: totalItems,
          itemsPerPage: itemsPerPage,
          onItemsPerPageChanged: (value) {
            if (value != null) controller.setItemsPerPage(value);
          },
          onPageChanged: (page) {
            if (page != null && page != currentPage) {
              controller.goToPage(page);
            }
          },
        );
      }),
    );
  }
}
