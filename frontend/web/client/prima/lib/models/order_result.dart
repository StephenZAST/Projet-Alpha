import 'package:prima/models/order.dart';

class OrderResult {
  final bool isSuccess;
  final String? error;
  final Order? data; // Ajout d'un champ data pour contenir l'ordre créé

  const OrderResult.success(Order order)
      : isSuccess = true,
        error = null,
        data = order;

  const OrderResult.error(String message)
      : isSuccess = false,
        error = message,
        data = null;

  T when<T>({
    required T Function(Order order) success,
    required T Function(String message) error,
  }) {
    if (isSuccess && data != null) {
      return success(data!);
    } else {
      return error(this.error ?? "Unknown error");
    }
  }
}
