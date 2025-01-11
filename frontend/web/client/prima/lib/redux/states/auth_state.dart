class AuthState {
  final bool isAuthenticated;
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;
  final String? tempEmail;
  final String? tempPassword;
  final bool? resetPasswordSuccess;
  final int? resetPasswordStep;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
    this.tempEmail,
    this.tempPassword,
    this.resetPasswordSuccess = false,
    this.resetPasswordStep = 0,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    String? tempEmail,
    String? tempPassword,
    bool? resetPasswordSuccess,
    int? resetPasswordStep,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      tempEmail: tempEmail ?? this.tempEmail,
      tempPassword: tempPassword ?? this.tempPassword,
      resetPasswordSuccess: resetPasswordSuccess ?? this.resetPasswordSuccess,
      resetPasswordStep: resetPasswordStep ?? this.resetPasswordStep,
    );
  }
}
