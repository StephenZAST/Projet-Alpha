import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../services/order_service.dart';
import '../constants.dart';

class OrdersController extends GetxController {
  // État de chargement et erreurs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Données des commandes
  final orders = <Order>[].obs;
  final selectedOrder = Rxn<Order>();
  final totalOrders = 0.obs;
  final totalAmount = 0.0.obs;
  final orderStatusCount = <String, int>{}.obs;

  // Filtres et recherche
  final selectedStatus = Rxn<OrderStatus>();
  final searchQuery = ''.obs;

  // État de pagination
  final currentPage = 1.obs;
  final itemsPerPage = 50.obs;
  final totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (resetPage) {
        currentPage.value = 1;
      }

      final result = await OrderService.loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: selectedStatus.value?.name,
      );

      orders.value = result.orders;
      totalOrders.value = result.total;
      totalPages.value = result.totalPages;

      // Calculer le montant total
      totalAmount.value =
          result.orders.fold(0, (sum, order) => sum + (order.totalAmount ?? 0));

      // Mettre à jour les compteurs par statut
      await _updateStatusCounts();
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
    fetchOrders(resetPage: true);
  }

  Future<void> _updateStatusCounts() async {
    try {
      final allOrders = await OrderService.getOrders();
      final statusCount = <String, int>{};
      for (var order in allOrders) {
        final status = order.status;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
      orderStatusCount.value = statusCount;
    } catch (e) {
      print('[OrdersController] Error updating status counts: $e');
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchOrders();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchOrders();
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    fetchOrders(resetPage: true);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Trouver la commande actuelle
      final order = orders.firstWhereOrNull((o) => o.id == orderId);
      if (order == null) {
        throw 'Commande non trouvée';
      }

      // Vérifier si la transition est valide
      if (!OrderService.isValidTransition(order.status, newStatus.name)) {
        throw 'La transition de "${order.status}" à "${newStatus.name}" n\'est pas autorisée';
      }

      // Mettre à jour le statut
      await OrderService.updateOrderStatus(orderId, newStatus.name);

      // Attendre un court instant pour la synchronisation
      await Future.delayed(Duration(milliseconds: 500));

      // Rafraîchir les données
      await fetchOrders();

      // Notification de succès
      Get.snackbar(
        'Succès',
        'La commande est maintenant ${newStatus.label.toLowerCase()}',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('[OrdersController] Error updating order status: $e');
      hasError.value = true;

      // Analyser l'erreur pour un message approprié
      String errorTitle = 'Erreur';
      String errorMsg = e.toString();

      if (errorMsg.contains('Session expirée')) {
        errorTitle = 'Session expirée';
        errorMsg = 'Veuillez vous reconnecter pour continuer';
      } else if (errorMsg.contains('permissions')) {
        errorTitle = 'Accès refusé';
      } else if (errorMsg.contains('transition')) {
        errorTitle = 'Action non autorisée';
      } else if (errorMsg.contains('commande non trouvée')) {
        errorTitle = 'Erreur de données';
      }

      errorMessage.value = errorMsg;
      Get.snackbar(
        errorTitle,
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setItemsPerPage(int value) {
    if (value > 0) {
      itemsPerPage.value = value;
      fetchOrders(resetPage: true);
    }
  }

  void clearFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    currentPage.value = 1;
    itemsPerPage.value = 50;
    fetchOrders(resetPage: true);
  }
}
