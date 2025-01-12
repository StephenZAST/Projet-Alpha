import '../states/navigation_state.dart';
import '../actions/navigation_actions.dart';

NavigationState navigationReducer(NavigationState state, dynamic action) {
  if (action is SetRouteAction) {
    final newIndex = NavigationState.mainRoutes.contains(action.route) 
        ? NavigationState.mainRoutes.indexOf(action.route)
        : state.currentIndex;
        
    return state.copyWith(
      currentRoute: action.route,
      currentIndex: newIndex,
      navigationStack: [action.route],
    );
  }

  if (action is SetIndexAction) {
    return state.copyWith(
      currentIndex: action.index,
      currentRoute: NavigationState.mainRoutes[action.index],
    );
  }

  if (action is PushRouteAction) {
    final newStack = List<String>.from(state.navigationStack)..add(action.route);
    return state.copyWith(navigationStack: newStack);
  }

  if (action is PopRouteAction && state.navigationStack.length > 1) {
    final newStack = List<String>.from(state.navigationStack..removeLast();
    return state.copyWith(
      navigationStack: newStack,
      currentRoute: newStack.last,
    );
  }

  return state;
}
