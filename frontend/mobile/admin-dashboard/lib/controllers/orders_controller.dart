import 'package:admin/models/article.dart';
import 'package:admin/models/flash_order_update.dart' as flash_update;
import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/address.dart';
import '../services/order_service.dart';
import '../services/user_service.dart';
import '../services/pricing_service.dart';
import '../services/service_service.dart';
import '../services/api_service.dart';
import '../constants.dart';

class OrdersController extends GetxController {
  late final ApiService _apiService;

  OrdersController() {
    _apiService = Get.find<ApiService>();
  }

  // État de chargement et erreurs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Données des commandes
  final orders = <Order>[].obs;
  final selectedOrder = Rxn<Order>();
  final totalOrders = 0.obs;
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

  // Ajouter cette propriété pour le filtre de type de commande
  final selectedOrderType = Rxn<bool>();

  // Ajouter les propriétés pour les filtres avancés
  final filterStatus = ''.obs;
  final filterStartDate = Rx<DateTime?>(null);
  final filterEndDate = Rx<DateTime?>(null);

  // État de pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;
  final totalPages = 1.obs;

  // État spécifique aux commandes flash
  final selectedFlashOrder = Rxn<Order>();
  final selectedArticles = <flash_update.FlashOrderItem>[]
      .obs; // Utiliser la version du modèle flash_order_update
  final selectedService = Rxn<Service>();
  final collectionDate = Rxn<DateTime>();
  final deliveryDate = Rxn<DateTime>();

  // Ajouter cette propriété pour gérer les changements non sauvegardés
  bool get hasUnsavedChanges {
    if (selectedFlashOrder.value == null) return false;

    return selectedService.value != null ||
        selectedArticles.isNotEmpty ||
        collectionDate.value != null ||
        deliveryDate.value != null;
  }

  // Ajouter ces propriétés pour le tri
  final sortColumnIndex = 0.obs;
  final sortAscending = true.obs;

  // Ajout des variables pour la recherche avancée
  final advancedSearchEnabled = false.obs;
  final dateRange = Rx<DateTimeRange?>(null);
  final selectedPaymentMethod = Rx<PaymentMethod?>(null);
  final selectedPrice = RxDouble(0.0);
  final priceRange = RxList<double>([0, 1000]);
  final selectedDateFilter = RxString('all'); // today, week, month, custom

  // Nouveaux filtres de recherche
  final orderId = RxString('');
  final customerName = RxString('');
  final customerContact = RxString('');
  final serviceType = RxString('');
  final minAmount = RxDouble(0.0);
  final maxAmount = RxDouble(0.0);
  final address = RxString('');
  final paymentStatus = Rx<bool?>(null);

  void setOrderId(String value) => orderId.value = value;
  void setCustomerName(String value) => customerName.value = value;
  void setCustomerContact(String value) => customerContact.value = value;
  void setServiceType(String value) => serviceType.value = value;
  void setMinAmount(double value) => minAmount.value = value;
  void setMaxAmount(double value) => maxAmount.value = value;
  void setAddress(String value) => address.value = value;
  void setPaymentStatus(bool? value) => paymentStatus.value = value;

  @override
  void onInit() {
    super.onInit();
    loadDraftOrders(); // Ajout de cet appel explicite
    fetchOrders();
  }

