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
      child: Obx(() {
        final currentIndex = menuController.selectedIndex.value;
        print('[AdminSideMenu] Current selected index: $currentIndex');

        return ListView(
          children: [
            DrawerHeader(
              child: Image.asset("assets/images/logo.png"),
            ),
            // DASHBOARD
            DrawerListTile(
              title: "Tableau de bord",
              icon: Icons.dashboard_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.dashboard, // 0
              onPress: () => menuController.updateIndex(MenuIndices.dashboard),
            ),
            // COMMANDES
            DrawerListTile(
              title: "Commandes",
              icon: Icons.shopping_cart_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.orders, // 1
              onPress: () => menuController.updateIndex(MenuIndices.orders),
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
              isSelected:
                  menuController.selectedIndex == MenuIndices.services, // 2
              onPress: () {
                print(
                    '[AdminSideMenu] Pressing Services button (index ${MenuIndices.services})');
                menuController.updateIndex(MenuIndices.services);
              },
            ),
            DrawerListTile(
              title: "Catégories",
              icon: Icons.category_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.categories, // 3
              onPress: () => menuController.updateIndex(MenuIndices.categories),
            ),
            DrawerListTile(
              title: "Articles",
              icon: Icons.inventory_2_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.articles, // 4
              onPress: () => menuController.updateIndex(MenuIndices.articles),
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
              isSelected:
                  menuController.selectedIndex == MenuIndices.users, // 6
              onPress: () => menuController.updateIndex(MenuIndices.users),
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
              isSelected: menuController.selectedIndex ==
                  MenuIndices.notifications, // 8
              onPress: () =>
                  menuController.updateIndex(MenuIndices.notifications),
            ),
            DrawerListTile(
              title: "Mon Profil",
              icon: Icons.person_outline,
              isSelected:
                  menuController.selectedIndex == MenuIndices.profile, // 7
              onPress: () => menuController.updateIndex(MenuIndices.profile),
            ),
          ],
        );
      }),
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
