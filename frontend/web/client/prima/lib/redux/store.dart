import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'states/auth_state.dart';
import 'reducers/auth_reducer.dart';
import '../providers/auth_data_provider.dart';
import 'package:dio/dio.dart';
import 'middleware/auth_middleware.dart';

class AppState {
  final AuthState authState;

  AppState({
    required this.authState,
  });

  AppState copyWith({
    AuthState? authState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
  );
}

Store<AppState> createStore(Dio dio, AuthDataProvider authDataProvider) {
  final authMiddleware = AuthMiddleware(dio, authDataProvider);

  return Store<AppState>(
    appReducer,
    initialState: AppState(
      authState: AuthState(),
    ),
    middleware: [
      thunkMiddleware,
      ...authMiddleware.createMiddleware(),
    ],
  );
}