  Future<void> fetchOrders({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (resetPage) {
        currentPage.value = 1;
      }

      final params = {
        'page': currentPage.value.toString(),
        'limit': itemsPerPage.value.toString(),
        'status': selectedStatus.value?.name,
        'search': searchQuery.value,
        'orderType': selectedOrderType.value?.toString(),
      };

      print('[OrdersController] Fetching orders with params: $params');

      final response =
          await _apiService.get('/orders', queryParameters: params);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Extraire les données de pagination
        final pagination = data['pagination'] as Map<String, dynamic>;
        totalOrders.value = pagination['total'] ?? 0;
        totalPages.value = pagination['totalPages'] ?? 1;
        currentPage.value = pagination['currentPage'] ?? 1;

        // Mettre à jour la liste des commandes
        final List ordersData = data['data'] as List;
        orders.value = ordersData.map((json) => Order.fromJson(json)).toList();

        print('[OrdersController] Pagination info:');
        print('- Total orders: ${totalOrders.value}');
        print('- Current page: ${currentPage.value}');
        print('- Items per page: ${itemsPerPage.value}');
        print('- Total pages: ${totalPages.value}');
        print('- Orders in current page: ${orders.length}');
      }
    } catch (e) {
      print('[OrdersController] Error fetching orders: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes';
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      print('[OrdersController] Moving to next page: ${currentPage.value + 1}');
      currentPage.value++;
      fetchOrders();
    } else {
      print(
          '[OrdersController] Already at last page (${currentPage.value}/${totalPages.value})');
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      print(
          '[OrdersController] Moving to previous page: ${currentPage.value - 1}');
      currentPage.value--;
      fetchOrders();
    } else {
      print('[OrdersController] Already at first page');
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
  Future<void> filterByStatus(OrderStatus? status) async {
    try {
      selectedStatus.value = status;
      currentPage.value = 1; // Reset to first page when filtering
      await fetchOrders();
    } catch (e) {
      print('[OrdersController] Error filtering by status: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du filtrage des commandes';
    }
  }

  // Ajouter cette méthode pour filtrer par type de commande
  void filterByType(bool? isFlash) {
    selectedOrderType.value = isFlash;
    fetchOrders();
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

  void goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      print('[OrdersController] Going to page: $page');
      currentPage.value = page;
      await fetchOrders();
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      final isFlash = await OrderService.isFlashOrder(orderId);

      // Vérifier si c'est une commande flash
      if (isFlash && !_isValidFlashTransition(newStatus)) {
        throw 'Transition non autorisée pour une commande flash';
      }

      await OrderService.updateOrderStatus(orderId, newStatus.name);
      await fetchOrders();
    } catch (e) {
      // ...error handling...
    }
  }

  bool _isValidFlashTransition(OrderStatus newStatus) {
    switch (newStatus) {
      case OrderStatus.PENDING:
      case OrderStatus.PROCESSING:
      case OrderStatus.DELIVERED:
      case OrderStatus.CANCELLED:
        return true;
      default:
        return false;
    }
  }

  @override
  void clearFilters() {
    selectedStatus.value = null;
    selectedOrderType.value = null;
    searchQuery.value = '';
    currentPage.value = 1;
    itemsPerPage.value = 50;
    fetchOrders();
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
      print('[OrdersController] Loaded ${drafts.length} draft orders');
      draftOrders.assignAll(drafts);
    } catch (e) {
      print('[OrdersController] Error loading draft orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFlashOrder() async {
    try {
      if (selectedFlashOrder.value == null || selectedService.value == null) {
        throw 'Informations manquantes';
      }

      isLoading.value = true;

      final orderId = selectedFlashOrder.value!.id;
      // Créer un objet FlashOrderUpdate au lieu d'un Map
      final updateData = flash_update.FlashOrderUpdate(
        serviceId: selectedService.value!.id,
        items: selectedArticles.toList(),
        collectionDate: collectionDate.value,
        deliveryDate: deliveryDate.value,
      );

      final order = await OrderService.completeFlashOrder(orderId, updateData);
      // ...rest of the method...
    } catch (e) {
      // ...error handling...
    }
  }

  Future<void> initFlashOrderUpdate(String orderId) async {
    try {
      isLoading.value = true;

      // Charger la commande flash
      final order = await OrderService.getOrderById(orderId);
      selectedFlashOrder.value = order;

      // Charger les services et articles disponibles
      await Future.wait([
        loadServices(),
        loadArticles(),
      ]);

      // Réinitialiser les sélections
      selectedService.value = null;
      selectedArticles.clear();
      collectionDate.value = null;
      deliveryDate.value = null;
    } catch (e) {
      print('Error initializing flash order update: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données nécessaires',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter cette méthode pour rafraîchir régulièrement
  Future<void> refreshDraftOrders() async {
    await loadDraftOrders();
  }

  void sortOrders({required String field, required bool ascending}) {
    sortColumnIndex.value = _getSortColumnIndex(field);
    sortAscending.value = ascending;

    // Recharger les données avec le nouveau tri
    loadOrdersPage(
      page: currentPage.value,
      limit: itemsPerPage.value,
      status: selectedStatus.value?.name,
      sortField: field,
      sortOrder: ascending ? 'asc' : 'desc',
    );
  }

  int _getSortColumnIndex(String field) {
    switch (field) {
      case 'id':
        return 0;
      case 'user.firstName':
        return 1;
      case 'created_at':
        return 2;
      // ...autres cas...
      default:
        return 0;
    }
  }

  // Mettre à jour cette méthode
  Future<void> loadOrdersPage({
    int? page,
    int? limit,
    String? status,
    String sortField = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      isLoading.value = true;
      final result = await OrderService.loadOrdersPage(
        page: page ?? currentPage.value,
        limit: limit ?? itemsPerPage.value,
        status: status,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      orders.value = result.orders;
      totalOrders.value = result.total;
      totalPages.value = result.totalPages;
    } catch (e) {
      print('[OrdersController] Error loading orders page: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Ajout des nouvelles méthodes
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  void resetFilters() {
    filterStartDate.value = null;
    filterEndDate.value = null;
    searchQuery.value = '';
    selectedStatus.value = null;
    selectedOrderType.value = null;
    currentPage.value = 1;
    fetchOrders();
  }

  Future<void> applyFilters() async {
    try {
      isLoading.value = true;

      final queryParams = {
        'page': currentPage.value.toString(),
        'limit': itemsPerPage.value.toString(),
        'status': selectedStatus.value?.name,
        'search': searchQuery.value,
        if (filterStartDate.value != null)
          'startDate': filterStartDate.value!.toIso8601String(),
        if (filterEndDate.value != null)
          'endDate': filterEndDate.value!.toIso8601String(),
        'sortField': 'createdAt',
        'sortOrder': 'desc',
      };

      final response =
          await _apiService.get('/orders', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final ordersData = data['data'] as List;
        orders.value = ordersData.map((json) => Order.fromJson(json)).toList();

        // Mise à jour de la pagination
        final pagination = data['pagination'] as Map<String, dynamic>;
        totalOrders.value = pagination['total'] ?? 0;
        totalPages.value = pagination['totalPages'] ?? 1;
        currentPage.value = pagination['currentPage'] ?? 1;
      }
    } catch (e) {
      print('Error applying filters: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de l\'application des filtres';
    } finally {
      isLoading.value = false;
    }
  }

  void updateItemsPerPage(int value) {
    if (value != itemsPerPage.value) {
      print(
          '[OrdersController] Updating items per page from ${itemsPerPage.value} to $value');
      itemsPerPage.value = value;
      currentPage.value = 1; // Reset to first page
      fetchOrders();
    }
  }

  void setItemsPerPage(int value) {
    updateItemsPerPage(value);
  }

  Future<void> applyAdvancedSearch() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;

      final queryParams = {
        'page': currentPage.value.toString(),
        'limit': itemsPerPage.value.toString(),
        if (orderId.value.isNotEmpty) 'orderId': orderId.value,
        if (customerName.value.isNotEmpty) 'customerName': customerName.value,
        if (customerContact.value.isNotEmpty)
          'customerContact': customerContact.value,
        if (serviceType.value.isNotEmpty) 'serviceType': serviceType.value,
        if (minAmount.value > 0) 'minAmount': minAmount.value.toString(),
        if (maxAmount.value > 0) 'maxAmount': maxAmount.value.toString(),
        if (address.value.isNotEmpty) 'address': address.value,
        if (paymentStatus.value != null)
          'isPaid': paymentStatus.value.toString(),
        'status': selectedStatus.value?.name,
      };

      final response =
          await _apiService.get('/orders/search', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final pagination = data['pagination'] as Map<String, dynamic>;

        orders.value =
            (data['data'] as List).map((json) => Order.fromJson(json)).toList();
        totalOrders.value = pagination['total'] ?? 0;
        totalPages.value = pagination['totalPages'] ?? 1;
      }
    } catch (e) {
      print('[OrdersController] Error in advanced search: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la recherche';
    } finally {
      isLoading.value = false;
    }
  }

  void setDateFilter(String filter) {
    selectedDateFilter.value = filter;
    final now = DateTime.now();

    switch (filter) {
      case 'today':
        dateRange.value = DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
        break;
      case 'week':
        dateRange.value = DateTimeRange(
          start: now.subtract(Duration(days: 7)),
          end: now,
        );
        break;
      case 'month':
        dateRange.value = DateTimeRange(
          start: now.subtract(Duration(days: 30)),
          end: now,
        );
        break;
      case 'all':
        dateRange.value = null;
        break;
    }

    if (filter != 'custom') {
      applyAdvancedSearch();
    }
  }

  void resetAdvancedSearch() {
    orderId.value = '';
    customerName.value = '';
    customerContact.value = '';
    serviceType.value = '';
    minAmount.value = 0.0;
    maxAmount.value = 0.0;
    address.value = '';
    paymentStatus.value = null;
    selectedStatus.value = null;
    fetchOrders(resetPage: true);
  }
}
