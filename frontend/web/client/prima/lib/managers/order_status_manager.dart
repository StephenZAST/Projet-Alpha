import 'package:prima/models/order_status.dart';

class OrderStatusManager {
  static const Map<OrderStatus, List<OrderStatus>> validTransitions = {
    OrderStatus.PENDING: [OrderStatus.COLLECTING, OrderStatus.CANCELLED],
    OrderStatus.COLLECTING: [OrderStatus.COLLECTED, OrderStatus.CANCELLED],
    OrderStatus.COLLECTED: [OrderStatus.PROCESSING, OrderStatus.CANCELLED],
    OrderStatus.PROCESSING: [OrderStatus.READY, OrderStatus.CANCELLED],
    OrderStatus.READY: [OrderStatus.DELIVERING, OrderStatus.CANCELLED],
    OrderStatus.DELIVERING: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
    OrderStatus.DELIVERED: [],
    OrderStatus.CANCELLED: [],
  };

  static bool canTransitionTo(OrderStatus current, OrderStatus next) {
    return validTransitions[current]?.contains(next) ?? false;
  }

  static List<OrderStatus> getNextPossibleStatuses(OrderStatus current) {
    return validTransitions[current] ?? [];
  }
}
