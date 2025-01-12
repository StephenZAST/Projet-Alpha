import 'package:flutter/material.dart';

class UIState {
  final bool isLoading;
  final ThemeMode themeMode;
  final String? error;
  final bool isDrawerOpen;
  final Size screenSize;

  UIState({
    this.isLoading = false,
    this.themeMode = ThemeMode.system,
    this.error,
    this.isDrawerOpen = false,
    this.screenSize = const Size(0, 0),
  });

  UIState copyWith({
    bool? isLoading,
    ThemeMode? themeMode,
    String? error,
    bool? isDrawerOpen,
    Size? screenSize,
  }) {
    return UIState(
      isLoading: isLoading ?? this.isLoading,
      themeMode: themeMode ?? this.themeMode,
      error: error ?? this.error,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      screenSize: screenSize ?? this.screenSize,
    );
  }
}
