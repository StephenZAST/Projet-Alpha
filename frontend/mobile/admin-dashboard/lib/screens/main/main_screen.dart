import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../responsive.dart';
import '../../controllers/menu_app_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../orders/orders_screen.dart';
import '../services/services_screen.dart';
import '../categories/categories_screen.dart';
import '../users/users_screen.dart';
import '../profile/admin_profile_screen.dart';
import 'components/admin_side_menu.dart';

class MainScreen extends GetView<MenuAppController> {
  final Widget? child;

  const MainScreen({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[MainScreen] Building with scaffoldKey: ${controller.scaffoldKey}');

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: AdminSideMenu(
        selectedIndex: controller.selectedIndex,
        onItemSelected: controller.updateIndex,
      ),
      drawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu latéral permanent sur desktop
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                child: AdminSideMenu(
                  selectedIndex: controller.selectedIndex,
                  onItemSelected: controller.updateIndex,
                ),
              ),
            // Contenu principal
            Expanded(
              flex: 5,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child ??
                    DashboardScreen(), // Utiliser l'enfant passé ou DashboardScreen par défaut
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget withChild(Widget child) {
    return MainScreen(child: child);
  }
}
