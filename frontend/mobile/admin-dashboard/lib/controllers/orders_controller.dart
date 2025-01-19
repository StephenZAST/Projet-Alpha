import 'package:get/get.dart';
import '../models/order.dart';

class OrdersController extends GetxController {
  final orders = <Order>[].obs;
  final selectedStatus = Rxn<OrderStatus>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void updateStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      // TODO: Implement API call
      orders.value = demoOrders; // Replace with actual API response
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  List<Order> get filteredOrders {
    if (selectedStatus.value == null) return orders;
    return orders
        .where((order) => order.status == selectedStatus.value.toString())
        .toList();
  }

  int getOrderCountByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status.toString()).length;
  }

  double getOrderPercentageByStatus(OrderStatus status) {
    if (orders.isEmpty) return 0;
    return getOrderCountByStatus(status) / orders.length * 100;
  }
}
