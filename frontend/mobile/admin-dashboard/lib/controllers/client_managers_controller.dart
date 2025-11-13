import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/services/client_manager_service.dart';
import 'package:admin/constants.dart';

/// Controller pour la gestion des Client Managers (SVA)
class ClientManagersController extends GetxController {
  // ============================================
  // ÉTATS OBSERVABLES
  // ============================================

  // Liste des agents
  final RxList<AgentStats> agents = <AgentStats>[].obs;

  // États de chargement
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 10.obs;

  // Filtres
  final searchQuery = ''.obs;
  final sortBy = 'total_revenue'.obs;
  final sortOrder = 'desc'.obs;

  // Statistiques globales
  final totalAgents = 0.obs;
  final totalClientsAssigned = 0.obs;
  final totalOrdersGenerated = 0.obs;
  final totalRevenueGenerated = 0.0.obs;

  // Dashboard d'un agent
  final Rxn<AgentDashboard> selectedAgentDashboard = Rxn<AgentDashboard>();
  final RxBool isDashboardLoading = false.obs;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    print('[ClientManagersController] onInit: Initialisation');
    fetchAgents();
  }

  @override
  void onClose() {
    print('[ClientManagersController] onClose: Nettoyage');
    super.onClose();
  }

  // ============================================
  // MÉTHODES PRINCIPALES
  // ============================================

  /// Récupère la liste de tous les agents disponibles (ADMIN et SUPER_ADMIN)
  Future<void> fetchAgents({bool resetPage = false}) async {
    try {
      print('[ClientManagersController] fetchAgents: Début du chargement');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (resetPage) {
        currentPage.value = 1;
      }

      // Appel API - Récupérer TOUS les agents disponibles
      final result = await ClientManagerService.getAvailableAgents();

      agents.value = result;
      _calculateGlobalStats();

      print('[ClientManagersController] fetchAgents: ${agents.length} agents chargés');
    } catch (e) {
      print('[ClientManagersController] fetchAgents: Erreur - $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      agents.value = [];
      _showErrorSnackbar('Erreur', 'Impossible de charger les agents');
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère le dashboard détaillé d'un agent
  Future<void> fetchAgentDashboard(String agentId) async {
    try {
      print('[ClientManagersController] fetchAgentDashboard: Chargement pour $agentId');
      isDashboardLoading.value = true;

      final dashboard = await ClientManagerService.getAgentDashboard(agentId);
      selectedAgentDashboard.value = dashboard;

      print('[ClientManagersController] fetchAgentDashboard: Dashboard chargé');
    } catch (e) {
      print('[ClientManagersController] fetchAgentDashboard: Erreur - $e');
      _showErrorSnackbar('Erreur', 'Impossible de charger le dashboard');
    } finally {
      isDashboardLoading.value = false;
    }
  }

  /// Recherche les agents par nom ou email
  void searchAgents(String query) {
    print('[ClientManagersController] searchAgents: Recherche "$query"');
    searchQuery.value = query;
    currentPage.value = 1;
    // La recherche est effectuée localement sur la liste chargée
    // ou on peut refaire un appel API si nécessaire
  }

  /// Change le tri des agents
  void changeSorting(String field, String order) {
    print('[ClientManagersController] changeSorting: $field ($order)');
    sortBy.value = field;
    sortOrder.value = order;
    currentPage.value = 1;
    fetchAgents(resetPage: true);
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    print('[ClientManagersController] resetFilters: Réinitialisation');
    searchQuery.value = '';
    sortBy.value = 'total_revenue';
    sortOrder.value = 'desc';
    currentPage.value = 1;
    fetchAgents(resetPage: true);
  }

  /// Passe à la page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      print('[ClientManagersController] nextPage: Page ${currentPage.value}');
    }
  }

  /// Passe à la page précédente
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      print('[ClientManagersController] previousPage: Page ${currentPage.value}');
    }
  }

  /// Va à une page spécifique
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      print('[ClientManagersController] goToPage: Page $page');
    }
  }

  /// Change le nombre d'éléments par page
  void setItemsPerPage(int value) {
    if (value != itemsPerPage.value) {
      itemsPerPage.value = value;
      currentPage.value = 1;
      print('[ClientManagersController] setItemsPerPage: $value');
    }
  }

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  /// Calcule les statistiques globales à partir de la liste des agents
  void _calculateGlobalStats() {
    try {
      totalAgents.value = agents.length;
      totalClientsAssigned.value =
          agents.fold(0, (sum, agent) => sum + agent.totalClients);
      totalOrdersGenerated.value =
          agents.fold(0, (sum, agent) => sum + agent.totalOrders);
      totalRevenueGenerated.value =
          agents.fold(0.0, (sum, agent) => sum + agent.totalRevenue);

      print('[ClientManagersController] Stats calculées:');
      print('  - Agents: $totalAgents');
      print('  - Clients: $totalClientsAssigned');
      print('  - Commandes: $totalOrdersGenerated');
      print('  - Revenus: $totalRevenueGenerated');
    } catch (e) {
      print('[ClientManagersController] Erreur lors du calcul des stats: $e');
    }
  }

  /// Retourne la liste des agents filtrés par recherche
  List<AgentStats> get filteredAgents {
    if (searchQuery.value.isEmpty) {
      return agents;
    }

    final query = searchQuery.value.toLowerCase();
    return agents
        .where((agent) =>
            agent.name.toLowerCase().contains(query) ||
            agent.email.toLowerCase().contains(query))
        .toList();
  }

  /// Retourne la liste des agents paginés
  List<AgentStats> get paginatedAgents {
    final filtered = filteredAgents;
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;

    totalPages.value = (filtered.length / itemsPerPage.value).ceil();

    if (startIndex >= filtered.length) {
      return [];
    }

    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  // ============================================
  // NOTIFICATIONS
  // ============================================

  void _showErrorSnackbar(String title, String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.85),
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      isDismissible: true,
      overlayBlur: 2.5,
      boxShadows: [
        const BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 350),
      isDismissible: true,
      overlayBlur: 2.5,
      boxShadows: [
        const BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
