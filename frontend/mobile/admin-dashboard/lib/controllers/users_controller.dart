import 'package:admin/screens/users/components/delete_user_dialog.dart';
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

  // Ajout des stats globales
  final totalClientCount = 0.obs;
  final totalAffiliateCount = 0.obs;
  final totalAdminCount = 0.obs;
  final totalUsersCount = 0.obs;

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

  // Ajouter une nouvelle variable pour stocker tous les utilisateurs
  final allUsers = <User>[].obs;
  final filteredUsers = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('[UsersController] Initializing');
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadGlobalStats(),
      fetchUsers(),
    ]);
  }

  Future<void> loadGlobalStats() async {
    try {
      print('[UsersController] Loading global stats...');
      final stats = await UserService.getUserStats();

      print('[UsersController] Received stats: $stats'); // Debug

      // Mise à jour des compteurs globaux
      totalClientCount.value = stats['clientCount'] ?? 0;
      totalAffiliateCount.value = stats['affiliateCount'] ?? 0;
      totalAdminCount.value = stats['adminCount'] ?? 0;
      totalUsersCount.value = stats['total'] ?? 0;

      print(
          '[UsersController] Updated stats - Total: ${totalUsersCount.value}'); // Debug
    } catch (e) {
      print('[UsersController] Error loading global stats: $e');
      _showErrorSnackbar('Erreur', 'Impossible de charger les statistiques');
    }
  }

  Future<void> fetchUsers({bool resetPage = false}) async {
    try {
      print('[UsersController] Starting fetchUsers...'); // Ajout du log
      isLoading.value = true;

      if (resetPage) {
        currentPage.value = 1;
      }

      // Correction du paramètre role pour le filtrage
      final roleParam = selectedRole.value?.toString().split('.').last;
      print('[UsersController] Fetching with role: $roleParam'); // Ajout du log

      final result = await UserService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        role: roleParam,
        searchQuery: searchQuery.value,
      );

      // Stocker tous les utilisateurs
      allUsers.value = result.items;
      // Appliquer le filtre actuel
      _applyFilters();

      totalPages.value = result.totalPages;
      totalUsers.value = result.total;

      print(
          '[UsersController] Fetched ${allUsers.length} users'); // Ajout du log
    } catch (e) {
      print('[UsersController] Error fetching users: $e');
      _showErrorSnackbar(
          'Erreur de chargement', 'Impossible de charger les utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserStats() async {
    try {
      print('[UsersController] Fetching user stats...');
      final stats = await UserService.getUserStats();

      clientCount.value = stats['clientCount'] ?? 0;
      affiliateCount.value = stats['affiliateCount'] ?? 0;
      adminCount.value = stats['adminCount'] ?? 0;
    } catch (e) {
      print('[UsersController] Error fetching stats: $e');
      _showErrorSnackbar('Erreur', 'Impossible de charger les statistiques');
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
      await loadInitialData();

      Get.back(); // Fermer le dialogue d'édition
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
  Future<void> filterByRole(UserRole? role) async {
    try {
      isLoading.value = true;
      print('[UsersController] Filtering by role: ${role?.toString()}');

      selectedRole.value = role;
      currentPage.value = 1;

      // Utiliser la méthode toApiString() pour le rôle
      final roleString = role?.toApiString();
      print('[UsersController] Formatted role for API: $roleString');

      final result = await UserService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        role: roleString,
        searchQuery: searchQuery.value,
      );

      users.value = result.items;
      totalPages.value = result.totalPages;
      totalUsers.value = result.total;

      // Appliquer le filtre localement
      _applyFilters();

      print('[UsersController] Filter applied successfully');
    } catch (e) {
      print('[UsersController] Error filtering by role: $e');
      _showErrorSnackbar('Erreur', 'Impossible de filtrer les utilisateurs');
    } finally {
      isLoading.value = false;
    }
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
  void _updateLocalCounts() {
    clientCount.value = users.where((u) => u.role == UserRole.CLIENT).length;
    adminCount.value = users
        .where(
            (u) => u.role == UserRole.ADMIN || u.role == UserRole.SUPER_ADMIN)
        .length;
    affiliateCount.value =
        users.where((u) => u.role == UserRole.AFFILIATE).length;
  }

  void _applyFilters() {
    if (selectedRole.value == null) {
      // Si aucun filtre n'est sélectionné, afficher tous les utilisateurs
      filteredUsers.value = allUsers;
      users.value = allUsers;
    } else {
      // Filtrer les utilisateurs selon le rôle sélectionné
      filteredUsers.value = allUsers.where((user) {
        return user.role == selectedRole.value;
      }).toList();
      users.value = filteredUsers;
    }

    // Mettre à jour les compteurs locaux
    _updateLocalCounts();

    print('[UsersController] Filtered users: ${filteredUsers.length}');
    print('[UsersController] Selected role: ${selectedRole.value}');
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
      await UserService.createUser(userData);
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
        await fetchUsers();
        _showSuccessSnackbar('Succès', 'Utilisateur supprimé avec succès');
      });
    }
  }

  @override
  void onClose() {
    print('[UsersController] Disposing');
    super.onClose();
  }
}
