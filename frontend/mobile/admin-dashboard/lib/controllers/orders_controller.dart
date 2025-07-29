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
  // Formulaire d'édition pour l'adresse de commande (clé = champ, valeur = valeur éditée)
  final orderAddressEditForm = <String, dynamic>{}.obs;
  // Champ de recherche par ID
  final orderIdSearch = ''.obs;

  void setOrderAddressEditField(String key, dynamic value) {
    orderAddressEditForm[key] = value;
  }

  void loadOrderAddressEditForm(Address address) {
    orderAddressEditForm['id'] = address.id;
    orderAddressEditForm['name'] = address.name ?? '';
    orderAddressEditForm['street'] = address.street;
    orderAddressEditForm['city'] = address.city;
    orderAddressEditForm['postalCode'] = address.postalCode ?? '';
    orderAddressEditForm['gpsLatitude'] = address.gpsLatitude;
    orderAddressEditForm['gpsLongitude'] = address.gpsLongitude;
    orderAddressEditForm['userId'] = address.userId;
  }

  void clearOrderAddressEditForm() {
    orderAddressEditForm.clear();
  }

  // Formulaire d'édition pour le détail de commande (clé = champ, valeur = valeur éditée)
  final orderEditForm = <String, dynamic>{}.obs;

  void setOrderEditField(String key, dynamic value) {
    orderEditForm[key] = value;
  }

  void loadOrderEditForm(Order order) {
    orderEditForm['totalAmount'] = order.totalAmount.toString();
    orderEditForm['affiliateCode'] = order.affiliateCode ?? '';
    orderEditForm['status'] = order.status;
    orderEditForm['paymentMethod'] = order.paymentMethod.name;
    orderEditForm['collectionDate'] = order.collectionDate;
    orderEditForm['deliveryDate'] = order.deliveryDate;
    // Ajoute d'autres champs si besoin
  }

  void clearOrderEditForm() {
    orderEditForm.clear();
  }

  // Filtres avancés supplémentaires
  final affiliateCode = ''.obs;
  final selectedRecurrenceType = RxnString();
  final recurrenceTypes = <String>["NONE", "WEEKLY", "BIWEEKLY", "MONTHLY"].obs;
  final collectionDateStartController = TextEditingController();
  final collectionDateEndController = TextEditingController();
  final deliveryDateStartController = TextEditingController();
  final deliveryDateEndController = TextEditingController();
  final city = ''.obs;
  final postalCode = ''.obs;
  final isRecurring = false.obs;

  Future<void> pickCollectionDateStart(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      collectionDateStartController.text =
          picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> pickCollectionDateEnd(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      collectionDateEndController.text =
          picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> pickDeliveryDateStart(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      deliveryDateStartController.text =
          picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> pickDeliveryDateEnd(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      deliveryDateEndController.text =
          picked.toIso8601String().substring(0, 10);
    }
  }

  // Filtres avancés pour la recherche
  final serviceTypes = <Service>[].obs;
  final selectedServiceType = RxnString();

  final paymentMethods = <String>[].obs;
  final selectedPaymentMethod = RxnString();
  final isFlashOrderFilter =
      false.obs; // Switch pour le filtre 'Commande flash'
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final minAmount = ''.obs;
  final maxAmount = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
    loadDraftOrders();
    loadServiceTypes();
    loadPaymentMethods();
    loadOrdersPage();
  }

  void loadServiceTypes() {
    // À adapter selon la source réelle des services
    final now = DateTime.now();
    serviceTypes.value = [
      Service(
          id: 'all',
          name: 'Tous',
          description: '',
          price: 0,
          createdAt: now,
          updatedAt: now),
      Service(
          id: 'standard',
          name: 'Standard',
          description: '',
          price: 0,
          createdAt: now,
          updatedAt: now),
      Service(
          id: 'flash',
          name: 'Flash',
          description: '',
          price: 0,
          createdAt: now,
          updatedAt: now),
      // Ajouter les vrais services ici
    ];
  }

  void loadPaymentMethods() {
    // Doit correspondre exactement aux valeurs enum du backend (Prisma)
    paymentMethods.value = [
      'CASH',
      'ORANGE_MONEY',
    ];
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      startDateController.text = picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      endDateController.text = picked.toIso8601String().substring(0, 10);
    }
  }

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
  // Suppression de la version Rxn<bool> (doublon)

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

  // Ajouter cette propriété pour l'étape courante
  final currentStep = 0.obs;

  Future<void> fetchOrders() async {
    await loadOrdersPage(status: filterStatus.value);
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
    filterStatus.value = status?.name ?? '';
    currentPage.value = 1; // Réinitialiser la page
    fetchOrders();
  }

  // Ajouter cette méthode pour filtrer par type de commande
  void filterByFlashOrder(bool value) {
    isFlashOrderFilter.value = value;
    currentPage.value = 1;
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
      loadOrdersPage(page: currentPage.value, status: filterStatus.value);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadOrdersPage(page: currentPage.value, status: filterStatus.value);
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      final isFlash = await OrderService.isFlashOrder(orderId);
      if (isFlash && !_isValidFlashTransition(newStatus)) {
        throw 'Transition non autorisée pour une commande flash';
      }
      await OrderService.updateOrderStatus(orderId, newStatus.name);
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(orderId);
      _showSuccessSnackbar('Statut de la commande mis à jour');
    } catch (e) {
      print('[OrdersController] Error updating order status: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour du statut : $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
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
      loadOrdersPage(page: 1, status: filterStatus.value, limit: value);
    }
  }

  void clearFilters() {
    selectedStatus.value = null;
    isFlashOrderFilter.value = false;
    searchQuery.value = '';
    currentPage.value = 1;
    itemsPerPage.value = 50;
    fetchOrders();
  }

  // Méthodes pour la création/édition de commande
  Future<void> loadClients() async {
    try {
      isLoadingClients.value = true;
      final result = await UserService.getClients();
      clients.value = result;
      print('[OrdersController] Loaded ${result.length} clients');
    } catch (e) {
      print('[OrdersController] Error loading clients: $e');
    } finally {
      isLoadingClients.value = false;
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
      hasError.value = false;
      errorMessage.value = '';
      final result = await OrderService.createOrder(orderData);
      Get.back();
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(result.id);
      _showSuccessSnackbar('Commande créée avec succès');
    } catch (e) {
      print('[OrdersController] Error creating order: $e');
      hasError.value = true;
      errorMessage.value = 'Impossible de créer la commande : $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      // S'assurer que le champ affiliateCode est bien transmis
      if (orderEditForm.containsKey('affiliateCode')) {
        orderData['affiliateCode'] = orderEditForm['affiliateCode'];
      }
      await OrderService.updateOrder(orderId, orderData);
      Get.back();
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(orderId);
      _showSuccessSnackbar('Commande mise à jour avec succès');
    } catch (e) {
      print('[OrdersController] Error updating order: $e');
      hasError.value = true;
      // Gestion d'erreur pour le code affilié
      if (e.toString().contains('affiliate')) {
        errorMessage.value = 'Erreur sur le code affilié : $e';
      } else {
        errorMessage.value =
            e is String ? e : 'Impossible de mettre à jour la commande : $e';
      }
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Ajout : méthode pour mettre à jour l'adresse d'une commande
  Future<void> updateOrderAddress(
      String orderId, Map<String, dynamic> addressData) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      // Correction : toujours envoyer {"addressId": ...} au backend
      final patchData = {
        'addressId': addressData['id'] ?? addressData['addressId'],
      };
      await OrderService.updateOrderAddress(orderId, patchData);
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(orderId);
      _showSuccessSnackbar('Adresse de la commande mise à jour');
    } catch (e) {
      print('[OrdersController] Error updating order address: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la mise à jour de l\'adresse : $e';
      _showErrorSnackbar(errorMessage.value);
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
      hasError.value = false;
      errorMessage.value = '';
      final orderId = selectedFlashOrder.value!.id;
      final updateData = flash_update.FlashOrderUpdate(
        serviceId: selectedService.value!.id,
        items: selectedArticles.toList(),
        collectionDate: collectionDate.value,
        deliveryDate: deliveryDate.value,
      );
      await OrderService.completeFlashOrder(orderId, updateData);
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(orderId);
      _showSuccessSnackbar('Commande flash mise à jour');
    } catch (e) {
      print('[OrdersController] Error updating flash order: $e');
      hasError.value = true;
      errorMessage.value =
          'Erreur lors de la mise à jour de la commande flash : $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
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
    String? serviceTypeId,
    String? paymentMethod,
    String? startDate,
    String? endDate,
    String? minAmount,
    String? maxAmount,
    bool? isFlashOrder,
    String? searchTerm,
    String sortField = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      final result = await OrderService.loadOrdersPage(
        page: page ?? currentPage.value,
        limit: limit ?? itemsPerPage.value,
        status: status,
        serviceTypeId: serviceTypeId,
        paymentMethod: paymentMethod,
        startDate: startDate,
        endDate: endDate,
        minAmount: minAmount,
        maxAmount: maxAmount,
        isFlashOrder: isFlashOrder,
        searchTerm: searchTerm,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      orders.value = result.orders;
      totalOrders.value = result.total;
      totalPages.value = result.totalPages;
    } catch (e) {
      print('[OrdersController] Error loading orders page: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des commandes : $e';
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
    // Construction des paramètres avancés
    final params = {
      'searchTerm': searchQuery.value,
      'serviceTypeId':
          selectedServiceType.value == 'all' ? null : selectedServiceType.value,
      'paymentMethod': selectedPaymentMethod.value == 'all'
          ? null
          : selectedPaymentMethod.value,
      'status': filterStatus.value,
      'startDate':
          startDateController.text.isNotEmpty ? startDateController.text : null,
      'endDate':
          endDateController.text.isNotEmpty ? endDateController.text : null,
      'minAmount': minAmount.value.isNotEmpty ? minAmount.value : null,
      'maxAmount': maxAmount.value.isNotEmpty ? maxAmount.value : null,
      'isFlashOrder': isFlashOrderFilter.value ? true : null,
    };
    await loadOrdersPage(
      status: params['status'] as String?,
      serviceTypeId: params['serviceTypeId'] as String?,
      paymentMethod: params['paymentMethod'] as String?,
      startDate: params['startDate'] as String?,
      endDate: params['endDate'] as String?,
      minAmount: params['minAmount'] as String?,
      maxAmount: params['maxAmount'] as String?,
      isFlashOrder: params['isFlashOrder'] as bool?,
      searchTerm: params['searchTerm'] as String?,
    );
  }

  // Méthode pour rechercher des clients
  void searchClients(String query, String filter) async {
    try {
      isLoadingClients.value = true;

      if (filter == 'all') {
        await loadClients();
        return;
      }

      // Si la requête est vide, afficher tous les clients
      if (query.isEmpty) {
        filteredClients.value = clients;
        return;
      }

      // Appeler le backend pour la recherche
      final response = await UserService.searchUsers(
        query: query,
        filter: filter,
      );

      if (response.items.isNotEmpty) {
        filteredClients.value = response.items;
      } else {
        Get.snackbar(
          'Erreur',
          'Aucun client trouvé',
          backgroundColor: AppColors.error,
          colorText: AppColors.textLight,
        );
      }
    } catch (e) {
      print('[OrdersController] Error searching clients: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la recherche des clients',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoadingClients.value = false;
    }
  }

  // Méthode pour définir le filtre de recherche
  void setClientSearchFilter(String filter) {
    clientSearchFilter.value = filter;
    if (searchQuery.value.isNotEmpty) {
      searchClients(searchQuery.value, clientSearchFilter.value);
    }
  }

  Future<User?> createClient(Map<String, dynamic> clientData) async {
    try {
      isLoadingClients.value = true;

      // Générer un mot de passe aléatoire temporaire
      final tempPassword =
          '${DateTime.now().millisecondsSinceEpoch}'.substring(0, 8);

      // Ajouter le mot de passe aux données client
      final userData = {
        ...clientData,
        'password': tempPassword, // Ajouter le mot de passe
        'role': 'CLIENT',
      };

      // Créer le client via UserService
      final user = await UserService.createUser(userData);

      // Ajouter le nouveau client à la liste
      clients.add(user);
      Get.back();

      Get.snackbar(
        'Succès',
        'Client créé avec succès\nMot de passe temporaire: $tempPassword',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
        duration: Duration(seconds: 10),
      );

      // Sélectionner automatiquement le nouveau client
      selectClient(user.id);
      return user;
    } catch (e) {
      print('[OrdersController] Error creating client: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer le client',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
      return null;
    } finally {
      isLoadingClients.value = false;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.90),
      borderRadius: 16,
      margin: AppSpacing.marginMD,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}
