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
          key: ValueKey('menu_list_${key.toString()}'),
          children: [
            DrawerHeader(
              key: ValueKey('drawer_header_${key.toString()}'),
              child: Image.asset("assets/images/alphalogo.png"),
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
            DrawerListTile(
              title: "Types de service",
              icon: Icons.category,
              isSelected:
                  menuController.selectedIndex == MenuIndices.serviceTypes, // 5
              onPress: () =>
                  menuController.updateIndex(MenuIndices.serviceTypes),
            ),
            DrawerListTile(
              title: "Couples Service/Article",
              icon: Icons.link,
              isSelected: menuController.selectedIndex ==
                  MenuIndices.serviceArticleCouples,
              onPress: () =>
                  menuController.updateIndex(MenuIndices.serviceArticleCouples),
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
              title: "Abonnements",
              icon: Icons.subscriptions_outlined,
              isSelected: menuController.selectedIndex ==
                  MenuIndices.subscriptions, // 10
              onPress: () =>
                  menuController.updateIndex(MenuIndices.subscriptions),
            ),
            DrawerListTile(
              title: "Offres",
              icon: Icons.local_offer_outlined,
              isSelected: menuController.selectedIndex == MenuIndices.offers,
              onPress: () => menuController.updateIndex(MenuIndices.offers),
            ),
            DrawerListTile(
              title: "Utilisateurs",
              icon: Icons.people_outline,
              isSelected:
                  menuController.selectedIndex == MenuIndices.users, // 6
              onPress: () => menuController.updateIndex(MenuIndices.users),
            ),
            DrawerListTile(
              title: "Affiliés",
              icon: Icons.handshake_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.affiliates, // 7
              onPress: () => menuController.updateIndex(MenuIndices.affiliates),
            ),
            DrawerListTile(
              title: "Système de Fidélité",
              icon: Icons.stars_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.loyalty, // 8
              onPress: () => menuController.updateIndex(MenuIndices.loyalty),
            ),
            DrawerListTile(
              title: "Gestion Livreurs",
              icon: Icons.local_shipping_outlined,
              isSelected:
                  menuController.selectedIndex == MenuIndices.delivery, // 9
              onPress: () => menuController.updateIndex(MenuIndices.delivery),
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
            // Onglet "Abonnements" retiré ici pour éviter le doublon
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
