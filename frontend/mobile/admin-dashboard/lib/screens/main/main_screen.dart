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
import '../notifications/notifications_screen.dart';
import 'components/admin_side_menu.dart';

class MainScreen extends GetView<MenuAppController> {
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
      onDrawerChanged: controller.setDrawerState,
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
              child: Obx(() {
                print(
                    '[MainScreen] Rebuilding content with index: ${controller.selectedIndex}');
                Widget content;
                switch (controller.selectedIndex) {
                  case 0:
                    content = DashboardScreen();
                    break;
                  case 1:
                    content = OrdersScreen();
                    break;
                  case 2:
                    content = ServicesScreen();
                    break;
                  case 3:
                    content = CategoriesScreen();
                    break;
                  case 4:
                    content = UsersScreen();
                    break;
                  case 5:
                    content = AdminProfileScreen();
                    break;
                  case 6:
                    content = NotificationsScreen();
                    break;
                  default:
                    content = DashboardScreen();
                }
                print('[MainScreen] Selected content: ${content.runtimeType}');
                return Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: content,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
