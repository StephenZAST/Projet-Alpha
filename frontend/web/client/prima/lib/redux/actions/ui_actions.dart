import 'package:flutter/material.dart';

class SetLoadingAction {
  final bool isLoading;
  SetLoadingAction(this.isLoading);
}

class SetThemeModeAction {
  final ThemeMode themeMode;
  SetThemeModeAction(this.themeMode);
}

class SetErrorAction {
  final String? error;
  SetErrorAction(this.error);
}

class ToggleDrawerAction {}

class UpdateScreenSizeAction {
  final Size size;
  UpdateScreenSizeAction(this.size);
}
