import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html; // Ajout de cet import
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/address_service.dart'; // Import manquant ajouté
import '../constants.dart';
import './auth_controller.dart';
import 'package:admin/screens/users/components/delete_user_dialog.dart';
import '../types/user_search_filter.dart';

enum ViewMode { list, grid }

enum SortField { name, email, role, createdAt }

enum SortOrder { asc, desc }

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

  // Nouvelles propriétés
  final viewMode = Rx<ViewMode>(ViewMode.list);
  final sortField = Rx<SortField>(SortField.createdAt);
  final sortOrder = Rx<SortOrder>(SortOrder.desc);
  final selectedRoleString = 'all'.obs; // Nouvelle propriété ajoutée
  final selectedFilter = UserSearchFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPreferences();
    loadInitialData();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedViewMode = prefs.getString('user_view_mode');
      if (savedViewMode != null) {
        viewMode.value = ViewMode.values.firstWhere(
          (v) => v.toString() == savedViewMode,
          orElse: () => ViewMode.list,
        );
      }
    } catch (e) {
      print('[UsersController] Error loading preferences: $e');
    }
  }

  Future<void> toggleView(ViewMode mode) async {
    try {
      viewMode.value = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_view_mode', mode.toString());
    } catch (e) {
      print('[UsersController] Error saving view mode: $e');
    }
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
      showErrorSnackbar('Erreur', 'Impossible de charger les statistiques');
    }
  }

  Future<void> fetchUsers({bool resetPage = false}) async {
    try {
      print('[UsersController] Starting fetchUsers...');
      isLoading.value = true;

      if (resetPage) {
        currentPage.value = 1;
      }

      // Correction du paramètre role pour le filtrage
      final roleParam = (selectedRoleString.value == null ||
              selectedRoleString.value == '' ||
              selectedRoleString.value == 'all')
          ? null
          : selectedRoleString.value.toUpperCase();
      print('[UsersController] Fetching with role: $roleParam');

      final result = await UserService.getUsers(
        page: currentPage.value,
        limit: itemsPerPage.value,
        role: roleParam,
        searchQuery: searchQuery.value,
      );

      // Sécurisation : si la réponse n'est pas conforme, on affiche une liste vide
      if (result.items == null || result.items is! List) {
        allUsers.value = [];
        users.value = [];
        totalPages.value = 1;
        totalUsers.value = 0;
        hasError.value = true;
        errorMessage.value =
            'Erreur de chargement des utilisateurs (réponse invalide)';
        return;
      }

      // Stocker tous les utilisateurs paginés
      allUsers.value = result.items;
      users.value = result.items;
      // Ne pas appliquer de filtre local ici !

      totalPages.value = result.totalPages ?? 1;
      totalUsers.value = result.total ?? 0;
      hasError.value = false;
      errorMessage.value = '';

      print('[UsersController] Fetched ${allUsers.length} users');
    } catch (e) {
      print('[UsersController] Error fetching users: $e');
      allUsers.value = [];
      users.value = [];
      totalPages.value = 1;
      totalUsers.value = 0;
      hasError.value = true;
      errorMessage.value = 'Erreur de chargement des utilisateurs';
      showErrorSnackbar(
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
      showErrorSnackbar('Erreur', 'Impossible de charger les statistiques');
    }
  }

  Future<void> updateUser({
    required String userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      print('[UsersController] Updating user $userId');
      isLoading.value = true;

      final updates = <String, dynamic>{
        if (email != null) 'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role.toString().split('.').last,
        if (isActive != null) 'isActive': isActive,
      };

      await UserService.updateUser(userId, updates);
      await loadInitialData();

      Get.back(); // Fermer le dialogue d'édition
      _showSuccessSnackbar('Succès', 'Utilisateur mis à jour avec succès');
    } catch (e) {
      print('[UsersController] Error updating user: $e');
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour l\'utilisateur');
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
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour le statut');
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
      showErrorSnackbar(
          'Erreur', 'Impossible de récupérer les données pour l\'export');
      return [];
    }
  }

  /// Méthode centrale harmonisée pour la recherche, le filtrage et la pagination
  Future<void> fetchUsersOrSearch({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      if (resetPage) currentPage.value = 1;

      // Détection d'un filtre ou d'une recherche avancée
      final hasSearch = searchQuery.value.trim().isNotEmpty;
      final hasRole = selectedRoleString.value != 'ALL';
      final hasAdvanced = selectedStatus.value.isNotEmpty ||
          phoneFilter.value.isNotEmpty ||
          startDate.value != null ||
          endDate.value != null;

      print(
          '[UsersController] fetchUsersOrSearch: rôle envoyé = \'${selectedRoleString.value}\'');

      dynamic result;
      if (hasSearch || hasRole || hasAdvanced) {
        // Recherche avancée (toujours via /api/users/search)
        final filter = selectedFilter.value; // Utilise le filtre sélectionné
        result = await UserService.searchUsers(
          query: searchQuery.value,
          filter: filter.toString().split('.').last,
          role: selectedRoleString.value,
          page: currentPage.value,
          limit: itemsPerPage.value,
        );
      } else {
        // Liste simple (aucun filtre)
        result = await UserService.getUsers(
          page: currentPage.value,
          limit: itemsPerPage.value,
        );
      }

      // Toujours mettre à jour la pagination, même si la liste est vide
      users.value = result.items;
      totalPages.value = result.totalPages ?? 1;
      totalUsers.value = result.total ?? 0;
      currentPage.value = result.currentPage ?? 1;

      // Si la page courante est hors limites (ex: page 2 mais totalPages=1), revenir à la page 1
      if (currentPage.value > totalPages.value && totalPages.value > 0) {
        currentPage.value = 1;
        // Relancer la requête sur la page 1
        await fetchUsersOrSearch(resetPage: true);
        return;
      }

      hasError.value = false;
      errorMessage.value = '';
    } catch (e) {
      users.value = [];
      totalPages.value = 1;
      totalUsers.value = 0;
      hasError.value = true;
      errorMessage.value = 'Erreur de chargement des utilisateurs';
      showErrorSnackbar('Erreur', 'Impossible de charger les utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  // Rediriger toutes les actions vers la méthode centrale
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchUsersOrSearch();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchUsersOrSearch();
    }
  }

  void setItemsPerPage(int value) {
    if (value != itemsPerPage.value) {
      itemsPerPage.value = value;
      currentPage.value = 1;
      fetchUsersOrSearch(resetPage: true);
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchUsersOrSearch();
    }
  }

  Future<void> filterByRole(UserRole? role) async {
    try {
      isLoading.value = true;
      selectedRole.value = role;
      // Toujours stocker en MAJUSCULES pour l'API
      selectedRoleString.value =
          role != null ? role.toString().split('.').last.toUpperCase() : 'ALL';
      print(
          '[UsersController] Filtrage par rôle: \'${selectedRoleString.value}\'');
      currentPage.value = 1;
      await fetchUsersOrSearch(resetPage: true);
    } catch (e) {
      showErrorSnackbar('Erreur', 'Impossible de filtrer les utilisateurs');
    } finally {
      isLoading.value = false;
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    fetchUsersOrSearch(resetPage: true);
  }

  void setStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchUsersOrSearch(resetPage: true);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    fetchUsersOrSearch(resetPage: true);
  }

  void setPhoneFilter(String phone) {
    phoneFilter.value = phone;
    fetchUsersOrSearch(resetPage: true);
  }

  void resetFilters() {
    selectedStatus.value = '';
    startDate.value = null;
    endDate.value = null;
    phoneFilter.value = '';
    selectedRole.value = null;
    selectedRoleString.value = 'all';
    searchQuery.value = '';
    fetchUsersOrSearch(resetPage: true);
  }

  // Méthodes utilitaires
  void sortUsers(SortField field) {
    if (sortField.value == field) {
      sortOrder.value =
          sortOrder.value == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    } else {
      sortField.value = field;
      sortOrder.value = SortOrder.asc;
    }

    _applySorting();
  }

  void _applySorting() {
    final multiplier = sortOrder.value == SortOrder.asc ? 1 : -1;

    filteredUsers.sort((a, b) {
      switch (sortField.value) {
        case SortField.name:
          return multiplier *
              '${a.lastName} ${a.firstName}'
                  .compareTo('${b.lastName} ${b.firstName}');
        case SortField.email:
          return multiplier * a.email.compareTo(b.email);
        case SortField.role:
          return multiplier * a.role.toString().compareTo(b.role.toString());
        case SortField.createdAt:
          return multiplier * a.createdAt.compareTo(b.createdAt);
      }
    });

    // Mettre à jour la liste principale
    users.value = filteredUsers;
  }

  Future<void> exportFilteredUsers() async {
    try {
      isLoading.value = true;

      final data = filteredUsers
          .map((user) => {
                'ID': user.id,
                'Nom': user.lastName,
                'Prénom': user.firstName,
                'Email': user.email,
                'Rôle': user.role.toString().split('.').last,
                'Statut': user.isActive ? 'Actif' : 'Inactif',
                'Date création':
                    DateFormat('dd/MM/yyyy').format(user.createdAt),
              })
          .toList();

      // Laissez l'implémentation de l'export au platform-specific code
      await exportToCSV(data);

      _showSuccessSnackbar('Succès', 'Données exportées avec succès');
    } catch (e) {
      showErrorSnackbar('Erreur', 'Impossible d\'exporter les données');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToCSV(List<Map<String, dynamic>> data) async {
    try {
      // Créer l'en-tête CSV
      final headers = data.first.keys.toList();
      String csvContent = headers.join(',') + '\n';

      // Ajouter les données
      for (var row in data) {
        csvContent +=
            headers.map((header) => row[header].toString()).join(',') + '\n';
      }

      // Pour le web, créer un blob et télécharger
      if (GetPlatform.isWeb) {
        final blob = html.Blob([csvContent], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute(
              'download', 'users_${DateTime.now().toIso8601String()}.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
      // Pour mobile/desktop, utiliser path_provider et file
      else {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/users_${DateTime.now().toIso8601String()}.csv';
        final file = File(path);
        await file.writeAsString(csvContent);

        // Ouvrir le fichier avec une application externe
        if (await file.exists()) {
          await OpenFile.open(path);
        }
      }

      _showSuccessSnackbar(
          'Export réussi', 'Le fichier CSV a été créé avec succès');
    } catch (e) {
      print('[UsersController] Error exporting to CSV: $e');
      showErrorSnackbar(
          'Erreur d\'export', 'Impossible d\'exporter les données en CSV');
    }
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
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      animationDuration: Duration(milliseconds: 350),
      isDismissible: true,
      overlayBlur: 2.5,
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  void showErrorSnackbar(String title, String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
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
      showErrorSnackbar('Erreur', e.toString());
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

  // Recherche avancée multi-critères (API, pagination, multi-rôles)
  Future<void> advancedUserSearch(
      String query, UserSearchFilter filter, String role,
      {int page = 1, int limit = 10}) async {
    isLoading.value = true;
    try {
      final filterString = filter.toString().split('.').last;
      final result = await UserService.searchUsers(
        query: query,
        filter: filterString,
        role: role,
        page: page,
        limit: limit,
      );
      filteredUsers.value = result.items;
      totalPages.value = result.totalPages;
      totalUsers.value = result.total;
      currentPage.value = result.currentPage;
    } catch (e) {
      print('[UsersController] advancedUserSearch error: $e');
      filteredUsers.value = [];
      totalPages.value = 1;
      totalUsers.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère les adresses d'un utilisateur cible (client, affilié, etc)
  Future<List<dynamic>> getUserAddresses(String userId) async {
    try {
      final addresses = await UserService.getUserAddresses(userId);
      // On retourne une liste de Map pour compatibilité avec l'affichage dynamique
      return addresses.map((a) => a.toJson()).toList();
    } catch (e) {
      print('[UsersController] getUserAddresses error: $e');
      rethrow;
    }
  }

  /// Supprime une adresse d'un utilisateur cible
  Future<void> deleteUserAddress(String addressId, String userId) async {
    try {
      // Correction : utilise la méthode deleteAddress sans paramètre supplémentaire
      await AddressService.deleteAddress(addressId);
    } catch (e) {
      print('[UsersController] deleteUserAddress error: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    print('[UsersController] Disposing');
    super.onClose();
  }
}
