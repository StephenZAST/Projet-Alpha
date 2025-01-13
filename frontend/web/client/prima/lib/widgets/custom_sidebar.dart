import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/actions/auth_actions.dart';
import 'package:prima/redux/actions/navigation_actions.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/redux/states/navigation_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/string_utils.dart';
import 'package:redux/redux.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class DrawerSection extends StatelessWidget {
  final String title;
  final List<DrawerItem> items;

  const DrawerSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DrawerViewModel>(
      converter: (store) => _DrawerViewModel.fromStore(store),
      builder: (context, vm) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
          ),
          ...items.map((item) => _buildDrawerItem(
                context: context,
                icon: item.icon,
                text: item.title,
                isSelected: vm.currentRoute == item.route,
                onTap: () {
                  Navigator.pop(context);
                  if (vm.isMainRoute(item.route)) {
                    vm.navigateToMainRoute(context, item.route);
                  } else {
                    vm.navigateToSecondaryRoute(context, item.route);
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.gray600,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SidebarViewModel>(
      converter: (store) => _SidebarViewModel.fromStore(store),
      builder: (context, vm) {
        final displayName = getDisplayName(
          vm.user?['firstName'] as String?,
          vm.user?['lastName'] as String?,
        );

        return Drawer(
          backgroundColor: AppColors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                decoration: const BoxDecoration(color: AppColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/AlphaLogo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const DrawerSection(
                title: 'Navigation',
                items: [
                  DrawerItem(
                      icon: Icons.home, title: 'Accueil', route: '/home'),
                ],
              ),
              const Divider(),
              const DrawerSection(
                title: 'Activité',
                items: [
                  DrawerItem(
                      icon: Icons.receipt,
                      title: 'Commandes',
                      route: '/orders'),
                  DrawerItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      route: '/notifications'),
                ],
              ),
              const Divider(),
              const DrawerSection(
                title: 'Autres',
                items: [
                  DrawerItem(
                      icon: Icons.people,
                      title: 'Parrainage',
                      route: '/referral'),
                  DrawerItem(
                      icon: Icons.settings,
                      title: 'Paramètres',
                      route: '/settings'),
                ],
              ),
              const Divider(height: 1, color: AppColors.gray200),
              const Divider(height: 1, color: AppColors.gray200),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.gray600),
                title: const Text('Déconnexion'),
                onTap: () {
                  vm.onLogout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerViewModel {
  final String currentRoute;
  final Function(BuildContext, String) navigateToMainRoute;
  final Function(BuildContext, String) navigateToSecondaryRoute;
  final bool Function(String) isMainRoute;

  _DrawerViewModel({
    required this.currentRoute,
    required this.navigateToMainRoute,
    required this.navigateToSecondaryRoute,
    required this.isMainRoute,
  });

  static _DrawerViewModel fromStore(Store<AppState> store) {
    return _DrawerViewModel(
      currentRoute: store.state.navigationState.currentRoute,
      isMainRoute: (route) =>
          NavigationState.mainRoutes.contains(route), // Correction ici
      navigateToMainRoute: (context, route) => store.dispatch(
          NavigateToMainRouteAction(
              route, context)), // Ordre des paramètres corrigé
      navigateToSecondaryRoute: (context, route) => store.dispatch(
          NavigateToSecondaryRouteAction(
              route, context)), // Ordre des paramètres corrigé
    );
  }
}

class _SidebarViewModel {
  final Map<String, dynamic>? user;
  final Function() onLogout;

  _SidebarViewModel({
    required this.user,
    required this.onLogout,
  });

  static _SidebarViewModel fromStore(Store<AppState> store) {
    return _SidebarViewModel(
      user: store.state.authState.user,
      onLogout: () => store.dispatch(LogoutAction()),
    );
  }
}
