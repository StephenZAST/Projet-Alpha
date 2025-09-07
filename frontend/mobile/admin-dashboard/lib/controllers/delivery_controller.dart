import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';

class DeliveryController extends GetxController {
  // ==================== OBSERVABLES ====================

  // États de chargement
  final isLoading = false.obs;
  final isLoadingStats = false.obs;
  final isLoadingOrders = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Données des livreurs
  final deliverers = <DeliveryUser>[].obs;
  final filteredDeliverers = <DeliveryUser>[].obs;
  final selectedDeliverer = Rxn<DeliveryUser>();

  // Statistiques
  final globalStats = Rxn<GlobalDeliveryStats>();
  final selectedDelivererStats = Rxn<DeliveryStats>();

  // Commandes de livraison
  final activeDeliveries = <DeliveryOrder>[].obs;
  final delivererOrders = <DeliveryOrder>[].obs;
  final selectedOrder = Rxn<DeliveryOrder>();

  // Map / visualization
  final mapController = Rxn<MapController>();
  final markers = <Marker>[].obs;
  final routes = <Polyline>[].obs;

  // Filtres et recherche
  final searchQuery = ''.obs;
  final selectedStatus = Rxn<String>();
  final showActiveOnly = true.obs;
  final selectedDelivererFilter = Rxn<String>();

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 20.obs;
  final totalDeliverers = 0.obs;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    print('[DeliveryController] Initialisation');

    // Charger les données initiales
    refreshAll();

    // Initialiser le mapController si nécessaire
    if (mapController.value == null) {
      mapController.value = MapController();
    }

    // Écouter les changements de recherche
    debounce(searchQuery, (_) => _applyFilters(),
        time: Duration(milliseconds: 500));

