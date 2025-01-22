import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../routes/admin_routes.dart';

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
            icon: Icons.dashboard_outlined,
            onPress: () {
              Get.toNamed(AdminRoutes.dashboard);
              context.read<MenuAppController>().updateSelectedIndex(0);
            },
          ),
          DrawerListTile(
            title: "Commandes",
            icon: Icons.shopping_cart_outlined,
            onPress: () {
              Get.toNamed(AdminRoutes.orders);
              context.read<MenuAppController>().updateSelectedIndex(1);
            },
          ),
          const Divider(color: AppColors.borderLight),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "GESTION DES SERVICES",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DrawerListTile(
            title: "Services",
            icon: Icons.cleaning_services_outlined,
            onPress: () {
              Get.toNamed(AdminRoutes.services);
              context.read<MenuAppController>().updateSelectedIndex(2);
            },
          ),
          DrawerListTile(
            title: "Catégories",
            icon: Icons.category_outlined,
            onPress: () {
              Get.toNamed(AdminRoutes.categories);
              context.read<MenuAppController>().updateSelectedIndex(3);
            },
          ),
          const Divider(color: AppColors.borderLight),
          DrawerListTile(
            title: "Utilisateurs",
            icon: Icons.people_outline,
            onPress: () {
              Get.toNamed(AdminRoutes.users);
              context.read<MenuAppController>().updateSelectedIndex(4);
            },
          ),
          DrawerListTile(
            title: "Mon Profil",
            icon: Icons.person_outline,
            onPress: () {
              Get.toNamed(AdminRoutes.profile);
              context.read<MenuAppController>().updateSelectedIndex(5);
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
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
