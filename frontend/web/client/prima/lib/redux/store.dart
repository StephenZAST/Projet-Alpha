import 'package:dio/dio.dart';
import 'package:prima/redux/states/auth_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../providers/auth_data_provider.dart';
import '../providers/profile_data_provider.dart';
import '../services/article_service.dart';
import '../services/address_service.dart';
import 'states/app_state.dart';
import 'reducers/app_reducer.dart';
import 'middleware/auth_middleware.dart';
import 'middleware/profile_middleware.dart';
import 'middleware/address_middleware.dart';
import 'middleware/article_middleware.dart';
import 'middleware/service_middleware.dart';
import 'middleware/storage_middleware.dart';

Store<AppState> createStore(Dio dio, AuthDataProvider authDataProvider,
    ProfileDataProvider profileDataProvider,
    {AppState? initialState}) {
  final authMiddleware = AuthMiddleware(dio, authDataProvider);
  final profileMiddleware = ProfileMiddleware(dio, profileDataProvider);
  final addressService = AddressService(dio);
  final addressMiddleware = AddressMiddleware(addressService);
  final articleMiddleware = ArticleMiddleware(ArticleService(dio));
  final serviceMiddleware = ServiceMiddleware(dio);
  final storageMiddleware = StorageMiddleware(
    authDataProvider: authDataProvider,
  );

  return Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState.initial(),
    middleware: [
      thunkMiddleware,
      ...authMiddleware.createMiddleware(),
      ...profileMiddleware.createMiddleware(),
      ...addressMiddleware.createMiddleware(),
      ...articleMiddleware.createMiddleware(),
      ...serviceMiddleware.createMiddleware(),
      ...storageMiddleware.createMiddleware(),
    ],
  );
}

Future<Store<AppState>> initStore(
  Dio dio,
  AuthDataProvider authDataProvider,
  ProfileDataProvider profileDataProvider,
) async {
  final token = await authDataProvider.getStoredToken();
  final userData = await authDataProvider.getStoredUserData();

  return createStore(
    dio,
    authDataProvider,
    profileDataProvider,
    initialState: AppState.initial().copyWith(
      authState: AuthState(
        isAuthenticated: token != null,
        token: token,
        user: userData,
      ),
    ),
  );
}
