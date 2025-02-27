import 'dart:async';

import 'package:admin/screens/users/components/delete_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../constants.dart';
import './auth_controller.dart';

class UsersController extends GetxController {
  // État observable
  final users = <User>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final selectedUser = Rxn<User>();

  // Statistiques
  final clientCount = 0.obs;
  final affiliateCount = 0.obs;
  final adminCount = 0.obs;
  final totalUsers = 0.obs;

  // Nouvelles variables pour les stats globales
  final totalUserCount = 0.obs;
  final totalClientCount = 0.obs;
  final totalAffiliateCount = 0.obs;
  final totalAdminCount = 0.obs;

  // Ajout d'un debouncer pour éviter les rafraîchissements trop fréquents
  final _statsDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  final _isLoadingStats = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 10.obs;

  // Filtres
  final selectedRole = Rxn<UserRole>();
  final searchQuery = ''.obs;

  // Ajout des propriétés manquantes pour les filtres avancés
  final selectedStatus = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final phoneFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('[UsersController] Initializing');
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Charger les statistiques et les utilisateurs en parallèle
      await Future.wait([
        loadGlobalStats(),
        fetchUsers(),
      ]);
    } catch (e) {
      print('[UsersController] Error loading initial data: $e');
      _showErrorSnackbar(
          'Erreur', 'Impossible de charger les données initiales');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGlobalStats() async {
    try {
      print('[UsersController] Loading global stats...');
      if (_isLoadingStats.value) return;

      _isLoadingStats.value = true;
      final stats = await UserService.getUserStats();

      print('[UsersController] Received stats: $stats'); // Debug log

      // Mise à jour atomique des statistiques
      _updateGlobalStats({
        'total': stats['total'],
        'clientCount': stats['clientCount'],
        'affiliateCount': stats['affiliateCount'],
        'adminCount': stats['adminCount']
      });

      print(
          '[UsersController] Stats updated successfully: ${totalUserCount.value}, ${totalClientCount.value}, ${totalAffiliateCount.value}, ${totalAdminCount.value}');
    } catch (e) {
      print('[UsersController] Error loading global stats: $e');
      _handleStatsError(e);
    } finally {
      _isLoadingStats.value = false;
    }
  }

  void _updateGlobalStats(Map<String, dynamic> stats) {
    try {
      // Mise à jour atomique pour éviter les incohérences
      Get.defaultDialog(
        barrierDismissible: false,
        title: 'Mise à jour des statistiques',
        content: CircularProgressIndicator(),
      );

      totalUserCount.value = stats['total'] ?? totalUserCount.value;
      totalClientCount.value = stats['clientCount'] ?? totalClientCount.value;
      totalAffiliateCount.value =
          stats['affiliateCount'] ?? totalAffiliateCount.value;
      totalAdminCount.value = stats['adminCount'] ?? totalAdminCount.value;

      Get.back();
    } catch (e) {
      print('[UsersController] Error updating global stats: $e');
      Get.back();
      _handleStatsError(e);
    }
  }

  void _handleStatsError(dynamic error) {
    errorMessage.value = 'Erreur lors du chargement des statistiques globales';
    _showErrorSnackbar('Erreur de chargement',
        'Impossible de charger les statistiques globales. Réessayez plus tard.');
  }

  // Méthode utilitaire pour rafraîchir les stats avec debounce
  void refreshStats() {
    _statsDebouncer.call(() => loadGlobalStats());
  }

  Future<void> fetchUsers({bool resetPage = false}) async {
    try {
      print('[UsersController] Fetching users...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (resetPage) {
        currentPage.value = 1;
      }

      final result = await UserService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        role: selectedRole.value?.toString().split('.').last,
        searchQuery: searchQuery.value, // Changé de query à searchQuery
      );

      users.value = result.items; // Utiliser items au lieu de users
      totalPages.value = result.totalPages;

      // Mettre à jour uniquement les compteurs locaux
      _updateLocalCounts();
    } catch (e) {
      print('[UsersController] Error fetching users: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des utilisateurs';
      _showErrorSnackbar(
          'Erreur de chargement', 'Impossible de charger les utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateLocalCounts() {
    clientCount.value = users.where((u) => u.role == UserRole.CLIENT).length;
    adminCount.value = users
        .where(
            (u) => u.role == UserRole.ADMIN || u.role == UserRole.SUPER_ADMIN)
        .length;
    affiliateCount.value =
        users.where((u) => u.role == UserRole.AFFILIATE).length;
  }

  Future<void> fetchUserStats() async {
    try {
      print('[UsersController] Fetching user stats...');
      isLoading.value = true;
      hasError.value = false;

      final stats = await UserService.getUserStats();

      // Mise à jour sécurisée des statistiques
      clientCount.value = stats['clientCount'] ?? 0;
      affiliateCount.value = stats['affiliateCount'] ?? 0;
      adminCount.value =
          (stats['adminCount'] ?? 0) + (stats['superAdminCount'] ?? 0);
      totalUsers.value = stats['total'] ?? 0;

      print('[UsersController] Stats fetched successfully: $stats');
    } catch (e) {
      print('[UsersController] Error fetching stats: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des statistiques';
      _showErrorSnackbar('Erreur de chargement',
          'Impossible de charger les statistiques des utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser({
    required String userId,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      print('[UsersController] Updating user $userId');
      isLoading.value = true;

      final updates = {
        if (role != null) 'role': role.toString().split('.').last,
        if (isActive != null) 'isActive': isActive,
      };

      await UserService.updateUser(userId, updates);
      refreshStats(); // Utilisation du debouncer
      await fetchUsers();

      Get.back();
      _showSuccessSnackbar('Succès', 'Utilisateur mis à jour avec succès');
    } catch (e) {
      print('[UsersController] Error updating user: $e');
      _showErrorSnackbar(
          'Erreur', 'Impossible de mettre à jour l\'utilisateur');
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour mettre à jour le statut d'un utilisateur
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      isLoading.value = true;
      await UserService.updateUserStatus(userId, isActive);
      await fetchUsers();
      _showSuccessSnackbar('Succès', 'Statut mis à jour avec succès');
    } catch (e) {
      _showErrorSnackbar('Erreur', 'Impossible de mettre à jour le statut');
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour récupérer tous les utilisateurs pour l'export
  Future<List<User>> getAllUsersForExport() async {
    try {
      final response = await UserService.getUsers(
        page: 1,
        limit: 1000, // Grande limite pour récupérer tous les utilisateurs
        role: selectedRole.value?.toString().split('.').last,
        searchQuery: searchQuery.value,
      );
      return response.items;
    } catch (e) {
      _showErrorSnackbar(
          'Erreur', 'Impossible de récupérer les données pour l\'export');
      return [];
    }
  }

  // Méthodes de pagination
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchUsers();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchUsers();
    }
  }

  void setItemsPerPage(int value) {
    if (value != itemsPerPage.value) {
      itemsPerPage.value = value;
      currentPage.value = 1; // Reset to first page when changing items per page
      fetchUsers();
    }
  }

  // Méthodes de filtrage
  void filterByRole(UserRole? role) {
    selectedRole.value = role;
    fetchUsers(resetPage: true);
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    fetchUsers(resetPage: true);
  }

  // Méthodes pour les filtres avancés
  void setStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchUsers(resetPage: true);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    fetchUsers(resetPage: true);
  }

  void setPhoneFilter(String phone) {
    phoneFilter.value = phone;
    fetchUsers(resetPage: true);
  }

  void resetFilters() {
    selectedStatus.value = '';
    startDate.value = null;
    endDate.value = null;
    phoneFilter.value = '';
    selectedRole.value = null;
    searchQuery.value = '';
    fetchUsers(resetPage: true);
  }

  // Méthodes utilitaires
  void _updateRoleCounts() {
    clientCount.value = users.where((u) => u.role == UserRole.CLIENT).length;
    adminCount.value = users
        .where(
            (u) => u.role == UserRole.ADMIN || u.role == UserRole.SUPER_ADMIN)
        .length;
    affiliateCount.value =
        users.where((u) => u.role == UserRole.AFFILIATE).length;
  }

  // Permissions
  bool canManageUser(User user) {
    final currentUser = Get.find<AuthController>().user.value;
    if (currentUser == null) return false;

    if (currentUser.role == UserRole.SUPER_ADMIN) return true;
    if (currentUser.role == UserRole.ADMIN) {
      return user.role != UserRole.SUPER_ADMIN && user.role != UserRole.ADMIN;
    }

    return false;
  }

  // Notifications
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4),
    );
  }

  Future<void> safeCall(Future<void> Function() action) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      await action();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      _showErrorSnackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await safeCall(() async {
      final createdUser = await UserService.createUser(userData);
      refreshStats(); // Utilisation du debouncer
      await fetchUsers();
      Get.back();
      _showSuccessSnackbar('Succès', 'Utilisateur créé avec succès');
    });
  }

  Future<void> deleteUser(String id, String userName) async {
    final confirmed = await Get.dialog<bool>(
      DeleteUserDialog(userId: id, userName: userName),
    );

    if (confirmed == true) {
      await safeCall(() async {
        await UserService.deleteUser(id);
        refreshStats(); // Utilisation du debouncer
        await fetchUsers();
        _showSuccessSnackbar('Succès', 'Utilisateur supprimé avec succès');
      });
    }
  }

  @override
  void onClose() {
    _statsDebouncer.dispose(); // Nettoyage du debouncer
    print('[UsersController] Disposing');
    super.onClose();
  }
}

// Classe utilitaire pour le debouncing
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
