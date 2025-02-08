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
      child: Obx(() => PaginationControls(
            currentPage: controller.currentPage.value,
            totalPages: controller.totalPages.value,
            onPrevious: controller.previousPage,
            onNext: controller.nextPage,
            itemCount: controller.users.length,
            totalItems: controller.totalUsers.value,
            itemsPerPage: controller.itemsPerPage.value,
            onItemsPerPageChanged: (value) {
              if (value != null) controller.setItemsPerPage(value);
            },
          )),
    );
  }
}
