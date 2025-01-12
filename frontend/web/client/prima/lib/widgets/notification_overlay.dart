import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../redux/store.dart';
import '../theme/colors.dart';

class NotificationOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        if (vm.currentNotification == null) return const SizedBox.shrink();

        return Positioned(
          top: 60,
          right: 16,
          left: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(vm.currentNotification!['type']),
                borderRadius: BorderRadius.circular(8),
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(vm.currentNotification!['type']),
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vm.currentNotification!['message'],
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: vm.dismissNotification,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}

class _ViewModel {
  final Map<String, dynamic>? currentNotification;
  final Function dismissNotification;

  _ViewModel({
    required this.currentNotification,
    required this.dismissNotification,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      currentNotification: store.state.notificationState.currentNotification,
      dismissNotification: () => store.dispatch(DismissNotificationAction()),
    );
  }
}
