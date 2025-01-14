import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/models/service.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/redux/states/navigation_state.dart';
import 'package:redux/redux.dart';
import '../redux/actions/navigation_actions.dart';
import '../redux/actions/service_actions.dart';
import '../redux/actions/article_actions.dart';
import '../redux/actions/profile_actions.dart';
import '../theme/colors.dart';
import 'package:prima/widgets/order_bottom_sheet.dart';
import 'package:spring_button/spring_button.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        // Load initial data when authenticated
        store.dispatch(LoadServicesAction());
        store.dispatch(LoadArticlesAction());
        store.dispatch(LoadProfileAction());
        print('Initializing data loading in CustomBottomNavigation');
      },
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: BottomNavigationBar(
                currentIndex: vm.currentIndex,
                onTap: (index) {
                  StoreProvider.of<AppState>(context)
                      .dispatch(SetIndexAction(index));
                  final routes = [
                    '/home',
                    '/offers',
                    '/services',
                    '/chat',
                    '/profile'
                  ];
                  StoreProvider.of<AppState>(context)
                      .dispatch(SetRouteAction(routes[index]));
                },
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.gray500,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                iconSize: 24,
                items: [
                  _buildNavItem(Icons.home_rounded, 'Home', 0, vm.currentIndex),
                  _buildNavItem(
                      Icons.local_offer_rounded, 'Offres', 1, vm.currentIndex),
                  const BottomNavigationBarItem(
                      icon: SizedBox(height: 40), label: ''),
                  _buildNavItem(
                      Icons.chat_bubble_rounded, 'Chat', 3, vm.currentIndex),
                  _buildNavItem(
                      Icons.person_rounded, 'Profile', 4, vm.currentIndex),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -12,
              child: Center(
                child: SpringButton(
                  SpringButtonType.OnlyScale,
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.add, color: AppColors.white, size: 30),
                  ),
                  onTap: () {
                    BottomSheetManager().showCustomBottomSheet(
                      context: context,
                      builder: (context) => OrderBottomSheet(
                          initialService: Service(
                        id: '',
                        name: '',
                        price: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      )),
                    );
                  },
                  scaleCoefficient: 0.9,
                  useCache: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, int currentIndex) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(currentIndex == index ? 12 : 8),
        decoration: BoxDecoration(
          color: currentIndex == index
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

class _ViewModel {
  final int currentIndex;
  final Function(int) onTabSelected;
  final String currentRoute;
  final bool isLoading;
  final String? error;

  _ViewModel({
    required this.currentIndex,
    required this.onTabSelected,
    required this.currentRoute,
    this.isLoading = false,
    this.error,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      currentIndex: store.state.navigationState.currentIndex,
      currentRoute: store.state.navigationState.currentRoute,
      isLoading: store.state.serviceState.isLoading ||
          store.state.articleState.isLoading,
      error: store.state.serviceState.error ?? store.state.articleState.error,
      onTabSelected: (index) {
        if (index != 2) {
          store.dispatch(SetIndexAction(index));
          store.dispatch(SetRouteAction(NavigationState.mainRoutes[index]));
        }
      },
    );
  }
}
