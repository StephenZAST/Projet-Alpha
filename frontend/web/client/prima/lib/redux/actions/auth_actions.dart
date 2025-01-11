// Actions de base
class LoginRequestAction {
  final String email;
  final String password;

  LoginRequestAction(this.email, this.password);
}

class LoginSuccessAction {
  final String token;
  final Map<String, dynamic> user;

  LoginSuccessAction(this.token, this.user);
}

class LoginFailureAction {
  final String error;

  LoginFailureAction(this.error);
}

class LogoutAction {}

class SetTempCredentialsAction {
  final String email;
  final String password;

  SetTempCredentialsAction(this.email, this.password);
}

class ClearTempCredentialsAction {}

class RegisterRequestAction {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? affiliateCode;

  RegisterRequestAction({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.affiliateCode,
  });
}

class RegisterSuccessAction {
  final String token;
  final Map<String, dynamic> user;

  RegisterSuccessAction(this.token, this.user);
}

class RegisterFailureAction {
  final String error;

  RegisterFailureAction(this.error);
}

// Actions pour la réinitialisation du mot de passe
class RequestResetCodeAction {
  final String email;
  RequestResetCodeAction(this.email);
}

class RequestResetCodeSuccessAction {}

class RequestResetCodeFailureAction {
  final String error;
  RequestResetCodeFailureAction(this.error);
}

class VerifyResetCodeAction {
  final String email;
  final String code;
  VerifyResetCodeAction({required this.email, required this.code});
}

class VerifyResetCodeSuccessAction {}

class VerifyResetCodeFailureAction {
  final String error;
  VerifyResetCodeFailureAction(this.error);
}

class ResetPasswordAction {
  final String email;
  final String code;
  final String newPassword;
  ResetPasswordAction({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

class ResetPasswordSuccessAction {}

class ResetPasswordFailureAction {
  final String error;
  ResetPasswordFailureAction(this.error);
}
