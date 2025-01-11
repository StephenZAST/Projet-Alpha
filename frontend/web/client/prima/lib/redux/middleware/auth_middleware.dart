import 'package:prima/redux/store.dart';
import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../states/auth_state.dart';
import '../actions/auth_actions.dart';
import '../../providers/auth_data_provider.dart';

class AuthMiddleware {
  final Dio dio;
  final AuthDataProvider authDataProvider;

  AuthMiddleware(this.dio, this.authDataProvider);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoginRequestAction>(_handleLogin),
      TypedMiddleware<AppState, RegisterRequestAction>(_handleRegister),
      TypedMiddleware<AppState, LogoutAction>(_handleLogout),
      TypedMiddleware<AppState, RequestResetCodeAction>(
          _handleRequestResetCode),
      TypedMiddleware<AppState, VerifyResetCodeAction>(_handleVerifyResetCode),
      TypedMiddleware<AppState, ResetPasswordAction>(_handleResetPassword),
    ];
  }

  void _handleLogin(
    Store<AppState> store,
    LoginRequestAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {
          'email': action.email,
          'password': action.password,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final userData = response.data['data'];
        store.dispatch(LoginSuccessAction(
          userData['token'],
          userData['user'],
        ));
        await authDataProvider.saveToken(userData['token']);
        await authDataProvider.saveUserData(userData['user']);
      } else {
        store.dispatch(LoginFailureAction(
          response.data['error'] ?? 'Authentication failed',
        ));
      }
    } catch (e) {
      store.dispatch(LoginFailureAction('Connection error: $e'));
    }
  }

  void _handleRegister(
    Store<AppState> store,
    RegisterRequestAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.post(
        '/api/auth/register',
        data: {
          'email': action.email,
          'password': action.password,
          'firstName': action.firstName,
          'lastName': action.lastName,
          'phone': action.phone,
          'affiliateCode': action.affiliateCode,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final userData = response.data['data'];
        store.dispatch(RegisterSuccessAction(
          userData['token'],
          userData['user'],
        ));
        await authDataProvider.saveToken(userData['token']);
        await authDataProvider.saveUserData(userData['user']);
      } else {
        store.dispatch(RegisterFailureAction(
          response.data['error'] ?? 'Registration failed',
        ));
      }
    } catch (e) {
      store.dispatch(RegisterFailureAction('Connection error: $e'));
    }
  }

  void _handleLogout(
    Store<AppState> store,
    LogoutAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      await dio.post('/api/auth/logout');
      await authDataProvider.clearStoredData();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  void _handleRequestResetCode(
    Store<AppState> store,
    RequestResetCodeAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.post(
        '/api/auth/reset-password',
        data: {'email': action.email},
      );

      if (response.statusCode == 200) {
        store.dispatch(RequestResetCodeSuccessAction());
      } else {
        store.dispatch(RequestResetCodeFailureAction(
          response.data['error'] ?? 'Failed to send reset code',
        ));
      }
    } catch (e) {
      store.dispatch(RequestResetCodeFailureAction(e.toString()));
    }
  }

  void _handleVerifyResetCode(
    Store<AppState> store,
    VerifyResetCodeAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.post(
        '/api/auth/verify-code',
        data: {
          'email': action.email,
          'code': action.code,
        },
      );

      if (response.statusCode == 200) {
        store.dispatch(VerifyResetCodeSuccessAction());
      } else {
        store.dispatch(VerifyResetCodeFailureAction(
          response.data['error'] ?? 'Invalid code',
        ));
      }
    } catch (e) {
      store.dispatch(VerifyResetCodeFailureAction(e.toString()));
    }
  }

  void _handleResetPassword(
    Store<AppState> store,
    ResetPasswordAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.post(
        '/api/auth/verify-code-and-reset-password',
        data: {
          'email': action.email,
          'code': action.code,
          'newPassword': action.newPassword,
        },
      );

      if (response.statusCode == 200) {
        store.dispatch(ResetPasswordSuccessAction());
      } else {
        store.dispatch(ResetPasswordFailureAction(
          response.data['error'] ?? 'Failed to reset password',
        ));
      }
    } catch (e) {
      store.dispatch(ResetPasswordFailureAction(e.toString()));
    }
  }
}
