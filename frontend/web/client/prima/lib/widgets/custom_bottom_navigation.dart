import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/store.dart';
import '../redux/actions/navigation_actions.dart';
import '../theme/colors.dart';
import 'package:prima/widgets/order_bottom_sheet.dart';
import 'package:spring_button/spring_button.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';

class CustomBottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
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
                onTap: vm.onTabSelected,
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
                      builder: (context) => const OrderBottomSheet(),
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

  _ViewModel({
    required this.currentIndex,
    required this.onTabSelected,
    required this.currentRoute,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      currentIndex: store.state.navigationState.currentIndex,
      currentRoute: store.state.navigationState.currentRoute,
      onTabSelected: (index) {
        if (index != 2) {
          store.dispatch(SetIndexAction(index));
          store.dispatch(SetRouteAction(NavigationState.mainRoutes[index]));
        }
      },
    );
  }
}
