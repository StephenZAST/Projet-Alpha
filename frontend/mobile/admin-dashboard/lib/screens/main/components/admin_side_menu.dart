import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../routes/admin_routes.dart';

class AdminSideMenu extends StatelessWidget {
  const AdminSideMenu({Key? key}) : super(key: key);

  void _handleNavigation(String route, int index) {
    final controller = Get.find<MenuAppController>();
    Get.offAllNamed(route);
    controller.updateSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Drawer(
        backgroundColor: AppColors.secondaryBg,
        child: ListView(
          children: [
            DrawerHeader(
              child: Image.asset("assets/images/logo.png"),
            ),
            DrawerListTile(
              title: "Dashboard",
              icon: Icons.dashboard_outlined,
              onPress: () => _handleNavigation(AdminRoutes.dashboard, 0),
            ),
            DrawerListTile(
              title: "Commandes",
              icon: Icons.shopping_cart_outlined,
              onPress: () => _handleNavigation(AdminRoutes.orders, 1),
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
              onPress: () => _handleNavigation(AdminRoutes.services, 2),
            ),
            DrawerListTile(
              title: "Catégories",
              icon: Icons.category_outlined,
              onPress: () => _handleNavigation(AdminRoutes.categories, 3),
            ),
            const Divider(color: AppColors.borderLight),
            DrawerListTile(
              title: "Utilisateurs",
              icon: Icons.people_outline,
              onPress: () => _handleNavigation(AdminRoutes.users, 4),
            ),
            DrawerListTile(
              title: "Mon Profil",
              icon: Icons.person_outline,
              onPress: () => _handleNavigation(AdminRoutes.profile, 5),
            ),
          ],
        ),
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
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
      ),
    );
  }
}
