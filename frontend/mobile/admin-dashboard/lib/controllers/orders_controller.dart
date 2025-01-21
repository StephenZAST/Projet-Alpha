import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrdersController extends GetxController {
  final orders = <Order>[].obs;
  final isLoading = false.obs;
  final selectedStatus = Rxn<String>();
  final searchQuery = ''.obs;
  final ordersByStatus = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchOrdersByStatus();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final data = await OrderService.getRecentOrders();
      orders.value = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrdersByStatus() async {
    try {
      final data = await OrderService.getOrdersByStatus();
      ordersByStatus.value = data;
    } catch (e) {
      print('Error fetching orders by status: $e');
    }
  }

  int getOrderCountByStatus(String status) {
    return ordersByStatus[status] ?? 0;
  }

  double getOrderPercentageByStatus(String status) {
    final total = ordersByStatus.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return 0;
    return ((ordersByStatus[status] ?? 0) / total) * 100;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      isLoading.value = true;
      await OrderService.updateOrderStatus(orderId, status);
      await fetchOrders(); // Rafraîchir la liste
      Get.snackbar('Success', 'Order status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status;
    fetchOrders();
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    // Implémentez la logique de recherche si nécessaire
  }
}
