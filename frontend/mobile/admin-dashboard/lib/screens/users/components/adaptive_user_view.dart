import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import 'user_list.dart';
import 'user_grid.dart';

class AdaptiveUserView extends StatelessWidget {
  const AdaptiveUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: controller.viewMode.value == ViewMode.list
            ? UserList()
            : UserGrid(),
      );
    });
  }
}
