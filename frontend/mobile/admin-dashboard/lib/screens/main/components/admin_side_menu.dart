import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';

class AdminSideMenu extends StatelessWidget {
  const AdminSideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.secondaryBg,
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard,
            onPress: () {
              Get.toNamed(AdminRoutes.dashboard);
              context.read<MenuAppController>().updateSelectedIndex(0);
            },
          ),
          DrawerListTile(
            title: "Orders",
            icon: Icons.shopping_cart,
            onPress: () {
              Get.toNamed(AdminRoutes.orders);
              context.read<MenuAppController>().updateSelectedIndex(1);
            },
          ),
          DrawerListTile(
            title: "Products",
            icon: Icons.inventory,
            onPress: () {
              Get.toNamed(AdminRoutes.products);
              context.read<MenuAppController>().updateSelectedIndex(2);
            },
          ),
          DrawerListTile(
            title: "Users",
            icon: Icons.people,
            onPress: () {
              Get.toNamed(AdminRoutes.users);
              context.read<MenuAppController>().updateSelectedIndex(3);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;

  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      horizontalTitleGap: 0.0,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
