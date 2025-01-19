import 'package:flutter/material.dart';
import '../../../constants.dart';

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
            onPress: () {},
          ),
          DrawerListTile(
            title: "Orders",
            icon: Icons.shopping_cart,
            onPress: () {},
          ),
          DrawerListTile(
            title: "Products",
            icon: Icons.inventory,
            onPress: () {},
          ),
          DrawerListTile(
            title: "Services",
            icon: Icons.miscellaneous_services,
            onPress: () {},
          ),
          DrawerListTile(
            title: "Users",
            icon: Icons.people,
            onPress: () {},
          ),
          DrawerListTile(
            title: "Affiliates",
            icon: Icons.group_work,
            onPress: () {},
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
