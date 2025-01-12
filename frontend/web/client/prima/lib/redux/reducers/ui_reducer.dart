import '../states/ui_state.dart';
import '../actions/ui_actions.dart';

UIState uiReducer(UIState state, dynamic action) {
  if (action is SetLoadingAction) {
    return state.copyWith(isLoading: action.isLoading);
  }

  if (action is SetThemeModeAction) {
    return state.copyWith(themeMode: action.themeMode);
  }

  if (action is SetErrorAction) {
    return state.copyWith(error: action.error);
  }

  if (action is ToggleDrawerAction) {
    return state.copyWith(isDrawerOpen: !state.isDrawerOpen);
  }

  if (action is UpdateScreenSizeAction) {
    return state.copyWith(screenSize: action.size);
  }

  return state;
}