    // Écouter les changements de filtres
    ever(selectedStatus, (_) => _applyFilters());
    ever(showActiveOnly, (_) => _applyFilters());
    ever(selectedDelivererFilter, (_) => _applyFilters());
  }

  // ==================== MÉTHODES PUBLIQUES ====================

  /// Actualise toutes les données
  Future<void> refreshAll() async {
    await Future.wait([
      loadDeliverers(),
      loadGlobalStats(),
      loadActiveDeliveries(),
    ]);
  }

  /// Charge la liste des livreurs
  Future<void> loadDeliverers({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      hasError.value = false;

      print('[DeliveryController] Chargement des livreurs');

      final result = await DeliveryService.getAllDeliverers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        isActive: showActiveOnly.value ? true : null,
      );

      deliverers.assignAll(result);
      totalDeliverers.value = result.length;

      _applyFilters();

      print('[DeliveryController] ${result.length} livreurs chargés');
    } catch (e) {
      print('[DeliveryController] Erreur lors du chargement des livreurs: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des livreurs';

      Get.snackbar(
        'Erreur',
        'Impossible de charger les livreurs',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// Charge les statistiques globales
  Future<void> loadGlobalStats() async {
    try {
      isLoadingStats.value = true;

      print('[DeliveryController] Chargement des statistiques globales');

      final stats = await DeliveryService.getGlobalDeliveryStats();
      globalStats.value = stats;

      print('[DeliveryController] Statistiques globales chargées');
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors du chargement des statistiques: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Charge les livraisons actives
  Future<void> loadActiveDeliveries() async {
    try {
      isLoadingOrders.value = true;

      print('[DeliveryController] Chargement des livraisons actives');

      final orders = await DeliveryService.getAllActiveDeliveries(
        status: selectedStatus.value,
        delivererId: selectedDelivererFilter.value,
      );

      activeDeliveries.assignAll(orders);

      print(
          '[DeliveryController] ${orders.length} livraisons actives chargées');
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors du chargement des livraisons: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  /// Sélectionne un livreur et charge ses données
  Future<void> selectDeliverer(DeliveryUser deliverer) async {
    selectedDeliverer.value = deliverer;

    // Charger les statistiques et commandes du livreur
    await Future.wait([
      loadDelivererStats(deliverer.id),
      loadDelivererOrders(deliverer.id),
    ]);
  }

  /// Charge les statistiques d'un livreur
  Future<void> loadDelivererStats(String delivererId) async {
    try {
      print(
          '[DeliveryController] Chargement des statistiques du livreur: $delivererId');

      final stats = await DeliveryService.getDelivererStats(delivererId);
      selectedDelivererStats.value = stats;
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors du chargement des statistiques du livreur: $e');
    }
  }

  /// Charge les commandes d'un livreur
  Future<void> loadDelivererOrders(String delivererId) async {
    try {
      print(
          '[DeliveryController] Chargement des commandes du livreur: $delivererId');

      final orders = await DeliveryService.getDelivererOrders(delivererId);
      delivererOrders.assignAll(orders);
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors du chargement des commandes du livreur: $e');
    }
  }

  /// Crée un nouveau livreur
  Future<void> createDeliverer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? zone,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    try {
      isLoading.value = true;

      print('[DeliveryController] Création d\'un nouveau livreur: $email');

      final newDeliverer = await DeliveryService.createDeliverer(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        zone: zone,
        vehicleType: vehicleType,
        licenseNumber: licenseNumber,
      );

      // Ajouter à la liste
      deliverers.add(newDeliverer);
      _applyFilters();

      Get.snackbar(
        'Succès',
        'Livreur créé avec succès',
        snackPosition: SnackPosition.TOP,
      );

      print(
          '[DeliveryController] Livreur créé avec succès: ${newDeliverer.id}');
    } catch (e) {
      print('[DeliveryController] Erreur lors de la création du livreur: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de créer le livreur',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Met à jour un livreur
  Future<void> updateDeliverer(
    String delivererId, {
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isActive,
    String? zone,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    try {
      isLoading.value = true;

      print('[DeliveryController] Mise à jour du livreur: $delivererId');

      final updatedDeliverer = await DeliveryService.updateDeliverer(
        delivererId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        isActive: isActive,
        zone: zone,
        vehicleType: vehicleType,
        licenseNumber: licenseNumber,
      );

      // Mettre à jour dans la liste
      final index = deliverers.indexWhere((d) => d.id == delivererId);
      if (index != -1) {
        deliverers[index] = updatedDeliverer;
        _applyFilters();
      }

      // Mettre à jour la sélection si c'est le livreur sélectionné
      if (selectedDeliverer.value?.id == delivererId) {
        selectedDeliverer.value = updatedDeliverer;
      }

      Get.snackbar(
        'Succès',
        'Livreur mis à jour avec succès',
        snackPosition: SnackPosition.TOP,
      );

      print('[DeliveryController] Livreur mis à jour avec succès');
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors de la mise à jour du livreur: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le livreur',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprime un livreur
  Future<void> deleteDeliverer(String delivererId) async {
    try {
      isLoading.value = true;

      print('[DeliveryController] Suppression du livreur: $delivererId');

      final success = await DeliveryService.deleteDeliverer(delivererId);

      if (success) {
        // Retirer de la liste
        deliverers.removeWhere((d) => d.id == delivererId);
        _applyFilters();

        // Désélectionner si c'était le livreur sélectionné
        if (selectedDeliverer.value?.id == delivererId) {
          selectedDeliverer.value = null;
          selectedDelivererStats.value = null;
          delivererOrders.clear();
        }

        Get.snackbar(
          'Succès',
          'Livreur supprimé avec succès',
          snackPosition: SnackPosition.TOP,
        );

        print('[DeliveryController] Livreur supprimé avec succès');
      }
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors de la suppression du livreur: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le livreur',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Active/désactive un livreur
  Future<void> toggleDelivererStatus(String delivererId, bool isActive) async {
    try {
      print(
          '[DeliveryController] ${isActive ? 'Activation' : 'Désactivation'} du livreur: $delivererId');

      final success =
          await DeliveryService.toggleDelivererStatus(delivererId, isActive);

      if (success) {
        // Recharger les données
        await loadDeliverers(showLoading: false);

        Get.snackbar(
          'Succès',
          'Statut du livreur mis à jour',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('[DeliveryController] Erreur lors du changement de statut: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de changer le statut du livreur',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Assigne une commande à un livreur
  Future<void> assignOrderToDeliverer(
      String orderId, String delivererId) async {
    try {
      print(
          '[DeliveryController] Attribution de la commande $orderId au livreur $delivererId');

      final success =
          await DeliveryService.assignOrderToDeliverer(orderId, delivererId);

      if (success) {
        // Recharger les livraisons actives
        await loadActiveDeliveries();

        Get.snackbar(
          'Succès',
          'Commande assignée avec succès',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors de l\'attribution de la commande: $e');

      Get.snackbar(
        'Erreur',
        'Impossible d\'assigner la commande',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Met à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String newStatus,
      {String? note}) async {
    try {
      print(
          '[DeliveryController] Mise à jour du statut de la commande $orderId vers $newStatus');

      final success = await DeliveryService.updateOrderStatus(
          orderId, newStatus,
          note: note);

      if (success) {
        // Recharger les données
        await Future.wait([
          loadActiveDeliveries(),
          if (selectedDeliverer.value != null)
            loadDelivererOrders(selectedDeliverer.value!.id),
        ]);

        Get.snackbar(
          'Succès',
          'Statut de la commande mis à jour',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('[DeliveryController] Erreur lors de la mise à jour du statut: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== FILTRES ET RECHERCHE ====================

  /// Applique les filtres à la liste des livreurs
  void _applyFilters() {
    var filtered = deliverers.toList();

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((deliverer) {
        return deliverer.fullName.toLowerCase().contains(query) ||
            deliverer.email.toLowerCase().contains(query) ||
            (deliverer.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par statut actif
    if (showActiveOnly.value) {
      filtered = filtered.where((deliverer) => deliverer.isActive).toList();
    }

    filteredDeliverers.assignAll(filtered);
  }

  /// Change la recherche
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Change le filtre de statut
  void filterByStatus(String? status) {
    selectedStatus.value = status;
  }

  /// Toggle le filtre "actifs seulement"
  void toggleActiveOnly() {
    showActiveOnly.value = !showActiveOnly.value;
  }

  /// Change le filtre de livreur
  void filterByDeliverer(String? delivererId) {
    selectedDelivererFilter.value = delivererId;
  }

  // ==================== PAGINATION ====================

  /// Page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadDeliverers();
    }
  }

  /// Page précédente
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadDeliverers();
    }
  }

  /// Va à une page spécifique
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadDeliverers();
    }
  }

  // ==================== UTILITAIRES ====================

  /// Vérifie si un email est disponible
  Future<bool> isEmailAvailable(String email) async {
    try {
      return await DeliveryService.isEmailAvailable(email);
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }

  /// Réinitialise le mot de passe d'un livreur
  Future<void> resetDelivererPassword(
      String delivererId, String newPassword) async {
    try {
      print(
          '[DeliveryController] Réinitialisation du mot de passe du livreur: $delivererId');

      final success = await DeliveryService.resetDelivererPassword(
          delivererId, newPassword);

      if (success) {
        Get.snackbar(
          'Succès',
          'Mot de passe réinitialisé avec succès',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print(
          '[DeliveryController] Erreur lors de la réinitialisation du mot de passe: $e');

      Get.snackbar(
        'Erreur',
        'Impossible de réinitialiser le mot de passe',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Nettoie les ressources
  @override
  void onClose() {
    print('[DeliveryController] Nettoyage des ressources');
    super.onClose();
  }
}
