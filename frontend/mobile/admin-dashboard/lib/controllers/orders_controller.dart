import '../models/order_draft.dart';
import 'package:admin/models/article.dart';
import 'package:admin/models/flash_order_update.dart' as flash_update;
import 'package:admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/service_type.dart';
import '../models/address.dart';
import '../services/order_service.dart';
import '../services/user_service.dart';
import '../services/pricing_service.dart';
import '../services/service_service.dart';
import '../constants.dart';

class OrdersController extends GetxController {
  /// Détail local des articles sélectionnés (pour l'affichage du récap)
  /// Chaque entrée contient :
  /// {
  ///   'articleId': String,
  ///   'articleName': String,
  ///   'articleDescription': String?,
  ///   'basePrice': double,
  ///   'premiumPrice': double?,
  ///   'quantity': int,
  ///   'isPremium': bool,
  ///   'serviceId': String?,
  ///   'serviceName': String?,
  ///   'serviceTypeId': String?,
  ///   'serviceTypeName': String?,
  ///   'serviceTypePricing': String?,
  ///   'weight': double?,
  /// }
  final selectedArticleDetails = <Map<String, dynamic>>[].obs;

  /// Ajoute ou met à jour un article dans le cache local des détails sélectionnés
  void addOrUpdateArticleDetail({
    required String articleId,
    required String articleName,
    String? articleDescription,
    required double basePrice,
    double? premiumPrice,
    required int quantity,
    required bool isPremium,
    String? serviceId,
    String? serviceName,
    String? serviceTypeId,
    String? serviceTypeName,
    String? serviceTypePricing,
    double? weight,
  }) {
    final idx =
        selectedArticleDetails.indexWhere((d) => d['articleId'] == articleId);
    final detail = {
      'articleId': articleId,
      'articleName': articleName,
      'articleDescription': articleDescription,
      'basePrice': basePrice,
      'premiumPrice': premiumPrice,
      'quantity': quantity,
      'isPremium': isPremium,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceTypeId': serviceTypeId,
      'serviceTypeName': serviceTypeName,
      'serviceTypePricing': serviceTypePricing,
      'weight': weight,
    };
    if (idx >= 0) {
      selectedArticleDetails[idx] = detail;
    } else {
      selectedArticleDetails.add(detail);
    }
    print('[OrdersController] addOrUpdateArticleDetail: $detail');
    print(
        '[OrdersController] Etat du cache selectedArticleDetails: $selectedArticleDetails');
    update();
  }

  /// Supprime un article du cache local des détails sélectionnés
  void removeArticleDetail(String articleId) {
    selectedArticleDetails.removeWhere((d) => d['articleId'] == articleId);
    update();
  }

  /// Vide le cache local des détails sélectionnés (à appeler lors d'une nouvelle commande)
  void clearArticleDetails() {
    selectedArticleDetails.clear();
    update();
  }

  void updateDraftItemQuantity(String articleId, int quantity,
      {bool isPremium = false}) {
    orderDraft.update((draft) {
      if (draft == null) return;
      // Crée une nouvelle liste pour forcer la réactivité GetX
      final newItems = List<OrderDraftItem>.from(draft.items);
      newItems.removeWhere((i) => i.articleId == articleId);
      if (quantity > 0) {
        newItems.add(OrderDraftItem(
            articleId: articleId, quantity: quantity, isPremium: isPremium));
      }
      draft.items = newItems;
    });
    update();
  }

  // État centralisé de la commande en cours
  final orderDraft = OrderDraft().obs;

  // Setters pour chaque étape du stepper
  void setSelectedClient(String clientId) {
    orderDraft.update((draft) {
      draft?.clientId = clientId;
    });
    update();
  }

  void setSelectedAddress(String addressId) {
    orderDraft.update((draft) {
      draft?.addressId = addressId;
    });
    update();
  }

  void setSelectedService(String serviceId) {
    orderDraft.update((draft) {
      draft?.serviceId = serviceId;
    });
    update();
  }

  void setOrderItems(List<OrderDraftItem> items) {
    orderDraft.update((draft) {
      draft?.items = items;
    });
    update();
  }

