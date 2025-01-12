class OrderResult {
  final bool isSuccess;
  final String? error;

  const OrderResult.success()
      : isSuccess = true,
        error = null;
  const OrderResult.error(String message)
      : isSuccess = false,
        error = message;

  T when<T>({
    required T Function() success,
    required T Function(String message) error,
  }) {
    if (isSuccess) {
      return success();
    } else {
      return error(error! as String);
    }
  }
}
