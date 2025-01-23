import 'package:flutter/material.dart';
import '../../../constants.dart';

class AdminSideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

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
            isSelected: selectedIndex == 0,
            onPress: () => onItemSelected(0),
          ),
          DrawerListTile(
            title: "Commandes",
            icon: Icons.shopping_cart_outlined,
            isSelected: selectedIndex == 1,
            onPress: () => onItemSelected(1),
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
            isSelected: selectedIndex == 2,
            onPress: () => onItemSelected(2),
          ),
          DrawerListTile(
            title: "Catégories",
            icon: Icons.category_outlined,
            isSelected: selectedIndex == 3,
            onPress: () => onItemSelected(3),
          ),
          const Divider(color: AppColors.borderLight),
          DrawerListTile(
            title: "Utilisateurs",
            icon: Icons.people_outline,
            isSelected: selectedIndex == 4,
            onPress: () => onItemSelected(4),
          ),
          DrawerListTile(
            title: "Mon Profil",
            icon: Icons.person_outline,
            isSelected: selectedIndex == 5,
            onPress: () => onItemSelected(5),
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
    return Material(
      color:
          isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        onTap: onPress,
        horizontalTitleGap: 0.0,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
