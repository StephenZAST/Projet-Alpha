import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../constants.dart';

class ActiveFilterIndicator extends StatelessWidget {
  const ActiveFilterIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      final role = controller.selectedRole.value;
      if (role == null) return const SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Chip(
          label: Text('Filtré: ${role.toString().split('.').last}'),
          onDeleted: () => controller.filterByRole(null),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIconColor: AppColors.primary,
        ),
      );
    });
  }
}
