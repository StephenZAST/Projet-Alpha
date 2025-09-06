import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/loyalty.dart';
import '../services/loyalty_service.dart';
import '../utils/token_debug.dart';

class LoyaltyController extends GetxController {
  void setItemsPerPage(int value) {
    itemsPerPage.value = value;
    fetchLoyaltyPoints(resetPage: true);
  }

  // Observables pour les points de fidélité
  final loyaltyPoints = <LoyaltyPoints>[].obs;
  final filteredLoyaltyPoints = <LoyaltyPoints>[].obs;
  final isLoading = false.obs;
  final isLoadingStats = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 10.obs;
  final totalLoyaltyPoints = 0.obs;

  // Filtres et recherche
  final searchQuery = ''.obs;
  final sortBy = 'createdAt'.obs;
  final sortOrder = 'desc'.obs;

  // Statistiques
  final stats = Rxn<LoyaltyStats>();

  // Transactions de points
  final pointTransactions = <PointTransaction>[].obs;
  final filteredPointTransactions = <PointTransaction>[].obs;
  final isLoadingTransactions = false.obs;
  final selectedTransactionType = Rxn<PointTransactionType>();
  final selectedTransactionSource = Rxn<PointSource>();

  // Récompenses
  final rewards = <Reward>[].obs;
  final filteredRewards = <Reward>[].obs;
  final isLoadingRewards = false.obs;
  final selectedRewardType = Rxn<RewardType>();
  final showActiveRewardsOnly = true.obs;

  // Demandes de récompenses
  final rewardClaims = <RewardClaim>[].obs;
  final filteredRewardClaims = <RewardClaim>[].obs;
  final pendingRewardClaims = <RewardClaim>[].obs;
  final isLoadingClaims = false.obs;
  final selectedClaimStatus = Rxn<RewardClaimStatus>();

  // Utilisateur sélectionné pour les détails
  final selectedLoyaltyPoints = Rxn<LoyaltyPoints>();
  final userPointHistory = <PointTransaction>[].obs;

  // Récompense sélectionnée pour les détails
  final selectedReward = Rxn<Reward>();

  @override
  void onInit() {
    super.onInit();
    print('[LoyaltyController] Initializing...');

    // Debug du token avant de faire les requêtes
    TokenDebug.logTokenState('LoyaltyController.onInit');
    TokenDebug.logStorageContents();

    // Charger les données initiales
    fetchLoyaltyPoints();
    fetchLoyaltyStats();
    fetchPointTransactions();
    fetchRewards();
    fetchRewardClaims();
    fetchPendingRewardClaims();

    // Écouter les changements de recherche et filtres
    debounce(searchQuery, (_) => _applyFilters(),
        time: Duration(milliseconds: 500));
    ever(selectedTransactionType, (_) => _applyTransactionFilters());
    ever(selectedTransactionSource, (_) => _applyTransactionFilters());
    ever(selectedRewardType, (_) => _applyRewardFilters());
    ever(showActiveRewardsOnly, (_) => _applyRewardFilters());
    ever(selectedClaimStatus, (_) => _applyClaimFilters());
  }

