import 'package:admin/controllers/menu_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';

class AdminSideMenu extends StatelessWidget {
  const AdminSideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MenuAppController menuController = Get.find<MenuAppController>();
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.drawerTheme.backgroundColor,
      child: Obx(() => ListView(
            children: [
              DrawerHeader(
                child: Image.asset("assets/images/logo.png"),
              ),
              // DASHBOARD
              DrawerListTile(
                title: "Tableau de bord",
                icon: Icons.dashboard_outlined,
                isSelected: menuController.selectedIndex == 0,
                onPress: () => menuController.updateIndex(0),
              ),
              // COMMANDES
              DrawerListTile(
                title: "Commandes",
                icon: Icons.shopping_cart_outlined,
                isSelected: menuController.selectedIndex == 1,
                onPress: () => menuController.updateIndex(1),
              ),
              Divider(color: theme.dividerColor),
              // GESTION DES SERVICES
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "GESTION DES SERVICES",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DrawerListTile(
                title: "Services",
                icon: Icons.cleaning_services_outlined,
                isSelected: menuController.selectedIndex == 2,
                onPress: () => menuController.updateIndex(2),
              ),
              DrawerListTile(
                title: "Catégories",
                icon: Icons.category_outlined,
                isSelected: menuController.selectedIndex == 3,
                onPress: () => menuController.updateIndex(3),
              ),
              DrawerListTile(
                title: "Articles",
                icon: Icons.inventory,
                onPress: () => Get.toNamed('/articles'),
              ),
              DrawerListTile(
                title: "Types de Services",
                icon: Icons.category_outlined,
                onPress: () => Get.toNamed('/service-types'),
              ),
              Divider(color: theme.dividerColor),
              // GESTION DES UTILISATEURS
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "GESTION DES UTILISATEURS",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DrawerListTile(
                title: "Utilisateurs",
                icon: Icons.people_outline,
                isSelected: menuController.selectedIndex == 4,
                onPress: () => menuController.updateIndex(4),
              ),
              Divider(color: theme.dividerColor),
              // NOTIFICATIONS ET PROFIL
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "NOTIFICATIONS & PROFIL",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DrawerListTile(
                title: "Notifications",
                icon: Icons.notifications_outlined,
                isSelected: menuController.selectedIndex == 6,
                onPress: () => menuController.updateIndex(6),
              ),
              DrawerListTile(
                title: "Mon Profil",
                icon: Icons.person_outline,
                isSelected: menuController.selectedIndex == 5,
                onPress: () => menuController.updateIndex(5),
              ),
            ],
          )),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool isSelected;

  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Material(
      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        onTap: onPress,
        horizontalTitleGap: 0.0,
        leading: Icon(
          icon,
          color: isSelected ? primaryColor : textColor,
          size: 22,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? primaryColor : textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
