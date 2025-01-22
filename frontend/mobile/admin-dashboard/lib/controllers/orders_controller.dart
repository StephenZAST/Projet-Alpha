import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../services/order_service.dart';
import '../constants.dart';

class OrdersController extends GetxController {
  final isLoading = false.obs;
  final orders = <Order>[].obs;
  final selectedOrder = Rxn<Order>();
  final totalOrders = 0.obs;
  final totalAmount = 0.0.obs;
  final orderStatusCount = <String, int>{}.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final selectedStatus = Rxn<OrderStatus>();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await OrderService.getOrders();
      orders.value = result;

      // Calculer les totaux
      totalOrders.value = orders.length;
      totalAmount.value =
          orders.fold(0, (sum, order) => sum + (order.totalAmount ?? 0));

      // Compter les commandes par statut
      final statusCount = <String, int>{};
      for (var order in orders) {
        final status = order.status;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
      orderStatusCount.value = statusCount;
    } catch (e) {
      print('[OrdersController] Error fetching orders: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final order = await OrderService.getOrderById(orderId);
      selectedOrder.value = order;
    } catch (e) {
      print('[OrdersController] Error fetching order details: $e');
      hasError.value = true;
      errorMessage.value =
          'Erreur lors du chargement des détails de la commande';
    } finally {
      isLoading.value = false;
    }
  }

  // Méthodes pour les métriques et statistiques
  int getOrderCountByStatus(OrderStatus status) {
    return orderStatusCount[status.name] ?? 0;
  }

  double getOrderPercentageByStatus(OrderStatus status) {
    if (totalOrders.value == 0) return 0;
    return (getOrderCountByStatus(status) / totalOrders.value) * 100;
  }

  // Méthodes de filtrage
  void filterByStatus(OrderStatus? status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() async {
    try {
      isLoading.value = true;
      List<Order> filteredOrders = await OrderService.getOrders();

      // Appliquer le filtre de statut
      if (selectedStatus.value != null) {
        filteredOrders = filteredOrders
            .where((order) => order.status == selectedStatus.value!.name)
            .toList();
      }

      // Appliquer la recherche
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        filteredOrders = filteredOrders.where((order) {
          return order.id.toLowerCase().contains(query) ||
              (order.customerName?.toLowerCase() ?? '').contains(query) ||
              (order.customerEmail?.toLowerCase() ?? '').contains(query);
        }).toList();
      }

      orders.value = filteredOrders;
    } catch (e) {
      print('[OrdersController] Error applying filters: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du filtrage des commandes';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await OrderService.updateOrderStatus(orderId, newStatus.name);
      await fetchOrders(); // Rafraîchir la liste

      Get.snackbar(
        'Succès',
        'Statut de la commande mis à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[OrdersController] Error updating order status: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour du statut';

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut de la commande',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    fetchOrders();
  }
}
