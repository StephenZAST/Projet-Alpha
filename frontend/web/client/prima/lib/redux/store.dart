import 'package:prima/providers/profile_data_provider.dart';
import 'package:prima/redux/reducers/address_reducer.dart';
import 'package:prima/redux/states/address_state.dart';
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
import 'middleware/address_middleware.dart';
import 'states/article_state.dart';
import 'reducers/article_reducer.dart';
import 'middleware/article_middleware.dart';

class AppState {
  final AuthState authState;
  final ProfileState profileState;
  final AddressState addressState;
  final ArticleState articleState;

  AppState({
    required this.authState,
    required this.profileState,
    required this.addressState,
    required this.articleState,
  });

  AppState copyWith({
    AuthState? authState,
    ProfileState? profileState,
    AddressState? addressState,
    ArticleState? articleState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      profileState: profileState ?? this.profileState,
      addressState: addressState ?? this.addressState,
      articleState: articleState ?? this.articleState,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    profileState: profileReducer(state.profileState, action),
    addressState: addressReducer(state.addressState, action),
    articleState: articleReducer(state.articleState, action),
  );
}

Store<AppState> createStore(
  Dio dio,
  AuthDataProvider authDataProvider,
  ProfileDataProvider profileDataProvider,
) {
  final authMiddleware = AuthMiddleware(dio, authDataProvider);
  final profileMiddleware = ProfileMiddleware(dio, profileDataProvider);
  final addressMiddleware = AddressMiddleware(dio);
  final articleMiddleware = ArticleMiddleware(dio);

  return Store<AppState>(
    appReducer,
    initialState: AppState(
      authState: AuthState(),
      profileState: ProfileState(),
      addressState: AddressState(),
      articleState: ArticleState(),
    ),
    middleware: [
      thunkMiddleware,
      ...authMiddleware.createMiddleware(),
      ...profileMiddleware.createMiddleware(),
      ...addressMiddleware.createMiddleware(),
      ...articleMiddleware.createMiddleware(),
    ],
  );
}
