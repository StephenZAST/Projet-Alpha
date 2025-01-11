import 'package:flutter/material.dart';

class BottomSheetManager {
  static final BottomSheetManager _instance = BottomSheetManager._internal();
  factory BottomSheetManager() => _instance;
  BottomSheetManager._internal();

  PersistentBottomSheetController? _currentController;
  bool _isBottomSheetOpen = false;

  Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) async {
    if (_isBottomSheetOpen) {
      _currentController?.close();
    }

    _isBottomSheetOpen = true;

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return builder(context);
      },
    );

    _isBottomSheetOpen = false;
    return result;
  }
}
