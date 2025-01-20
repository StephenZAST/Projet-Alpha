import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Obx(() {
      final admin = controller.admin.value;
      if (admin == null) return SizedBox.shrink();

      return Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: admin.profilePicture != null
                ? NetworkImage(admin.profilePicture!)
                : AssetImage('assets/images/profile_pic.png') as ImageProvider,
          ),
          SizedBox(width: defaultPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(admin.name, style: Theme.of(context).textTheme.headline6),
              Text(admin.email, style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
        ],
      );
    });
  }
}
