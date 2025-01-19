import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _selectedIndex = 0.obs;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  int get selectedIndex => _selectedIndex.value;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void updateSelectedIndex(int index) {
    _selectedIndex.value = index;
    notifyListeners();
  }
}
