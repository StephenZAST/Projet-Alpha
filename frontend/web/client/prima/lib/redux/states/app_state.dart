import 'auth_state.dart';
import 'profile_state.dart';
import 'address_state.dart';
import 'article_state.dart';
import 'service_state.dart';
import 'order_state.dart';
import 'navigation_state.dart';
import 'notification_state.dart';

class AppState {
  final AuthState authState;
  final ProfileState profileState;
  final AddressState addressState;
  final ArticleState articleState;
  final ServiceState serviceState;
  final OrderState orderState;
  final NavigationState navigationState;
  final NotificationState notificationState;

  AppState({
    required this.authState,
    required this.profileState,
    required this.addressState,
    required this.articleState,
    required this.serviceState,
    required this.orderState,
    required this.navigationState,
    required this.notificationState,
  });

  factory AppState.initial() {
    return AppState(
      authState: AuthState(),
      profileState: ProfileState(),
      addressState: AddressState(),
      articleState: ArticleState(),
      serviceState: ServiceState(),
      orderState: OrderState(),
      navigationState: NavigationState(),
      notificationState: NotificationState(),
    );
  }

  AppState copyWith({
    AuthState? authState,
    ProfileState? profileState,
    AddressState? addressState,
    ArticleState? articleState,
    ServiceState? serviceState,
    OrderState? orderState,
    NavigationState? navigationState,
    NotificationState? notificationState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      profileState: profileState ?? this.profileState,
      addressState: addressState ?? this.addressState,
      articleState: articleState ?? this.articleState,
      serviceState: serviceState ?? this.serviceState,
      orderState: orderState ?? this.orderState,
      navigationState: navigationState ?? this.navigationState,
      notificationState: notificationState ?? this.notificationState,
    );
  }
}
