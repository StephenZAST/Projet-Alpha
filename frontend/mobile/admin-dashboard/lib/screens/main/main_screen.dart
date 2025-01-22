import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import 'components/admin_side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MenuAppController menuController = Get.find<MenuAppController>();

    return Scaffold(
      key: menuController.scaffoldKey,
      drawer: AdminSideMenu(),
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
                  default:
                    return Navigator(
                      key: Get.nestedKey(1),
                      onGenerateRoute: (settings) {
                        return GetPageRoute(
                          page: () => DashboardScreen(),
                        );
                      },
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
