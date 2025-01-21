import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/export_service.dart';

enum ExportType { PDF, EXCEL }

class OrdersController extends GetxController {
  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final selectedStatus = Rxn<OrderStatus>();
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await OrderService.getOrders(
        status: selectedStatus.value?.toString(),
      );
      orders.value = response;
      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Order>.from(orders);

    // Apply status filter
    if (selectedStatus.value != null) {
      filtered = filtered
          .where((order) => order.status == selectedStatus.value)
          .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((order) =>
              order.id
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              order.customerName
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredOrders.value = filtered;
  }

  void updateStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await OrderService.updateOrderStatus(orderId, newStatus.toString());
      await fetchOrders();
      Get.snackbar('Success', 'Order status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }

  Future<void> exportOrders(ExportType type) async {
    try {
      isLoading.value = true;
      final data = filteredOrders.map((order) => order.toJson()).toList();

      switch (type) {
        case ExportType.PDF:
          await ExportService.generatePDF(data, 'orders');
          break;
        case ExportType.EXCEL:
          await ExportService.generateExcel(data, 'orders');
          break;
      }

      Get.snackbar('Success', 'Orders exported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to export orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<OrderStatus, int> getOrderStatusCount() {
    final statusCount = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      statusCount[status] =
          orders.where((order) => order.status == status).length;
    }
    return statusCount;
  }

  double getOrderPercentageByStatus(OrderStatus status) {
    if (orders.isEmpty) return 0;
    return getOrderCountByStatus(status) / orders.length * 100;
  }

  int getOrderCountByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }

  double getTotalRevenue() {
    return orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }
}
