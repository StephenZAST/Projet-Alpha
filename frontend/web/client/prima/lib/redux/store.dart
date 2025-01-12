import 'package:prima/providers/address_data_provider.dart';
import 'package:prima/redux/actions/auth_actions.dart';

import 'states/order_state.dart'; // Utiliser uniquement cette version
import 'package:prima/providers/profile_data_provider.dart';
import 'package:prima/redux/reducers/address_reducer.dart';
import 'package:prima/redux/reducers/order_reducer.dart';
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
import 'states/service_state.dart';
import 'reducers/service_reducer.dart';
import 'middleware/service_middleware.dart';
import '../services/article_service.dart';
import 'middleware/storage_middleware.dart'; // Ajout de l'import
import '../middleware/order_middleware.dart';
import '../reducers/app_reducer.dart';
import '../states/app_state.dart';
import '../../services/address_service.dart';

class AppState {
  final AuthState authState;
  final ProfileState profileState;
  final AddressState addressState;
  final ArticleState articleState;
  final ServiceState serviceState;
  final OrderState
      orderState; // Ceci utilisera maintenant la version de redux/states/
  final NavigationState navigationState;

  AppState({
    required this.authState,
    required this.profileState,
    required this.addressState,
    required this.articleState,
    required this.serviceState,
    required this.orderState, // Ajout du paramètre
    required this.navigationState,
  });

  AppState copyWith({
    AuthState? authState,
    ProfileState? profileState,
    AddressState? addressState,
    ArticleState? articleState,
    ServiceState? serviceState,
    OrderState? orderState, // Ajout du paramètre
    NavigationState? navigationState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      profileState: profileState ?? this.profileState,
      addressState: addressState ?? this.addressState,
      articleState: articleState ?? this.articleState,
      serviceState: serviceState ?? this.serviceState,
      orderState: orderState ?? this.orderState, // Ajout de la copie
      navigationState: navigationState ?? this.navigationState,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    profileState: profileReducer(state.profileState, action),
    addressState: addressReducer(state.addressState, action),
    articleState: articleReducer(state.articleState, action),
    serviceState: serviceReducer(state.serviceState, action),
    orderState: orderReducer(state.orderState, action), // Ajout du reducer
    navigationState: navigationReducer(state.navigationState, action),
  );
}

Store<AppState> createStore(Dio dio, AuthDataProvider authDataProvider,
    ProfileDataProvider profileDataProvider,
    {AppState? initialState}) {
  final authMiddleware = AuthMiddleware(dio, authDataProvider);
  final profileMiddleware = ProfileMiddleware(dio, profileDataProvider);
  final addressMiddleware = AddressMiddleware(dio);
  final articleMiddleware = ArticleMiddleware(ArticleService(dio));
  final serviceMiddleware = ServiceMiddleware(dio);
  final storageMiddleware = StorageMiddleware(
    authDataProvider: authDataProvider,
  );

  return Store<AppState>(
    appReducer,
    initialState: initialState ??
        AppState(
          authState: AuthState(),
          profileState: ProfileState(),
          addressState: AddressState(),
          articleState: ArticleState(),
          serviceState: ServiceState(),
          orderState: OrderState(),
          navigationState: NavigationState(),
        ),
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
  final addressService = AddressService(dio);
  final articleService = ArticleService(dio);

  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      thunkMiddleware,
      ...AuthMiddleware(dio, authDataProvider).createMiddleware(),
      ...ProfileMiddleware(dio, profileDataProvider).createMiddleware(),
      ...AddressMiddleware(addressService).createMiddleware(),
      ...OrderMiddleware(dio).createMiddleware(),
      ...ServiceMiddleware(dio).createMiddleware(),
      ...ArticleMiddleware(articleService).createMiddleware(),
    ],
  );
}