  void addDraftItem(OrderDraftItem item) {
    orderDraft.update((draft) {
      draft?.items.add(item);
    });
    update();
  }

  void removeDraftItem(String articleId) {
    orderDraft.update((draft) {
      draft?.items.removeWhere((i) => i.articleId == articleId);
    });
    update();
  }

  // Setter générique pour champs additionnels (dates, code promo, etc.)
  void setOrderDraftField(String key, dynamic value) {
    orderDraft.update((draft) {
      draft?.setField(key, value);
    });
    update();
  }

  // Génère le payload final à envoyer au backend
  Map<String, dynamic> buildOrderPayload() {
    return orderDraft.value.toPayload();
  }

  // Pour garder en mémoire la dernière sélection d'articles et couples (pour le stepper)
  Map<String, int> lastSelectedArticles = {};
  List<Map<String, dynamic>> lastCouples = [];
  bool lastIsPremium = false;
  Service? lastSelectedService;
  ServiceType? lastSelectedServiceType;
  double? lastWeight;
  bool lastShowPremiumSwitch = false;

  /// Synchronise les articles sélectionnés depuis la sélection UI (catalogue)
  void syncSelectedItemsFrom({
    required Map<String, int> selectedArticles,
    required List<Map<String, dynamic>> couples,
    required bool isPremium,
    required Service? selectedService,
    required ServiceType? selectedServiceType,
    double? weight,
    bool showPremiumSwitch = false,
  }) {
    selectedItems.clear();
    selectedArticles.entries.where((e) => e.value > 0).forEach((e) {
      final couple = couples.firstWhereOrNull((c) => c['article_id'] == e.key);
      selectedItems.add({
        'articleId': e.key,
        'quantity': e.value,
        'articleName': couple != null ? couple['article_name'] : null,
        'articleDescription':
            couple != null ? couple['article_description'] : null,
        'price': couple != null
            ? (showPremiumSwitch && isPremium
                ? double.tryParse(couple['premium_price'].toString()) ?? 0.0
                : double.tryParse(couple['base_price'].toString()) ?? 0.0)
            : 0.0,
        'serviceId': selectedService?.id,
        'serviceName': selectedService?.name,
        'serviceTypeId': selectedServiceType?.id,
        'serviceTypeName': selectedServiceType?.name,
        'serviceTypePricing': selectedServiceType?.pricingType,
        'weight': weight,
        'isPremium': showPremiumSwitch && isPremium,
      });
      // Ajoute/MAJ le détail local pour l'affichage du récap
      final existingIdx =
          selectedArticleDetails.indexWhere((d) => d['articleId'] == e.key);
      final detail = {
        'articleId': e.key,
        'articleName': couple != null ? couple['article_name'] : null,
        'articleDescription':
            couple != null ? couple['article_description'] : null,
        'basePrice': couple != null
            ? double.tryParse(couple['base_price'].toString()) ?? 0.0
            : 0.0,
        'premiumPrice': couple != null
            ? double.tryParse(couple['premium_price'].toString())
            : null,
        'serviceId': selectedService?.id,
        'serviceName': selectedService?.name,
        'serviceTypeId': selectedServiceType?.id,
        'serviceTypeName': selectedServiceType?.name,
        'serviceTypePricing': selectedServiceType?.pricingType,
        'quantity': e.value,
      };
      if (existingIdx >= 0) {
        selectedArticleDetails[existingIdx] = detail;
      } else {
        selectedArticleDetails.add(detail);
      }
      print(
          '[OrdersController] Article ajouté (sync): ${e.key}, quantité: ${e.value}');
      print(
          '[OrdersController] Etat du cache selectedArticleDetails (sync): $selectedArticleDetails');
    });
    update();
  }

  // Méthode pour charger les adresses du client (nécessaire pour selectClient)
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

  // Setter pour la sélection du service
  void selectService(String id) {
    print('[OrdersController] Service sélectionné: $id');
    selectedServiceId.value = id;
  }

  // Setter pour la sélection du client (fusionné, unique)
  void selectClient(String clientId) {
    print('[OrdersController] Client sélectionné: $clientId');
    selectedClientId.value = clientId;
    loadClientAddresses(clientId);
  }

