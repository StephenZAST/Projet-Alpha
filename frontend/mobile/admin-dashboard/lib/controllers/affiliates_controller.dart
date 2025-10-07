import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/affiliate.dart';
import '../models/user.dart';
import '../services/affiliate_service.dart';
import '../services/user_service.dart';
import '../utils/token_debug.dart';

class AffiliatesController extends GetxController {
  void setItemsPerPage(int value) {
    itemsPerPage.value = value;
    fetchAffiliates(resetPage: true);
  }

  // Observables pour les affiliés
  final affiliates = <AffiliateProfile>[].obs;
  final filteredAffiliates = <AffiliateProfile>[].obs;
  final isLoading = false.obs;
  final isLoadingStats = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 10.obs;
  final totalAffiliates = 0.obs;

  // Filtres et recherche
  final searchQuery = ''.obs;
  final selectedStatus = Rxn<AffiliateStatus>();
  final sortBy = 'createdAt'.obs;
  final sortOrder = 'desc'.obs;

  // Statistiques
  final stats = Rxn<AffiliateStats>();

  // Commissions et retraits
  final commissions = <CommissionTransaction>[].obs;
  final withdrawals = <WithdrawalRequest>[].obs;
  final pendingWithdrawals = <WithdrawalRequest>[].obs;
  final isLoadingCommissions = false.obs;
  final isLoadingWithdrawals = false.obs;

  // Niveaux d'affiliation
  final affiliateLevels = <AffiliateLevel>[].obs;

  // Affilié sélectionné pour les détails
  final selectedAffiliate = Rxn<AffiliateProfile>();
  final affiliateReferrals = <AffiliateProfile>[].obs;

  // Liaisons affilié-client
  final affiliateClientLinks = <AffiliateClientLink>[].obs;
  final isLoadingLinks = false.obs;
  final currentLinksPage = 1.obs;
  final totalLinksPages = 1.obs;
  final totalLinks = 0.obs;

  // Clients et affiliés pour les dropdowns
  final availableClients = <User>[].obs;
  final availableAffiliates = <AffiliateProfile>[].obs;
  final isLoadingDropdowns = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[AffiliatesController] Initializing...');

    // Debug du token avant de faire les requêtes
    TokenDebug.logTokenState('AffiliatesController.onInit');
    TokenDebug.logStorageContents();

    // Charger les données initiales
    fetchAffiliates();
    fetchAffiliateStats();
    fetchAffiliateLevels();
    fetchPendingWithdrawals();

