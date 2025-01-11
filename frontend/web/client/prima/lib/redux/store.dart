import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'states/auth_state.dart';
import 'states/profile_state.dart';
import 'reducers/auth_reducer.dart';
import 'reducers/profile_reducer.dart';
import '../providers/auth_data_provider.dart';
import 'package:dio/dio.dart';
import 'middleware/auth_middleware.dart';
import 'middleware/profile_middleware.dart';

class AppState {
  final AuthState authState;
  final ProfileState profileState;

  AppState({
    required this.authState,
    required this.profileState,
  });

  AppState copyWith({
    AuthState? authState,
    ProfileState? profileState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      profileState: profileState ?? this.profileState,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    profileState: profileReducer(state.profileState, action),
  );
}

Store<AppState> createStore(
  Dio dio,
  AuthDataProvider authDataProvider,
  ProfileDataProvider profileDataProvider,
) {
  final authMiddleware = AuthMiddleware(dio, authDataProvider);
  final profileMiddleware = ProfileMiddleware(dio, profileDataProvider);

  return Store<AppState>(
    appReducer,
    initialState: AppState(
      authState: AuthState(),
      profileState: ProfileState(),
    ),
    middleware: [
      thunkMiddleware,
      ...authMiddleware.createMiddleware(),
      ...profileMiddleware.createMiddleware(),
    ],
  );
}