  // Setter pour la sélection de l'adresse (fusionné, unique)
  void selectAddress(String addressId) {
    print('[OrdersController] Adresse sélectionnée: $addressId');
    selectedAddressId.value = addressId;
  }

  // Setter pour l'ajout d'un article (fusionné, unique)
  void addItem(String articleId) {
    print('[OrdersController] Article ajouté: $articleId');
    final article = articles.firstWhere((a) => a.id == articleId);
    selectedItems.add({
      'articleId': articleId,
      'quantity': 1,
      'isPremium': false,
      'price': article.basePrice,
    });
    _calculateTotal();
  }

  // Setter pour la mise à jour d'un article (fusionné, unique)
  void updateItemPrice(int index, bool isPremium) {
    final item = selectedItems[index];
    final article = articles.firstWhere((a) => a.id == item['articleId']);
    item['isPremium'] = isPremium;
    item['price'] = isPremium ? article.premiumPrice : article.basePrice;
    selectedItems[index] = item;
    print(
        '[OrdersController] Article modifié: \\${item['articleId']} isPremium=$isPremium');
    _calculateTotal();
  }

  // Setter pour la suppression d'un article (fusionné, unique)
  void removeItem(int index) {
    print(
        '[OrdersController] Article supprimé: ${selectedItems[index]['articleId']}');
    selectedItems.removeAt(index);
    _calculateTotal();
  }

  /// Helper pour retrouver le service type sélectionné à partir de l'ID du draft
  ServiceType? get selectedServiceTypeFromDraft {
    final id = orderDraft.value.serviceTypeId;
    if (id == null) return null;
    return serviceTypes.firstWhereOrNull((t) => t.id == id);
  }

  /// Retourne une liste d'objets enrichis pour le récapitulatif à partir de orderDraft.items
  List<Map<String, dynamic>> getRecapOrderItems() {
    return orderDraft.value.items.map((item) {
      final detail = selectedArticleDetails
          .firstWhereOrNull((d) => d['articleId'] == item.articleId);
      final articleName = detail?['articleName'] ?? 'Article inconnu';
      final serviceName = detail?['serviceName'] ?? '';
      final serviceTypeName = detail?['serviceTypeName'] ?? 'Type inconnu';
      final serviceTypePricing = detail?['serviceTypePricing'] ?? '';
      final articleDescription = detail?['articleDescription'];
      double unitPrice = 0;
      if (detail != null) {
        unitPrice = item.isPremium
            ? (detail['premiumPrice'] ?? detail['basePrice'] ?? 0.0)
            : (detail['basePrice'] ?? 0.0);
      }
      final lineTotal = unitPrice * item.quantity;
      return {
        'articleName': articleName,
        'articleDescription': articleDescription,
        'serviceName': serviceName,
        'serviceTypeName': serviceTypeName,
        'serviceTypePricing': serviceTypePricing,
        'quantity': item.quantity,
        'weight': null,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
        'isPremium': item.isPremium,
      };
    }).toList();
  }

  /// Calcule le total estimé de la commande (somme des lignes)
  double get estimatedTotal {
    return getRecapOrderItems()
        .fold(0.0, (sum, item) => sum + (item['lineTotal'] as double));
  }

  /// Ajoute un nouvel item à la commande (OrderEditForm)
  Future<void> addOrderItem(Map<String, dynamic> item) async {
    if (orderEditForm['items'] == null) {
      orderEditForm['items'] = <Map<String, dynamic>>[];
    }
    (orderEditForm['items'] as List).add(item);
    await recalculateOrderTotalFromBackend();
  }

  /// Met à jour un item existant à l'index donné
  Future<void> updateOrderItem(int index, Map<String, dynamic> item) async {
    if (orderEditForm['items'] != null &&
        index >= 0 &&
        index < (orderEditForm['items'] as List).length) {
      (orderEditForm['items'] as List)[index] = item;
      await recalculateOrderTotalFromBackend();
    }
  }

  /// Supprime un item à l'index donné
  Future<void> removeOrderItem(int index) async {
    if (orderEditForm['items'] != null &&
        index >= 0 &&
        index < (orderEditForm['items'] as List).length) {
      (orderEditForm['items'] as List).removeAt(index);
      await recalculateOrderTotalFromBackend();
    }
  }

