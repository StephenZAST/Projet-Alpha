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

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MenuAppController _menuController = Get.find<MenuAppController>();
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Fermer le drawer après la sélection sur mobile
    if (!Responsive.isDesktop(context)) {
      Navigator.of(context).pop(); // Ferme le drawer
    }
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
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
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                ),
              ),
            // Contenu principal
            Expanded(
              flex: 5,
              child: _getScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
