import 'package:get/get.dart';
import '../constants.dart';
import '../services/admin_service.dart';
import '../models/affiliate.dart';

class AffiliateController extends GetxController {
  // État de chargement et erreurs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;

  void rejectWithdrawal(String requestId, String reason) async {
    try {
      isLoading(true);
      await AdminService.rejectWithdrawal(requestId, reason);
      loadWithdrawals(); // Recharger les demandes après le rejet
      Get.snackbar(
        'Succès',
        'Demande rejetée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de rejeter la demande: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading(false);
    }
  }

  // Données des affiliés
  final affiliates = <Affiliate>[].obs;
  final selectedAffiliate = Rxn<Affiliate>();
  final totalAffiliates = 0.obs;

  // Filtres et pagination
  final selectedStatus = RxnString();
  final searchQuery = ''.obs;
  final currentPage = 1.obs;
  final itemsPerPage = 50.obs;
  final totalPages = 0.obs;

  // Statistiques
  final pendingWithdrawals = 0.obs;
  final totalCommissionsPaid = 0.0.obs;
  final activeAffiliates = 0.obs;
  final withdrawalRequests = <WithdrawalRequest>[].obs;

  // Paramètres
  final commissionRate = 0.0.obs;
  final rewardPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAffiliates();
    loadStatistics();
    loadSettings();
  }

  Future<void> loadAffiliates({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (resetPage) {
        currentPage.value = 1;
      }

      final Map<String, dynamic> result = await AdminService.getAllAffiliates(
        page: currentPage.value,
        limit: itemsPerPage.value,
        status: selectedStatus.value,
        query: searchQuery.value,
      );

      final List affiliatesList = result['affiliates'] as List;
      affiliates.value = affiliatesList
          .map((json) => Affiliate.fromJson(json as Map<String, dynamic>))
          .toList();

      totalAffiliates.value = result['total'] as int;
      totalPages.value = (totalAffiliates.value / itemsPerPage.value).ceil();
    } catch (e) {
      print('[AffiliateController] Error loading affiliates: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des affiliés';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAffiliateStatus(
    String affiliateId,
    String status,
    bool isActive,
  ) async {
    try {
      isLoading.value = true;
      await AdminService.updateAffiliateStatus(affiliateId, status, isActive);

      Get.snackbar(
        'Succès',
        'Statut de l\'affilié mis à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );

      loadAffiliates();
    } catch (e) {
      print('[AffiliateController] Error updating affiliate status: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveWithdrawal(String withdrawalId) async {
    try {
      isLoading.value = true;
      await AdminService.approveWithdrawal(withdrawalId);

      Get.snackbar(
        'Succès',
        'Demande de retrait approuvée',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );

      loadStatistics();
      loadWithdrawals();
    } catch (e) {
      print('[AffiliateController] Error approving withdrawal: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'approuver la demande',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCommissionSettings(
    double rate,
    int points,
  ) async {
    try {
      isLoading.value = true;
      await AdminService.configureCommissions(rate, points);

      Get.snackbar(
        'Succès',
        'Paramètres mis à jour',
        backgroundColor: AppColors.success,
        colorText: AppColors.textLight,
      );

      loadSettings();
    } catch (e) {
      print('[AffiliateController] Error updating settings: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour les paramètres',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWithdrawals() async {
    try {
      isLoading.value = true;
      final result = await AdminService.getWithdrawals();
      withdrawalRequests.value =
          result.map((json) => WithdrawalRequest.fromJson(json)).toList();
    } catch (e) {
      print('[AffiliateController] Error loading withdrawals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStatistics() async {
    try {
      final stats = await AdminService.getAffiliateStats();
      pendingWithdrawals.value = stats['pendingWithdrawals'] as int;
      totalCommissionsPaid.value =
          (stats['totalCommissionsPaid'] as num).toDouble();
      activeAffiliates.value = stats['activeAffiliates'] as int;
    } catch (e) {
      print('[AffiliateController] Error loading statistics: $e');
    }
  }

  Future<void> loadSettings() async {
    try {
      final config = await AdminService.getSystemConfig();
      commissionRate.value = (config['commissionRate'] as num).toDouble();
      rewardPoints.value = config['rewardPoints'] as int;
    } catch (e) {
      print('[AffiliateController] Error loading settings: $e');
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status;
    loadAffiliates(resetPage: true);
  }

  void searchAffiliates(String query) {
    searchQuery.value = query;
    loadAffiliates(resetPage: true);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadAffiliates();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadAffiliates();
    }
  }

  void setItemsPerPage(int value) {
    if (value > 0) {
      itemsPerPage.value = value;
      loadAffiliates(resetPage: true);
    }
  }
}