  /// Recalcule le total de la commande via le backend (pricing)
  Future<void> recalculateOrderTotalFromBackend() async {
    final items = orderEditForm['items'] as List?;
    final userId = selectedClientId.value;
    if (items == null || items.isEmpty || userId == null || userId.isEmpty) {
      orderEditForm['totalAmount'] = 0.0;
      orderEditForm['subtotal'] = 0.0;
      orderEditForm['discounts'] = [];
      return;
    }
    try {
      final result = await PricingService.calculateOrderTotal(
        items: List<Map<String, dynamic>>.from(items),
        userId: userId,
      );
      orderEditForm['subtotal'] = result['subtotal'] ?? 0.0;
      orderEditForm['discounts'] = result['discounts'] ?? [];
      orderEditForm['totalAmount'] = result['total'] ?? 0.0;
    } catch (e) {
      orderEditForm['totalAmount'] = 0.0;
      orderEditForm['subtotal'] = 0.0;
      orderEditForm['discounts'] = [];
      _showErrorSnackbar('Erreur lors du calcul du total : $e');
    }
  }

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
  final serviceTypes = <ServiceType>[].obs;
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
    loadServices(); // S'assure que la liste des services est chargée dès l'init
  }

  void loadServiceTypes() {
    // À adapter selon la source réelle des services
    serviceTypes.value = [
      ServiceType(
        id: 'standard',
        name: 'Standard',
        description: 'Service standard',
        requiresWeight: false,
        pricingType: 'FIXED',
        isActive: true,
        supportsPremium: true,
        isDefault: true,
      ),
      ServiceType(
        id: 'weight',
        name: 'Au poids',
        description: 'Service au poids',
        requiresWeight: true,
        pricingType: 'WEIGHT_BASED',
        isActive: true,
        supportsPremium: false,
        isDefault: false,
      ),
      // Ajouter d'autres types mock ou charger dynamiquement depuis l'API
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

  // Ajout des propriétés et méthodes pour la recherche par ID indépendante et réinitialisable.
  final isOrderIdSearchActive = false.obs;
  final orderIdResult = Rxn<Order>();

  Future<void> fetchOrders() async {
    // Si une recherche par ID était active, on la désactive
    isOrderIdSearchActive.value = false;
    orderIdResult.value = null;
    await loadOrdersPage(status: filterStatus.value);
  }

  /// Récupère les détails d'une commande.
  /// [activateOrderIdSearch] doit être true UNIQUEMENT pour la recherche par ID (champ dédié),
  /// et false pour un clic sur une ligne du tableau (affichage du dialog sans changer le mode du tableau).
  Future<void> fetchOrderDetails(String orderId,
      {bool activateOrderIdSearch = false}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      final order = await OrderService.getOrderById(orderId);
      orderIdResult.value = order;
      selectedOrder.value = order;
      isOrderIdSearchActive.value = activateOrderIdSearch;
    } catch (e) {
      print('[OrdersController] Error fetching order details: $e');
      hasError.value = true;
      errorMessage.value =
          'Erreur lors du chargement des détails de la commande';
      orderIdResult.value = null;
      selectedOrder.value = null;
      isOrderIdSearchActive.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetOrderIdSearch() {
    orderIdSearch.value = '';
    orderIdResult.value = null;
    isOrderIdSearchActive.value = false;
    hasError.value = false;
    errorMessage.value = '';
    fetchOrders(); // recharge la liste normale
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
      await fetchOrderDetails(orderId, activateOrderIdSearch: false);
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

  // ...existing code...

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
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      // Affiche une notification de succès
      _showSuccessSnackbar('Commande créée avec succès');
      // Ferme tous les écrans jusqu'à la page des commandes
      Get.offAllNamed('/orders');
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
      // Get.back() supprimé pour éviter de fermer le dialog parent
      await loadOrdersPage(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: filterStatus.value,
      );
      await fetchOrderDetails(orderId, activateOrderIdSearch: false);
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
      await fetchOrderDetails(orderId, activateOrderIdSearch: false);
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
      // Get.back() supprimé pour éviter de fermer le dialog parent

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
