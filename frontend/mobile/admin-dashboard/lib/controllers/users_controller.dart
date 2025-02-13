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
    await Future.wait([
      fetchUsers(),
      fetchUserStats(),
    ]);
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
      totalUsers.value = result.total;

      _updateRoleCounts();
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

  @override
  void onClose() {
    print('[UsersController] Disposing');
    super.onClose();
  }
}
