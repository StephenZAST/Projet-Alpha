import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../services/order_service.dart';
import '../constants.dart';

/// Contrôleur pour la gestion des commandes avec pagination
///
/// Fonctionnalités :
/// - Chargement paginé des commandes
/// - Filtrage par statut
/// - Recherche textuelle
/// - Statistiques et métriques
/// - Navigation entre les pages
///
/// La pagination est gérée via :
/// - [currentPage] : Page actuelle (commence à 1)
/// - [itemsPerPage] : Nombre d'éléments par page
/// - [totalPages] : Nombre total de pages disponibles
///
/// Utilisez [nextPage] et [previousPage] pour naviguer entre les pages,
/// ou [setItemsPerPage] pour modifier le nombre d'éléments par page.
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
  /// Filtre les commandes par statut et réinitialise la pagination
  void filterByStatus(OrderStatus? status) {
    selectedStatus.value = status;
    fetchOrders(resetPage: true);
  }

  /// Met à jour les compteurs de statuts des commandes
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

  /// Navigue à la page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchOrders();
    }
  }

  /// Navigue à la page précédente
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

  void _applyFilters() async {
    try {
      isLoading.value = true;

      // Réinitialiser la pagination
      currentPage.value = 1;

      // Charger les commandes filtrées avec pagination
      final result = await OrderService.loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: selectedStatus.value?.name,
      );

      orders.value = result.orders;
      totalOrders.value = result.total;
      totalPages.value = result.totalPages;
    } catch (e) {
      print('[OrdersController] Error applying filters: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du filtrage des commandes';
    } finally {
      isLoading.value = false;
    }
  }

  /// Change le nombre d'éléments par page
  void setItemsPerPage(int value) {
    if (value > 0) {
      itemsPerPage.value = value;
      fetchOrders(resetPage: true);
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

  /// Réinitialise tous les filtres et la pagination
  void clearFilters() {
    // Réinitialiser les filtres
    selectedStatus.value = null;
    searchQuery.value = '';

    // Réinitialiser la pagination
    currentPage.value = 1;
    itemsPerPage.value = 50; // Valeur par défaut

    // Recharger les données
    fetchOrders(resetPage: true);
  }
}
