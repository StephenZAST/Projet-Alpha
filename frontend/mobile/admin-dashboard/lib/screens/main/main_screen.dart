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
  static const _mobileDrawerKey = Key('mobile-drawer');
  static const _desktopDrawerKey = Key('desktop-drawer');

  @override
  Widget build(BuildContext context) {
    // Sync with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = Get.currentRoute;
      if (currentRoute != '/' && currentRoute != '') {
        controller.syncWithRoute(currentRoute);
      }
    });

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: AdminSideMenu(
        key: _mobileDrawerKey,
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
                  key: _desktopDrawerKey,
                ),
              ),
            // Contenu principal
            Expanded(
              flex: 5,
              child: Obx(() {
                final index = controller.selectedIndex.value;
                print('[MainScreen] Building content for index: $index');

                final screen = controller.getScreen();
                print('[MainScreen] Screen type: ${screen.runtimeType}');

                return Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: screen,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