  /// Récupère tous les points de fidélité
  Future<void> fetchLoyaltyPoints({bool resetPage = false}) async {
    try {
      if (resetPage) currentPage.value = 1;

      isLoading.value = true;
      print('[LoyaltyController] Fetching loyalty points...');

      final result = await LoyaltyService.getAllLoyaltyPoints(
        page: currentPage.value,
        limit: itemsPerPage.value,
        query: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      loyaltyPoints.value = result;
      _applyFilters();

      print('[LoyaltyController] ✅ Fetched ${result.length} loyalty points');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching loyalty points: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des points', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère les statistiques du système de fidélité
  Future<void> fetchLoyaltyStats() async {
    try {
      isLoadingStats.value = true;
      print('[LoyaltyController] Fetching loyalty stats...');

      final result = await LoyaltyService.getLoyaltyStats();
      stats.value = result;

      print('[LoyaltyController] ✅ Fetched loyalty stats');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching loyalty stats: $e');
      // Ne pas afficher d'erreur pour les stats, c'est moins critique
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Récupère toutes les transactions de points
  Future<void> fetchPointTransactions({bool resetPage = false}) async {
    try {
      if (resetPage) currentPage.value = 1;

      isLoadingTransactions.value = true;
      print('[LoyaltyController] Fetching point transactions...');

      final result = await LoyaltyService.getPointTransactions(
        page: currentPage.value,
        limit: itemsPerPage.value,
        type: selectedTransactionType.value,
        source: selectedTransactionSource.value,
      );

      pointTransactions.value = result;
      _applyTransactionFilters();

      print('[LoyaltyController] ✅ Fetched ${result.length} point transactions');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching point transactions: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des transactions', e.toString());
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  /// Récupère toutes les récompenses
  Future<void> fetchRewards({bool resetPage = false}) async {
    try {
      if (resetPage) currentPage.value = 1;

      isLoadingRewards.value = true;
      print('[LoyaltyController] Fetching rewards...');

      final result = await LoyaltyService.getAllRewards(
        page: currentPage.value,
        limit: itemsPerPage.value,
        isActive: showActiveRewardsOnly.value ? true : null,
        type: selectedRewardType.value,
      );

      rewards.value = result;
      _applyRewardFilters();

      print('[LoyaltyController] ✅ Fetched ${result.length} rewards');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching rewards: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des récompenses', e.toString());
    } finally {
      isLoadingRewards.value = false;
    }
  }

  /// Récupère toutes les demandes de récompenses
  Future<void> fetchRewardClaims({bool resetPage = false}) async {
    try {
      if (resetPage) currentPage.value = 1;

      isLoadingClaims.value = true;
      print('[LoyaltyController] Fetching reward claims...');

      final result = await LoyaltyService.getRewardClaims(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: selectedClaimStatus.value,
      );

      rewardClaims.value = result;
      _applyClaimFilters();

      print('[LoyaltyController] ✅ Fetched ${result.length} reward claims');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching reward claims: $e');
      _showErrorSnackbar(
          'Erreur lors du chargement des demandes', e.toString());
    } finally {
      isLoadingClaims.value = false;
    }
  }

  /// Récupère les demandes de récompenses en attente
  Future<void> fetchPendingRewardClaims() async {
    try {
      print('[LoyaltyController] Fetching pending reward claims...');

      final result = await LoyaltyService.getPendingRewardClaims();
      pendingRewardClaims.value = result;

      print(
          '[LoyaltyController] ✅ Fetched ${result.length} pending reward claims');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching pending reward claims: $e');
    }
  }

  /// Ajoute des points à un utilisateur
  Future<void> addPointsToUser(
    String userId,
    int points,
    PointSource source,
    String referenceId,
  ) async {
    try {
      print('[LoyaltyController] Adding points to user: $userId');

      final result = await LoyaltyService.addPointsToUser(
        userId,
        points,
        source,
        referenceId,
      );

      if (result != null) {
        // Recharger les données
        await Future.wait([
          fetchLoyaltyPoints(),
          fetchPointTransactions(),
          fetchLoyaltyStats(),
        ]);

        _showSuccessSnackbar('Points ajoutés',
            '$points points ont été ajoutés avec succès');
        print('[LoyaltyController] ✅ Points added successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error adding points: $e');
      _showErrorSnackbar('Erreur d\'ajout de points', e.toString());
    }
  }

  /// Déduit des points d'un utilisateur
  Future<void> deductPointsFromUser(
    String userId,
    int points,
    PointSource source,
    String referenceId,
  ) async {
    try {
      print('[LoyaltyController] Deducting points from user: $userId');

      final result = await LoyaltyService.deductPointsFromUser(
        userId,
        points,
        source,
        referenceId,
      );

      if (result != null) {
        // Recharger les données
        await Future.wait([
          fetchLoyaltyPoints(),
          fetchPointTransactions(),
          fetchLoyaltyStats(),
        ]);

        _showSuccessSnackbar('Points déduits',
            '$points points ont été déduits avec succès');
        print('[LoyaltyController] ✅ Points deducted successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error deducting points: $e');
      _showErrorSnackbar('Erreur de déduction de points', e.toString());
    }
  }

  /// Crée une nouvelle récompense
  Future<void> createReward({
    required String name,
    required String description,
    required int pointsCost,
    required RewardType type,
    double? discountValue,
    String? discountType,
    int? maxRedemptions,
  }) async {
    try {
      print('[LoyaltyController] Creating new reward: $name');

      final result = await LoyaltyService.createReward(
        name: name,
        description: description,
        pointsCost: pointsCost,
        type: type,
        discountValue: discountValue,
        discountType: discountType,
        maxRedemptions: maxRedemptions,
      );

      if (result != null) {
        // Recharger les récompenses
        await fetchRewards();

        _showSuccessSnackbar('Récompense créée',
            'La récompense a été créée avec succès');
        print('[LoyaltyController] ✅ Reward created successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error creating reward: $e');
      _showErrorSnackbar('Erreur de création', e.toString());
    }
  }

  /// Met à jour une récompense
  Future<void> updateReward(
    String rewardId, {
    String? name,
    String? description,
    int? pointsCost,
    RewardType? type,
    double? discountValue,
    String? discountType,
    bool? isActive,
    int? maxRedemptions,
  }) async {
    try {
      print('[LoyaltyController] Updating reward: $rewardId');

      final result = await LoyaltyService.updateReward(
        rewardId,
        name: name,
        description: description,
        pointsCost: pointsCost,
        type: type,
        discountValue: discountValue,
        discountType: discountType,
        isActive: isActive,
        maxRedemptions: maxRedemptions,
      );

      if (result != null) {
        // Mettre à jour la récompense dans la liste
        final index = rewards.indexWhere((r) => r.id == rewardId);
        if (index != -1) {
          rewards[index] = result;
          rewards.refresh();
          _applyRewardFilters();
        }

        // Mettre à jour la récompense sélectionnée si c'est la même
        if (selectedReward.value?.id == rewardId) {
          selectedReward.value = result;
        }

        _showSuccessSnackbar('Récompense mise à jour',
            'La récompense a été mise à jour avec succès');
        print('[LoyaltyController] ✅ Reward updated successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error updating reward: $e');
      _showErrorSnackbar('Erreur de mise à jour', e.toString());
    }
  }

  /// Supprime une récompense
  Future<void> deleteReward(String rewardId) async {
    try {
      print('[LoyaltyController] Deleting reward: $rewardId');

      final success = await LoyaltyService.deleteReward(rewardId);

      if (success) {
        // Supprimer la récompense de la liste
        rewards.removeWhere((r) => r.id == rewardId);
        rewards.refresh();
        _applyRewardFilters();

        // Désélectionner si c'était la récompense sélectionnée
        if (selectedReward.value?.id == rewardId) {
          selectedReward.value = null;
        }

        _showSuccessSnackbar('Récompense supprimée',
            'La récompense a été supprimée avec succès');
        print('[LoyaltyController] ✅ Reward deleted successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error deleting reward: $e');
      _showErrorSnackbar('Erreur de suppression', e.toString());
    }
  }

  /// Approuve une demande de récompense
  Future<void> approveRewardClaim(String claimId) async {
    try {
      print('[LoyaltyController] Approving reward claim: $claimId');

      final success = await LoyaltyService.approveRewardClaim(claimId);

      if (success) {
        // Recharger les demandes de récompenses
        await Future.wait([
          fetchRewardClaims(),
          fetchPendingRewardClaims(),
        ]);

        _showSuccessSnackbar('Demande approuvée',
            'La demande de récompense a été approuvée avec succès');
        print('[LoyaltyController] ✅ Reward claim approved successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error approving reward claim: $e');
      _showErrorSnackbar('Erreur d\'approbation', e.toString());
    }
  }

  /// Rejette une demande de récompense
  Future<void> rejectRewardClaim(String claimId, String reason) async {
    try {
      print('[LoyaltyController] Rejecting reward claim: $claimId');

      final success = await LoyaltyService.rejectRewardClaim(claimId, reason);

      if (success) {
        // Recharger les demandes de récompenses
        await Future.wait([
          fetchRewardClaims(),
          fetchPendingRewardClaims(),
        ]);

        _showSuccessSnackbar(
            'Demande rejetée', 'La demande de récompense a été rejetée');
        print('[LoyaltyController] ✅ Reward claim rejected successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error rejecting reward claim: $e');
      _showErrorSnackbar('Erreur de rejet', e.toString());
    }
  }

  /// Marque une demande de récompense comme utilisée
  Future<void> markRewardClaimAsUsed(String claimId) async {
    try {
      print('[LoyaltyController] Marking reward claim as used: $claimId');

      final success = await LoyaltyService.markRewardClaimAsUsed(claimId);

      if (success) {
        // Recharger les demandes de récompenses
        await fetchRewardClaims();

        _showSuccessSnackbar('Récompense utilisée',
            'La récompense a été marquée comme utilisée');
        print('[LoyaltyController] ✅ Reward claim marked as used successfully');
      }
    } catch (e) {
      print('[LoyaltyController] ❌ Error marking reward claim as used: $e');
      _showErrorSnackbar('Erreur de mise à jour', e.toString());
    }
  }

  /// Sélectionne des points de fidélité et charge l'historique
  Future<void> selectLoyaltyPoints(LoyaltyPoints loyaltyPoints) async {
    try {
      selectedLoyaltyPoints.value = loyaltyPoints;
      print(
          '[LoyaltyController] Selected loyalty points for user: ${loyaltyPoints.userId}');

      // Charger l'historique des points de l'utilisateur
      await fetchUserPointHistory(loyaltyPoints.userId);
    } catch (e) {
      print('[LoyaltyController] ❌ Error selecting loyalty points: $e');
    }
  }

  /// Récupère l'historique des points d'un utilisateur
  Future<void> fetchUserPointHistory(String userId) async {
    try {
      print('[LoyaltyController] Fetching point history for user: $userId');

      final result = await LoyaltyService.getUserPointHistory(userId);
      userPointHistory.value = result;

      print('[LoyaltyController] ✅ Fetched ${result.length} point transactions for user');
    } catch (e) {
      print('[LoyaltyController] ❌ Error fetching user point history: $e');
    }
  }

  /// Sélectionne une récompense
  void selectReward(Reward reward) {
    selectedReward.value = reward;
    print('[LoyaltyController] Selected reward: ${reward.name}');
  }

  /// Recherche dans les points de fidélité
  void searchLoyaltyPoints(String query) {
    searchQuery.value = query;
    print('[LoyaltyController] Searching loyalty points: $query');
  }

  /// Filtre les transactions par type
  void filterTransactionsByType(PointTransactionType? type) {
    selectedTransactionType.value = type;
    print(
        '[LoyaltyController] Filtering transactions by type: ${type?.name ?? 'ALL'}');
  }

  /// Filtre les transactions par source
  void filterTransactionsBySource(PointSource? source) {
    selectedTransactionSource.value = source;
    print(
        '[LoyaltyController] Filtering transactions by source: ${source?.name ?? 'ALL'}');
  }

  /// Filtre les récompenses par type
  void filterRewardsByType(RewardType? type) {
    selectedRewardType.value = type;
    print(
        '[LoyaltyController] Filtering rewards by type: ${type?.name ?? 'ALL'}');
  }

  /// Bascule l'affichage des récompenses actives seulement
  void toggleActiveRewardsOnly() {
    showActiveRewardsOnly.value = !showActiveRewardsOnly.value;
    print(
        '[LoyaltyController] Show active rewards only: ${showActiveRewardsOnly.value}');
  }

  /// Filtre les demandes par statut
  void filterClaimsByStatus(RewardClaimStatus? status) {
    selectedClaimStatus.value = status;
    print(
        '[LoyaltyController] Filtering claims by status: ${status?.name ?? 'ALL'}');
  }

  /// Applique les filtres et la recherche pour les points de fidélité
  void _applyFilters() {
    var filtered = List<LoyaltyPoints>.from(loyaltyPoints);

    // Appliquer le filtre de recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((points) {
        return points.fullName.toLowerCase().contains(query) ||
            points.email.toLowerCase().contains(query) ||
            points.phone.toLowerCase().contains(query);
      }).toList();
    }

    // Appliquer le tri
    filtered.sort((a, b) {
      switch (sortBy.value) {
        case 'name':
          return sortOrder.value == 'asc'
              ? a.fullName.compareTo(b.fullName)
              : b.fullName.compareTo(a.fullName);
        case 'pointsBalance':
          return sortOrder.value == 'asc'
              ? a.pointsBalance.compareTo(b.pointsBalance)
              : b.pointsBalance.compareTo(a.pointsBalance);
        case 'totalEarned':
          return sortOrder.value == 'asc'
              ? a.totalEarned.compareTo(b.totalEarned)
              : b.totalEarned.compareTo(a.totalEarned);
        case 'createdAt':
        default:
          return sortOrder.value == 'asc'
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
      }
    });

    filteredLoyaltyPoints.value = filtered;
    totalLoyaltyPoints.value = filtered.length;

    print('[LoyaltyController] Applied filters: ${filtered.length} results');
  }

  /// Applique les filtres pour les transactions
  void _applyTransactionFilters() {
    var filtered = List<PointTransaction>.from(pointTransactions);

    // Appliquer le filtre de type
    if (selectedTransactionType.value != null) {
      filtered = filtered.where((transaction) {
        return transaction.type == selectedTransactionType.value;
      }).toList();
    }

    // Appliquer le filtre de source
    if (selectedTransactionSource.value != null) {
      filtered = filtered.where((transaction) {
        return transaction.source == selectedTransactionSource.value;
      }).toList();
    }

    // Tri par date (plus récent en premier)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredPointTransactions.value = filtered;

    print('[LoyaltyController] Applied transaction filters: ${filtered.length} results');
  }

  /// Applique les filtres pour les récompenses
  void _applyRewardFilters() {
    var filtered = List<Reward>.from(rewards);

    // Appliquer le filtre de type
    if (selectedRewardType.value != null) {
      filtered = filtered.where((reward) {
        return reward.type == selectedRewardType.value;
      }).toList();
    }

    // Appliquer le filtre actif/inactif
    if (showActiveRewardsOnly.value) {
      filtered = filtered.where((reward) => reward.isActive).toList();
    }

    // Tri par date de création (plus récent en premier)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredRewards.value = filtered;

    print('[LoyaltyController] Applied reward filters: ${filtered.length} results');
  }

  /// Applique les filtres pour les demandes de récompenses
  void _applyClaimFilters() {
    var filtered = List<RewardClaim>.from(rewardClaims);

    // Appliquer le filtre de statut
    if (selectedClaimStatus.value != null) {
      filtered = filtered.where((claim) {
        return claim.status == selectedClaimStatus.value;
      }).toList();
    }

    // Tri par date de création (plus récent en premier)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredRewardClaims.value = filtered;

    print('[LoyaltyController] Applied claim filters: ${filtered.length} results');
  }

  /// Change la page
  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchLoyaltyPoints();
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
      fetchLoyaltyPoints(resetPage: true),
      fetchLoyaltyStats(),
      fetchPointTransactions(resetPage: true),
      fetchRewards(resetPage: true),
      fetchRewardClaims(resetPage: true),
      fetchPendingRewardClaims(),
    ]);
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
    print('[LoyaltyController] Disposing...');
    super.onClose();
  }
}