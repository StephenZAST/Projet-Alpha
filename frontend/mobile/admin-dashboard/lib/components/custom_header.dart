import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../routes/admin_routes.dart';
import '../controllers/menu_app_controller.dart';
import '../responsive.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomHeader({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuAppController>();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context) && !showBackButton)
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: controller.controlMenu,
            ),
          if (showBackButton && AdminRoutes.canGoBack())
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                AdminRoutes.goBack();
              },
              tooltip: 'Retour',
            ),
          if (!Responsive.isDesktop(context) &&
              (showBackButton || !showBackButton))
            SizedBox(width: defaultPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