    // Écouter les changements de recherche et filtres
    debounce(searchQuery, (_) => _applyFilters(),
        time: Duration(milliseconds: 500));
    ever(selectedStatus, (_) => _applyFilters());
  }

  /// Récupère tous les affiliés
  Future<void> fetchAffiliates({bool resetPage = false}) async {
    try {
      if (resetPage) currentPage.value = 1;

      isLoading.value = true;
      print('[AffiliatesController] Fetching affiliates...');

      final result = await AffiliateService.getAllAffiliates(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: selectedStatus.value,
        query: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      affiliates.value = result;
      _applyFilters();

      print('[AffiliatesController] ✅ Fetched ${result.length} affiliates');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching affiliates: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des affiliés', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère les statistiques des affiliés
  Future<void> fetchAffiliateStats() async {
    try {
      isLoadingStats.value = true;
      print('[AffiliatesController] Fetching affiliate stats...');

      final result = await AffiliateService.getAffiliateStats();
      stats.value = result;

      print('[AffiliatesController] ✅ Fetched affiliate stats');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching affiliate stats: $e');
      // Ne pas afficher d'erreur pour les stats, c'est moins critique
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Récupère les niveaux d'affiliation
  Future<void> fetchAffiliateLevels() async {
    try {
      print('[AffiliatesController] Fetching affiliate levels...');

      final result = await AffiliateService.getAffiliateLevels();
      affiliateLevels.value = result;

      print(
          '[AffiliatesController] ✅ Fetched ${result.length} affiliate levels');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching affiliate levels: $e');
    }
  }

  /// Met à jour le statut d'un affilié
  Future<void> updateAffiliateStatus(
    String affiliateId,
    AffiliateStatus status,
    bool isActive,
  ) async {
    try {
      print('[AffiliatesController] Updating affiliate status: $affiliateId');

      final result = await AffiliateService.updateAffiliateStatus(
        affiliateId,
        status,
        isActive,
      );

      if (result != null) {
        // Mettre à jour l'affilié dans la liste
        final index = affiliates.indexWhere((a) => a.id == affiliateId);
        if (index != -1) {
          affiliates[index] = result;
          affiliates.refresh();
          _applyFilters();
        }

        // Mettre à jour l'affilié sélectionné si c'est le même
        if (selectedAffiliate.value?.id == affiliateId) {
          selectedAffiliate.value = result;
        }

        _showSuccessSnackbar('Statut mis à jour',
            'Le statut de l\'affilié a été mis à jour avec succès');
        print('[AffiliatesController] ✅ Affiliate status updated successfully');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error updating affiliate status: $e');
      _showErrorSnackbar('Erreur de mise à jour', e.toString());
    }
  }

  /// Sélectionne un affilié et charge ses détails
  Future<void> selectAffiliate(AffiliateProfile affiliate) async {
    try {
      selectedAffiliate.value = affiliate;
      print(
          '[AffiliatesController] Selected affiliate: ${affiliate.affiliateCode}');

      // Charger les détails supplémentaires
      await Future.wait([
        fetchAffiliateCommissions(affiliate.id),
        fetchAffiliateReferrals(affiliate.id),
      ]);
    } catch (e) {
      print('[AffiliatesController] ❌ Error selecting affiliate: $e');
    }
  }

  /// Récupère les commissions d'un affilié
  Future<void> fetchAffiliateCommissions(String affiliateId) async {
    try {
      isLoadingCommissions.value = true;
      print('[AffiliatesController] Fetching commissions for: $affiliateId');

      final result = await AffiliateService.getCommissions(affiliateId);
      commissions.value = result;

      print('[AffiliatesController] ✅ Fetched ${result.length} commissions');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching commissions: $e');
    } finally {
      isLoadingCommissions.value = false;
    }
  }

  /// Récupère les filleuls d'un affilié
  Future<void> fetchAffiliateReferrals(String affiliateId) async {
    try {
      print('[AffiliatesController] Fetching referrals for: $affiliateId');

      final result = await AffiliateService.getReferrals(affiliateId);
      affiliateReferrals.value = result;

      print('[AffiliatesController] ✅ Fetched ${result.length} referrals');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching referrals: $e');
    }
  }

  /// Récupère toutes les demandes de retrait
  Future<void> fetchWithdrawals() async {
    try {
      isLoadingWithdrawals.value = true;
      print('[AffiliatesController] Fetching withdrawals...');

      final result = await AffiliateService.getWithdrawals();
      withdrawals.value = result;

      print('[AffiliatesController] ✅ Fetched ${result.length} withdrawals');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching withdrawals: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des retraits', e.toString());
    } finally {
      isLoadingWithdrawals.value = false;
    }
  }

  /// Récupère les demandes de retrait en attente
  Future<void> fetchPendingWithdrawals() async {
    try {
      print('[AffiliatesController] Fetching pending withdrawals...');

      final result = await AffiliateService.getPendingWithdrawals();
      pendingWithdrawals.value = result;

      print(
          '[AffiliatesController] ✅ Fetched ${result.length} pending withdrawals');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching pending withdrawals: $e');
    }
  }

  /// Approuve une demande de retrait
  Future<void> approveWithdrawal(String withdrawalId) async {
    try {
      print('[AffiliatesController] Approving withdrawal: $withdrawalId');

      final success = await AffiliateService.approveWithdrawal(withdrawalId);

      if (success) {
        // Recharger les demandes de retrait
        await Future.wait([
          fetchWithdrawals(),
          fetchPendingWithdrawals(),
        ]);

        _showSuccessSnackbar('Retrait approuvé',
            'La demande de retrait a été approuvée avec succès');
        print('[AffiliatesController] ✅ Withdrawal approved successfully');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error approving withdrawal: $e');
      _showErrorSnackbar('Erreur d\'approbation', e.toString());
    }
  }

  /// Rejette une demande de retrait
  Future<void> rejectWithdrawal(String withdrawalId, String reason) async {
    try {
      print('[AffiliatesController] Rejecting withdrawal: $withdrawalId');

      final success =
          await AffiliateService.rejectWithdrawal(withdrawalId, reason);

      if (success) {
        // Recharger les demandes de retrait
        await Future.wait([
          fetchWithdrawals(),
          fetchPendingWithdrawals(),
        ]);

        _showSuccessSnackbar(
            'Retrait rejeté', 'La demande de retrait a été rejetée');
        print('[AffiliatesController] ✅ Withdrawal rejected successfully');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error rejecting withdrawal: $e');
      _showErrorSnackbar('Erreur de rejet', e.toString());
    }
  }

  /// Recherche des affiliés
  void searchAffiliates(String query) {
    searchQuery.value = query;
    print('[AffiliatesController] Searching affiliates: $query');
  }

  /// Filtre par statut
  void filterByStatus(AffiliateStatus? status) {
    selectedStatus.value = status;
    print(
        '[AffiliatesController] Filtering by status: ${status?.name ?? 'ALL'}');
  }

  /// Applique les filtres et la recherche
  void _applyFilters() {
    var filtered = List<AffiliateProfile>.from(affiliates);

    // Appliquer le filtre de recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((affiliate) {
        return affiliate.affiliateCode.toLowerCase().contains(query) ||
            affiliate.fullName.toLowerCase().contains(query) ||
            affiliate.email.toLowerCase().contains(query);
      }).toList();
    }

    // Appliquer le filtre de statut
    if (selectedStatus.value != null) {
      filtered = filtered.where((affiliate) {
        return affiliate.status == selectedStatus.value;
      }).toList();
    }

    // Appliquer le tri
    filtered.sort((a, b) {
      switch (sortBy.value) {
        case 'name':
          return sortOrder.value == 'asc'
              ? a.fullName.compareTo(b.fullName)
              : b.fullName.compareTo(a.fullName);
        case 'totalEarned':
          return sortOrder.value == 'asc'
              ? a.totalEarned.compareTo(b.totalEarned)
              : b.totalEarned.compareTo(a.totalEarned);
        case 'commissionBalance':
          return sortOrder.value == 'asc'
              ? a.commissionBalance.compareTo(b.commissionBalance)
              : b.commissionBalance.compareTo(a.commissionBalance);
        case 'createdAt':
        default:
          return sortOrder.value == 'asc'
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
      }
    });

    filteredAffiliates.value = filtered;
    totalAffiliates.value = filtered.length;

    print('[AffiliatesController] Applied filters: ${filtered.length} results');
  }

  /// Change la page
  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchAffiliates();
    }
  }

  /// Page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      changePage(currentPage.value + 1);
    }
  }

  /// Page précédente
  void previousPage() {
    if (currentPage.value > 1) {
      changePage(currentPage.value - 1);
    }
  }

  /// Change le tri
  void changeSorting(String field) {
    if (sortBy.value == field) {
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortOrder.value = 'desc';
    }
    _applyFilters();
  }

  /// Rafraîchit toutes les données
  Future<void> refreshAll() async {
    await Future.wait([
      fetchAffiliates(resetPage: true),
      fetchAffiliateStats(),
      fetchPendingWithdrawals(),
      fetchAffiliateClientLinks(resetPage: true),
    ]);
  }

  // ===== AFFILIATE CLIENT LINKS =====

  /// Récupère les liaisons affilié-client
  Future<void> fetchAffiliateClientLinks({bool resetPage = false}) async {
    try {
      if (resetPage) currentLinksPage.value = 1;

      isLoadingLinks.value = true;
      print('[AffiliatesController] Fetching affiliate client links...');

      final result = await AffiliateService.getAffiliateClientLinks(
        page: currentLinksPage.value,
        limit: itemsPerPage.value,
      );

      affiliateClientLinks.value = result;
      print('[AffiliatesController] ✅ Fetched ${result.length} links');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching links: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des liaisons', e.toString());
    } finally {
      isLoadingLinks.value = false;
    }
  }

  /// Crée une nouvelle liaison
  Future<void> createAffiliateClientLink({
    required String affiliateId,
    required String clientId,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      print('[AffiliatesController] Creating new link...');
      print('[AffiliatesController] Parameters received:');
      print('  - affiliateId: $affiliateId (type: ${affiliateId.runtimeType})');
      print('  - clientId: $clientId (type: ${clientId.runtimeType})');
      print('  - startDate: $startDate (type: ${startDate.runtimeType})');
      print('  - endDate: $endDate (type: ${endDate?.runtimeType})');

      // Validation des paramètres
      if (affiliateId.isEmpty) {
        throw Exception('Affiliate ID is empty');
      }
      if (clientId.isEmpty) {
        throw Exception('Client ID is empty');
      }

      print(
          '[AffiliatesController] Calling AffiliateService.createAffiliateClientLink...');

      final newLink = await AffiliateService.createAffiliateClientLink(
        affiliateId: affiliateId,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
      );

      print('[AffiliatesController] Service returned: $newLink');

      if (newLink != null) {
        affiliateClientLinks.add(newLink);
        _showSuccessSnackbar('Succès', 'Liaison créée avec succès');
        print('[AffiliatesController] ✅ Link created successfully');
      } else {
        print('[AffiliatesController] ⚠️ Service returned null link');
        throw Exception('Service returned null link');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error creating link: $e');
      print('[AffiliatesController] ❌ Error type: ${e.runtimeType}');
      _showErrorSnackbar('Erreur lors de la création', e.toString());
    }
  }

  /// Met à jour une liaison
  Future<void> updateAffiliateClientLink({
    required String linkId,
    String? affiliateId,
    String? clientId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    try {
      print('[AffiliatesController] Updating link $linkId...');

      final updatedLink = await AffiliateService.updateAffiliateClientLink(
        linkId: linkId,
        affiliateId: affiliateId,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );

      if (updatedLink != null) {
        final index =
            affiliateClientLinks.indexWhere((link) => link.id == linkId);
        if (index != -1) {
          affiliateClientLinks[index] = updatedLink;
        }
        _showSuccessSnackbar('Succès', 'Liaison mise à jour');
        print('[AffiliatesController] ✅ Link updated successfully');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error updating link: $e');
      _showErrorSnackbar('Erreur lors de la mise à jour', e.toString());
    }
  }

  /// Supprime une liaison
  Future<void> deleteAffiliateClientLink(String linkId) async {
    try {
      print('[AffiliatesController] Deleting link $linkId...');

      final success = await AffiliateService.deleteAffiliateClientLink(linkId);

      if (success) {
        affiliateClientLinks.removeWhere((link) => link.id == linkId);
        _showSuccessSnackbar('Succès', 'Liaison supprimée');
        print('[AffiliatesController] ✅ Link deleted successfully');
      }
    } catch (e) {
      print('[AffiliatesController] ❌ Error deleting link: $e');
      _showErrorSnackbar('Erreur lors de la suppression', e.toString());
    }
  }

  /// Récupère les clients disponibles pour les dropdowns
  Future<void> fetchAvailableClients() async {
    try {
      print('[AffiliatesController] Fetching available clients...');
      isLoadingDropdowns.value = true;

      final response = await UserService.getUsers(
        role: 'CLIENT',
        limit: 1000, // Récupérer tous les clients
      );

      // Filtrer pour s'assurer qu'on n'a que des clients
      final clients =
          response.items.where((user) => user.role == UserRole.CLIENT).toList();
      availableClients.value = clients;

      print(
          '[AffiliatesController] ✅ Fetched ${clients.length} clients (filtered from ${response.items.length} users)');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching clients: $e');
      _showErrorSnackbar('Erreur', 'Impossible de charger les clients');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  /// Récupère les affiliés disponibles pour les dropdowns
  Future<void> fetchAvailableAffiliates() async {
    try {
      print('[AffiliatesController] Fetching available affiliates...');
      isLoadingDropdowns.value = true;

      final affiliates = await AffiliateService.getAllAffiliates(
        limit: 1000, // Récupérer tous les affiliés
      );

      availableAffiliates.value = affiliates;
      print('[AffiliatesController] ✅ Fetched ${affiliates.length} affiliates');
    } catch (e) {
      print('[AffiliatesController] ❌ Error fetching affiliates: $e');
      _showErrorSnackbar('Erreur', 'Impossible de charger les affiliés');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  /// Charge les données pour les dropdowns
  Future<void> loadDropdownData() async {
    print('[AffiliatesController] Loading dropdown data...');
    await Future.wait([
      fetchAvailableClients(),
      fetchAvailableAffiliates(),
    ]);
    print(
        '[AffiliatesController] Dropdown data loaded - Clients: ${availableClients.length}, Affiliates: ${availableAffiliates.length}');
  }

  /// Affiche un snackbar de succès
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Affiche un snackbar d'erreur
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: Duration(seconds: 5),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  @override
  void onClose() {
    print('[AffiliatesController] Disposing...');
    super.onClose();
  }
}
