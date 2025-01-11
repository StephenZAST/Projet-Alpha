import 'package:redux/redux.dart';
import '../states/auth_state.dart';
import '../actions/auth_actions.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginRequestAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is LoginSuccessAction) {
    return state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      token: action.token,
      user: action.user,
      error: null,
    );
  }

  if (action is LoginFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is LogoutAction) {
    return AuthState();
  }

  if (action is SetTempCredentialsAction) {
    return state.copyWith(
      tempEmail: action.email,
      tempPassword: action.password,
    );
  }

  if (action is ClearTempCredentialsAction) {
    return state.copyWith(
      tempEmail: null,
      tempPassword: null,
    );
  }

  // Reducers pour la réinitialisation du mot de passe
  if (action is RequestResetCodeAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
      resetPasswordSuccess: false,
    );
  }

  if (action is RequestResetCodeSuccessAction) {
    return state.copyWith(
      isLoading: false,
      resetPasswordSuccess: true,
      resetPasswordStep: 1,
    );
  }

  if (action is RequestResetCodeFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
      resetPasswordSuccess: false,
    );
  }

  if (action is VerifyResetCodeAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
      resetPasswordSuccess: false,
    );
  }

  if (action is VerifyResetCodeSuccessAction) {
    return state.copyWith(
      isLoading: false,
      resetPasswordSuccess: true,
      resetPasswordStep: 2,
    );
  }

  if (action is VerifyResetCodeFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
      resetPasswordSuccess: false,
    );
  }

  if (action is ResetPasswordAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
      resetPasswordSuccess: false,
    );
  }

  if (action is ResetPasswordSuccessAction) {
    return state.copyWith(
      isLoading: false,
      resetPasswordSuccess: true,
      resetPasswordStep: 3,
    );
  }

  if (action is ResetPasswordFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
      resetPasswordSuccess: false,
    );
  }

  return state;
}
