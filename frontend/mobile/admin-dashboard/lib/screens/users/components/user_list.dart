import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import 'user_list_item.dart';

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

      if (controller.users.isEmpty) {
        return Center(
          child: Text('Aucun utilisateur trouvé'),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: controller.users.length,
              itemBuilder: (context, index) {
                return UserListItem(user: controller.users[index]);
              },
            ),
          ),
          _buildPagination(),
        ],
      );
    });
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: controller.currentPage.value > 1
              ? () => controller.previousPage()
              : null,
        ),
        Text(
          'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
          style: AppTextStyles.bodyMedium,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: controller.currentPage.value < controller.totalPages.value
              ? () => controller.nextPage()
              : null,
        ),
      ],
    );
  }
}
