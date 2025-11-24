import 'package:admin/models/paginated_response.dart';
import 'package:admin/services/api_service.dart';
import '../models/client_manager.dart';

/// Service pour gérer les appels API liés aux Client Managers (SVA)
class ClientManagerService {
  static const String baseUrl = '/admin/client-managers';

  /// Récupère TOUS les agents disponibles (ADMIN et SUPER_ADMIN)
  /// GET /api/admin/client-managers/available-agents
  static Future<List<AgentStats>> getAvailableAgents() async {
    try {
      print('[ClientManagerService] Fetching all available agents...');
      
      final response = await ApiService().get(
        '$baseUrl/available-agents',
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data != null && data['success'] == true && data['data'] != null) {
        final List<dynamic> agentsData = data['data']['agents'] ?? [];
        final agents = agentsData
            .map((agent) => AgentStats.fromJson(agent))
            .toList();
        
        print('[ClientManagerService] Fetched ${agents.length} available agents');
        return agents;
      } else {
        throw Exception(data?['error'] ?? 'Erreur lors du chargement des agents');
      }
    } catch (e) {
      print('[ClientManagerService] Error fetching available agents: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques de tous les agents
  /// GET /api/admin/client-managers/agents/stats
  static Future<List<AgentStats>> getAllAgentsStats({
    String sortBy = 'total_revenue',
    String order = 'desc',
  }) async {
    try {
      print('[ClientManagerService] Fetching all agents stats...');
      
      final response = await ApiService().get(
        '$baseUrl/agents/stats',
        queryParameters: {
          'sort': sortBy,
          'order': order,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data != null && data['success'] == true && data['data'] != null) {
        final List<dynamic> agentsData = data['data']['agents'] ?? [];
        final agents = agentsData
            .map((agent) => AgentStats.fromJson(agent))
            .toList();
        
        print('[ClientManagerService] Fetched ${agents.length} agents');
        return agents;
      } else {
        throw Exception(data?['error'] ?? 'Erreur lors du chargement des statistiques');
      }
    } catch (e) {
      print('[ClientManagerService] Error fetching agents stats: $e');
      rethrow;
    }
  }

  /// Récupère le dashboard d'un agent
  /// GET /api/admin/client-managers/agent/:agentId/dashboard
  static Future<AgentDashboard> getAgentDashboard(String agentId) async {
    try {
      print('[ClientManagerService] Fetching dashboard for agent: $agentId');
      
      final response = await ApiService().get(
        '$baseUrl/agent/$agentId/dashboard',
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data != null && data['success'] == true && data['data'] != null) {
        final dashboard = AgentDashboard.fromJson(data['data']);
        print('[ClientManagerService] Dashboard fetched successfully');
        return dashboard;
      } else {
        throw Exception(data?['error'] ?? 'Erreur lors du chargement du dashboard');
      }
    } catch (e) {
      print('[ClientManagerService] Error fetching dashboard: $e');
      rethrow;
    }
  }

  /// Récupère les clients d'un agent avec pagination
  /// GET /api/admin/client-managers/agent/:agentId?page=&limit=
  static Future<PaginatedResponse<ClientInfo>> getAgentClients(
    String agentId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[ClientManagerService] Fetching clients for agent: $agentId (page: $page, limit: $limit)');
      
      final response = await ApiService().get(
        '$baseUrl/agent/$agentId',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      
      if (responseData != null && responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        final List<dynamic> clientsData = data['clients'] ?? [];
        final paginationData = data['pagination'] ?? {};

        final clients = clientsData
            .map((client) => ClientInfo.fromJson(client))
            .toList();

        final paginatedResponse = PaginatedResponse<ClientInfo>(
          items: clients,
          total: paginationData['total'] ?? 0,
          currentPage: paginationData['page'] ?? 1,
          totalPages: paginationData['pages'] ?? 1,
        );

        print('[ClientManagerService] Fetched ${clients.length} clients');
        return paginatedResponse;
      } else {
        throw Exception(responseData?['error'] ?? 'Erreur lors du chargement des clients');
      }
    } catch (e) {
      print('[ClientManagerService] Error fetching agent clients: $e');
      rethrow;
    }
  }

  /// Assigne un client à un agent
  /// POST /api/admin/client-managers/assign
  static Future<void> assignClient({
    required String agentId,
    required String clientId,
    String? notes,
  }) async {
    try {
      print('[ClientManagerService] Assigning client $clientId to agent $agentId');
      
      final response = await ApiService().post(
        '$baseUrl/assign',
        data: {
          'agent_id': agentId,
          'client_id': clientId,
          if (notes != null) 'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Erreur lors de l\'assignation');
      }

      print('[ClientManagerService] Client assigned successfully');
    } catch (e) {
      print('[ClientManagerService] Error assigning client: $e');
      rethrow;
    }
  }

  /// Retire un client d'un agent
  /// DELETE /api/admin/client-managers/:managerId
  static Future<void> unassignClient(String managerId) async {
    try {
      print('[ClientManagerService] Unassigning client manager: $managerId');
      
      final response = await ApiService().delete(
        '$baseUrl/$managerId',
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Erreur lors du retrait');
      }

      print('[ClientManagerService] Client unassigned successfully');
    } catch (e) {
      print('[ClientManagerService] Error unassigning client: $e');
      rethrow;
    }
  }

  /// Met à jour les notes d'un client
  /// PATCH /api/admin/client-managers/:managerId
  static Future<void> updateClientNotes(String managerId, String notes) async {
    try {
      print('[ClientManagerService] Updating notes for manager: $managerId');
      
      final response = await ApiService().patch(
        '$baseUrl/$managerId',
        data: {
          'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Erreur lors de la mise à jour');
      }

      print('[ClientManagerService] Notes updated successfully');
    } catch (e) {
      print('[ClientManagerService] Error updating notes: $e');
      rethrow;
    }
  }

  /// Récupère les clients inactifs d'un agent
  /// GET /api/admin/client-managers/agent/:agentId/inactive?days=7
  static Future<List<InactiveClient>> getInactiveClients(
    String agentId, {
    int days = 7,
  }) async {
    try {
      print('[ClientManagerService] Fetching inactive clients for agent: $agentId (days: $days)');
      
      final response = await ApiService().get(
        '$baseUrl/agent/$agentId/inactive',
        queryParameters: {
          'days': days.toString(),
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      
      if (responseData != null && responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> clientsData = responseData['data']['inactive_clients'] ?? [];
        final clients = clientsData
            .map((client) => InactiveClient.fromJson(client))
            .toList();
        
        print('[ClientManagerService] Fetched ${clients.length} inactive clients');
        return clients;
      } else {
        throw Exception(responseData?['error'] ?? 'Erreur lors du chargement des clients inactifs');
      }
    } catch (e) {
      print('[ClientManagerService] Error fetching inactive clients: $e');
      rethrow;
    }
  }
}
