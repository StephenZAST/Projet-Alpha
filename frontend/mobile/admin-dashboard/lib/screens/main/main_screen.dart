import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../responsive.dart';
import '../../controllers/menu_app_controller.dart';
import 'components/admin_side_menu.dart';

class MainScreen extends GetView<MenuAppController> {
  final String screenIdentifier;

  MainScreen({
    this.screenIdentifier = 'default',
    Key? key,
  }) : super(key: Key('main_$screenIdentifier')); // Correction ici

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('scaffold_$screenIdentifier'),
      drawer: AdminSideMenu(
        key: Key('drawer_$screenIdentifier'),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 1,
                child: AdminSideMenu(
                  key: Key('desktop_drawer_$screenIdentifier'),
                ),
              ),
            Expanded(
              flex: 5,
              child: Obx(() {
                final screen = controller.getScreen();
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
