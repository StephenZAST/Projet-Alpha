import 'package:flutter/material.dart';
import 'package:prima/navigation/navigation_provider.dart';
import 'package:prima/redux/actions/navigation_actions.dart';
import 'package:prima/redux/actions/notification_actions.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';
import 'package:prima/widgets/custom_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        store.dispatch(FetchNotificationsAction());
        store.dispatch(SetRouteAction('/notifications'));
      },
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          backgroundColor: AppColors.dashboardBackground,
          drawer: const CustomSidebar(),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (BuildContext context) => SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              AppBarComponent(
                                title: 'Notifications',
                                onMenuPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                              const AddressSectionComponent(),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Mes Notifications',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray800,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vm.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = vm.notifications[index];
                              return NotificationCard(
                                  notification: notification);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(notification['title'] ?? ''),
        subtitle: Text(notification['message'] ?? ''),
        trailing: Text(notification['date'] ?? ''),
      ),
    );
  }
}

class _ViewModel {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String currentRoute;

  _ViewModel({
    required this.notifications,
    required this.isLoading,
    required this.currentRoute,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      notifications: store.state.notificationState.notifications,
      isLoading: store.state.notificationState.isLoading,
      currentRoute: store.state.navigationState.currentRoute,
    );
  }
}
