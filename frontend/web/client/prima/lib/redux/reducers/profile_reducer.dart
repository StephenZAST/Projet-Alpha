import '../states/profile_state.dart';
import '../actions/profile_actions.dart';

ProfileState profileReducer(ProfileState state, dynamic action) {
  print('ProfileReducer: handling ${action.runtimeType}');

  if (action is LoadProfileAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadProfileSuccessAction) {
    return state.copyWith(
      isLoading: false,
      profile: action.profile,
      error: null,
    );
  }

  if (action is LoadProfileFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is UpdateProfileAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is UpdateProfileSuccessAction) {
    return state.copyWith(
      isLoading: false,
      profile: action.profile,
      error: null,
    );
  }

  if (action is UpdateProfileFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is ClearProfileAction) {
    return ProfileState();
  }

  return state;
}
