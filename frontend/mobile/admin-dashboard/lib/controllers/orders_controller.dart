import 'dart:developer';

import 'package:admin/models/article.dart';
import 'package:admin/models/user.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../models/user.dart';
import '../models/article.dart';
import '../models/service.dart';
import '../models/address.dart';
import '../services/order_service.dart';
import '../services/user_service.dart';
import '../services/pricing_service.dart';
import '../services/service_service.dart';
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

  // Ajouter cette propriété pour les commandes en brouillon
  final draftOrders = <Order>[].obs;

  // État pour la création/modification de commande
  final clients = <User>[].obs;
  final selectedClientId = RxnString();
  final clientAddresses = <Address>[].obs;
  final selectedAddressId = RxnString();
  final articles = <Article>[].obs;
  final selectedItems = <Map<String, dynamic>>[].obs;
  final services = <Service>[].obs;
  final selectedServiceId = RxnString();
  final orderTotal = 0.0.obs;

  // État du formulaire de commande
  final isEditMode = false.obs;
  final currentOrderId = RxnString();

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
    loadDraftOrders(); // Charger aussi les brouillons
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

  // Méthodes pour la création/édition de commande
  Future<void> loadClients() async {
    try {
      final result = await UserService.getClients();
      clients.value = result;
    } catch (e) {
      print('[OrdersController] Error loading clients: $e');
      throw 'Erreur lors du chargement des clients';
    }
  }

  Future<void> loadArticles() async {
    try {
      final result = await PricingService.getAllArticles();
      articles.value = result;
    } catch (e) {
      print('[OrdersController] Error loading articles: $e');
      throw 'Erreur lors du chargement des articles';
    }
  }

  Future<void> loadServices() async {
    try {
      final result = await ServiceService.getAllServices();
      services.value = result;
    } catch (e) {
      print('[OrdersController] Error loading services: $e');
      throw 'Erreur lors du chargement des services';
    }
  }

  void selectClient(String clientId) {
    selectedClientId.value = clientId;
    loadClientAddresses(clientId);
  }

  Future<void> loadClientAddresses(String clientId) async {
    try {
      final result = await UserService.getUserAddresses(clientId);
      clientAddresses.value = result;
      if (result.isNotEmpty) {
        final defaultAddress = result.firstWhereOrNull((a) => a.isDefault);
        selectedAddressId.value = defaultAddress?.id ?? result.first.id;
      }
    } catch (e) {
      print('[OrdersController] Error loading client addresses: $e');
      throw 'Erreur lors du chargement des adresses';
    }
  }

  void selectAddress(String addressId) {
    selectedAddressId.value = addressId;
  }

  void addItem(String articleId) {
    final article = articles.firstWhere((a) => a.id == articleId);
    selectedItems.add({
      'articleId': articleId,
      'quantity': 1,
      'isPremium': false,
      'price': article.basePrice,
    });
    _calculateTotal();
  }

  void updateItemPrice(int index, bool isPremium) {
    final item = selectedItems[index];
    final article = articles.firstWhere((a) => a.id == item['articleId']);
    item['isPremium'] = isPremium;
    item['price'] = isPremium ? article.premiumPrice : article.basePrice;
    selectedItems[index] = item;
    _calculateTotal();
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    _calculateTotal();
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in selectedItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    orderTotal.value = total;
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      isLoading.value = true;
      final result = await OrderService.createOrder(orderData);
      Get.back();
      fetchOrders();
      Get.snackbar(
        'Succès',
        'Commande créée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
    } catch (e) {
      print('[OrdersController] Error creating order: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer la commande',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      isLoading.value = true;
      await OrderService.updateOrder(orderId, orderData);
      Get.back();
      fetchOrders();
      Get.snackbar(
        'Succès',
        'Commande mise à jour avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
    } catch (e) {
      print('[OrdersController] Error updating order: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la commande',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDraftOrders() async {
    try {
      isLoading.value = true;
      final drafts = await OrderService.getDraftOrders();
      draftOrders.value = drafts;
    } catch (e) {
      print('[OrdersController] Error loading draft orders: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
