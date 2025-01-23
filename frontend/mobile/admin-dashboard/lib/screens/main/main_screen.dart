import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../orders/orders_screen.dart';
import '../services/services_screen.dart';
import '../categories/categories_screen.dart';
import '../users/users_screen.dart';
import '../profile/admin_profile_screen.dart';
import 'components/admin_side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MenuAppController menuController = Get.find<MenuAppController>();

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        key: menuController.scaffoldKey,
        drawer: AdminSideMenu(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              if (menuController.scaffoldKey.currentState?.isDrawerOpen ??
                  false) {
                Navigator.pop(context);
              } else {
                menuController.scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affiche le menu latéral en permanence sur desktop
              if (Responsive.isDesktop(context))
                Expanded(
                  flex: 1,
                  child: AdminSideMenu(),
                ),
              // Contenu principal
              Expanded(
                flex: 5,
                child: Obx(() {
                  switch (menuController.selectedIndex) {
                    case 0:
                      return DashboardScreen();
                    case 1:
                      return OrdersScreen();
                    case 2:
                      return ServicesScreen();
                    case 3:
                      return CategoriesScreen();
                    case 4:
                      return UsersScreen();
                    case 5:
                      return AdminProfileScreen();
                    default:
                      return DashboardScreen();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
