import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuAppController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _selectedIndex = 0.obs;
  final _isDrawerOpen = false.obs;

  int get selectedIndex => _selectedIndex.value;
  bool get isDrawerOpen => _isDrawerOpen.value;

  void controlMenu() {
    print('[MenuAppController] controlMenu called');
    print('[MenuAppController] scaffoldKey: $scaffoldKey');

    try {
      if (scaffoldKey.currentState == null) {
        print('[MenuAppController] Error: scaffoldKey.currentState is null');
        return;
      }

      if (!scaffoldKey.currentState!.isDrawerOpen) {
        print('[MenuAppController] Opening drawer');
        scaffoldKey.currentState!.openDrawer();
        _isDrawerOpen.value = true;
      } else {
        print('[MenuAppController] Closing drawer');
        scaffoldKey.currentState!.closeDrawer();
        _isDrawerOpen.value = false;
      }
    } catch (e) {
      print('[MenuAppController] Error controlling drawer: $e');
    }
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
    _isDrawerOpen.value = false;
  }

  void updateIndex(int index) {
    _selectedIndex.value = index;
    // Fermer le drawer après la sélection sur mobile
    if (_isDrawerOpen.value) {
      closeDrawer();
    }
  }

  void setDrawerState(bool isOpen) {
    _isDrawerOpen.value = isOpen;
  }

  @override
  void onInit() {
    super.onInit();
    print('[MenuAppController] Initialized with scaffoldKey: $scaffoldKey');
  }

  @override
  void onReady() {
    super.onReady();
    print('[MenuAppController] Ready with scaffoldKey: $scaffoldKey');
  }
}
