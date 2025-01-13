import '../states/app_state.dart';
import 'auth_reducer.dart';
import 'profile_reducer.dart';
import 'address_reducer.dart';
import 'article_reducer.dart';
import 'service_reducer.dart';
import 'order_reducer.dart';
import 'navigation_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  print('AppReducer: handling ${action.runtimeType}');

  return AppState(
    authState: authReducer(state.authState, action),
    profileState: profileReducer(state.profileState, action),
    addressState: addressReducer(state.addressState, action),
    articleState: articleReducer(state.articleState, action),
    serviceState: serviceReducer(state.serviceState, action),
    orderState: orderReducer(state.orderState, action),
    navigationState: navigationReducer(state.navigationState, action),
  );
}
