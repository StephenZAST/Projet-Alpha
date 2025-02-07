import 'dart:developer' as dev; // Correction de l'import pour debugger
import 'package:admin/services/error_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Ajout de cet import pour kDebugMode
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
  // Définir les clés comme static final
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'MainScaffold');
  static final GlobalKey _mobileDrawerKey =
      GlobalKey(debugLabel: 'MobileDrawer');
  static final GlobalKey _desktopDrawerKey =
      GlobalKey(debugLabel: 'DesktopDrawer');

  @override
  Widget build(BuildContext context) {
    // Utiliser le debugger correctement
    // dev.debugger(); // Décommenter si vous voulez un point d'arrêt

    // Maintenant kDebugMode est disponible
    if (kDebugMode) {
      print('[MainScreen] Building with GlobalKeys:');
      print('ScaffoldKey: $_scaffoldKey');
      print('MobileDrawerKey: $_mobileDrawerKey');
      print('DesktopDrawerKey: $_desktopDrawerKey');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ErrorTrackingService.dumpKeyUsage();
    });

    // Sync with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = Get.currentRoute;
      if (currentRoute != '/' && currentRoute != '') {
        controller.syncWithRoute(currentRoute);
      }
    });

    // Traquer l'utilisation des clés
    ErrorTrackingService.trackGlobalKey(_scaffoldKey, 'MainScreen');
    ErrorTrackingService.trackGlobalKey(_mobileDrawerKey, 'MainScreen');
    ErrorTrackingService.trackGlobalKey(_desktopDrawerKey, 'MainScreen');

    return Scaffold(
      key: _scaffoldKey,
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
