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
      // Fermer le bottom sheet actuel avant d'en ouvrir un nouveau
      _currentController?.close();
    }

    _isBottomSheetOpen = true;

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 200),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: ModalRoute.of(context)!.animation!,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOut,
              )),
              child: builder(context),
            );
          },
        );
      },
    );

    _isBottomSheetOpen = false;
    return result;
  }
}
