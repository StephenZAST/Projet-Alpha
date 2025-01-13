import 'dart:developer';
import 'package:prima/redux/actions/address_actions.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import '../store.dart';
import '../actions/auth_actions.dart';
import '../actions/profile_actions.dart';
import '../../providers/auth_data_provider.dart';

class StorageMiddleware {
  final AuthDataProvider authDataProvider;

  // Simplification du constructeur pour n'utiliser que authDataProvider
  StorageMiddleware({required this.authDataProvider});

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoginSuccessAction>(_persistAuthData),
      TypedMiddleware<AppState, RegisterSuccessAction>(_persistAuthData),
      TypedMiddleware<AppState, LogoutAction>(_clearAuthData),
      TypedMiddleware<AppState, UpdateProfileSuccessAction>(_persistUserData),
    ];
  }

  void _persistAuthData(
      Store<AppState> store, dynamic action, NextDispatcher next) async {
    print('StorageMiddleware: Persisting auth data'); // Log pour debug
    next(action);

    try {
      if (action is LoginSuccessAction || action is RegisterSuccessAction) {
        await authDataProvider.saveToken(action.token);
        await authDataProvider.saveUserData(action.user);
        print('Auth data persisted successfully'); // Log pour debug
      }
    } catch (e) {
      print('Error persisting auth data: $e'); // Log pour debug
    }
  }

  void _clearAuthData(
      Store<AppState> store, LogoutAction action, NextDispatcher next) async {
    print('StorageMiddleware: Clearing auth data'); // Log pour debug
    next(action);

    try {
      await authDataProvider.clearStoredData();
      print('Auth data cleared successfully'); // Log pour debug
    } catch (e) {
      print('Error clearing auth data: $e'); // Log pour debug
    }
  }

  void _persistUserData(Store<AppState> store,
      UpdateProfileSuccessAction action, NextDispatcher next) async {
    print('StorageMiddleware: Updating stored user data'); // Log pour debug
    next(action);

    try {
      await authDataProvider
          .saveUserData(action.profile); // Changé de updatedUser à profile
      print('User data updated successfully'); // Log pour debug
    } catch (e) {
      print('Error updating user data: $e'); // Log pour debug
    }
  }

  Future<void> syncWithBackend(Store<AppState> store) async {
    print('StorageMiddleware: Syncing with backend');
    try {
      final token = await authDataProvider.getStoredToken();
      if (token != null) {
        store.dispatch(LoadAddressesAction());
        print('Backend sync completed');
      }
    } catch (e) {
      print('Error syncing with backend: $e');
    }
  }
}
