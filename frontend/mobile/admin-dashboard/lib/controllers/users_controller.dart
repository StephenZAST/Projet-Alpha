import 'package:get/get.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UsersController extends GetxController {
  // État de chargement et erreurs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Données des utilisateurs
  final users = <User>[].obs;
  final selectedUser = Rxn<User>();
  final totalUsers = 0.obs;

  // État de pagination
  final currentPage = 1.obs;
  final itemsPerPage = 50.obs;
  final totalPages = 0.obs;

  // Filtres
  final selectedRole = Rxn<UserRole>();
  final searchQuery = ''.obs;

  // Statistiques
  final clientCount = 0.obs;
  final adminCount = 0.obs;
  final affiliateCount = 0.obs;

  Future<void> loadUsers({bool resetPage = false}) async {
    try {
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
        query: searchQuery.value,
      );

      users.value = result.users;
      totalUsers.value = result.total;
      totalPages.value = (result.total / itemsPerPage.value).ceil();

      // Mise à jour des compteurs par rôle
      _updateRoleCounts();
    } catch (e) {
      print('[UsersController] Error loading users: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des utilisateurs';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserDetails(String userId) async {
    try {
      isLoading.value = true;
      final user = await UserService.getUserById(userId);
      selectedUser.value = user;
    } catch (e) {
      print('[UsersController] Error loading user details: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les détails de l\'utilisateur',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      isLoading.value = true;
      await UserService.updateUserRole(userId, newRole);
      loadUsers();
      Get.back(); // Ferme le dialogue de détails
      Get.snackbar(
        'Succès',
        'Rôle mis à jour avec succès',
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } catch (e) {
      print('[UsersController] Error updating user role: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le rôle',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      isLoading.value = true;
      await UserService.updateUserStatus(userId, isActive);
      loadUsers();
      Get.back(); // Ferme le dialogue de détails
      Get.snackbar(
        'Succès',
        'Statut mis à jour avec succès',
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } catch (e) {
      print('[UsersController] Error updating user status: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterByRole(UserRole? role) {
    selectedRole.value = role;
    loadUsers(resetPage: true);
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    loadUsers(resetPage: true);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadUsers();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadUsers();
    }
  }

  void setItemsPerPage(int value) {
    if (value > 0) {
      itemsPerPage.value = value;
      loadUsers(resetPage: true);
    }
  }

  void _updateRoleCounts() {
    clientCount.value = users.where((u) => u.role == 'CLIENT').length;
    adminCount.value = users.where((u) => u.role == 'ADMIN').length;
    affiliateCount.value = users.where((u) => u.role == 'AFFILIATE').length;
  }
}
