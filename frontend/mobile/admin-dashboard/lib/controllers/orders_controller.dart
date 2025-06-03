import 'package:admin/models/article.dart';
import 'package:admin/models/flash_order_update.dart' as flash_update;
import 'package:admin/models/user.dart';
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
  final ApiService _apiService = Get.find<ApiService>();

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

  // Ajouter cette propriété pour le filtre de type de commande
  final selectedOrderType = Rxn<bool>();

  // Ajouter les propriétés pour les filtres avancés
  final filterStatus = ''.obs;
  final filterStartDate = Rx<DateTime?>(null);
  final filterEndDate = Rx<DateTime?>(null);

  // État de pagination
  final currentPage = 1.obs;
  final itemsPerPage = 50.obs;
  final totalPages = 0.obs;

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

  // Nouvelles propriétés pour la recherche de clients
  final isLoadingClients = false.obs;
  final filteredClients = <User>[].obs;
  final clientSearchFilter = 'name'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDraftOrders(); // Ajout de cet appel explicite
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      // Construction des paramètres de requête
      final queryParams = <String, dynamic>{};
      if (filterStatus.value.isNotEmpty) {
        queryParams['status'] = filterStatus.value;
      }
      if (filterStartDate.value != null) {
        queryParams['startDate'] = filterStartDate.value!.toIso8601String();
      }
      if (filterEndDate.value != null) {
        queryParams['endDate'] = filterEndDate.value!.toIso8601String();
      }

      final response =
          await _apiService.get('/api/orders', queryParameters: queryParams);

      orders.value = (response.data['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    currentPage.value = 1; // Réinitialiser la page
    fetchOrders();
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

  void setItemsPerPage(int value) {
    if (value != itemsPerPage.value) {
      itemsPerPage.value = value;
      currentPage.value = 1;
      fetchOrders();
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
    filterStatus.value = '';
    filterStartDate.value = null;
    filterEndDate.value = null;
    fetchOrders();
  }

  Future<void> applyFilters() async {
    await fetchOrders();
  }

  // Méthode pour rechercher des clients
  void searchClients(String query) {
    try {
      isLoadingClients.value = true;
      if (query.isEmpty) {
        filteredClients.clear();
        return;
      }

      final normalizedQuery = query.toLowerCase();
      filteredClients.value = clients.where((client) {
        switch (clientSearchFilter.value) {
          case 'name':
            return '${client.firstName} ${client.lastName}'
                .toLowerCase()
                .contains(normalizedQuery);
          case 'email':
            return client.email.toLowerCase().contains(normalizedQuery);
          case 'phone':
            return (client.phone ?? '').toLowerCase().contains(normalizedQuery);
          default:
            return false;
        }
      }).toList();
    } catch (e) {
      print('[OrdersController] Error searching clients: $e');
    } finally {
      isLoadingClients.value = false;
    }
  }

  // Méthode pour définir le filtre de recherche
  void setClientSearchFilter(String filter) {
    clientSearchFilter.value = filter;
    if (searchQuery.value.isNotEmpty) {
      searchClients(searchQuery.value);
    }
  }

  Future<void> createClient(Map<String, dynamic> clientData) async {
    try {
      isLoadingClients.value = true;
      
      // Créer le client via UserService
      final user = await UserService.createUser({
        ...clientData,
        'role': 'CLIENT', // Définir le rôle comme CLIENT
      });
      
      // Ajouter le nouveau client à la liste
      clients.add(user);
      
      // Fermer le dialogue
      Get.back();
      
      // Afficher un message de succès
      Get.snackbar(
        'Succès',
        'Client créé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
      
      // Sélectionner automatiquement le nouveau client
      selectClient(user.id);
      
    } catch (e) {
      print('[OrdersController] Error creating client: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer le client',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoadingClients.value = false;
    }
  }
}
