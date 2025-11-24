/**
 * 👤 Contrôleur: Client Manager Admin
 * Endpoints pour gérer les liaisons agent-client
 * 
 * Endpoints :
 * - POST /api/admin/client-managers/assign - Assigner un client
 * - DELETE /api/admin/client-managers/:managerId - Retirer un client
 * - GET /api/admin/client-managers/agent/:agentId - Récupérer les clients
 * - GET /api/admin/client-managers/agent/:agentId/dashboard - Dashboard
 * - GET /api/admin/client-managers/agents/stats - Stats de tous les agents
 * - PATCH /api/admin/client-managers/:managerId - Mettre à jour les notes
 */

import { Request, Response } from 'express';
import { ClientManagerService } from '../../services/clientManager.service';
import { ClientManagerStatsService } from '../../services/clientManagerStats.service';

export class ClientManagerController {
  /**
   * POST /api/admin/client-managers/assign
   * Assigner un client à un agent
   */
  static async assignClient(req: Request, res: Response): Promise<void> {
    try {
      const { agent_id, client_id, notes } = req.body;
      const adminId = (req as any).user?.id;

      // Validation
      if (!agent_id || !client_id) {
        res.status(400).json({
          success: false,
          error: 'agent_id and client_id are required'
        });
        return;
      }

      if (!adminId) {
        res.status(401).json({
          success: false,
          error: 'Unauthorized'
        });
        return;
      }

      // Assigner le client
      const clientManager = await ClientManagerService.assignClientToAgent(
        agent_id,
        client_id,
        adminId,
        notes
      );

      // Mettre à jour les stats
      await ClientManagerStatsService.updateAgentStats(agent_id);

      res.status(201).json({
        success: true,
        data: clientManager
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error assigning client:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to assign client'
      });
    }
  }

  /**
   * DELETE /api/admin/client-managers/:managerId
   * Retirer un client d'un agent
   */
  static async unassignClient(req: Request, res: Response): Promise<void> {
    try {
      const { managerId } = req.params;

      if (!managerId) {
        res.status(400).json({
          success: false,
          error: 'managerId is required'
        });
        return;
      }

      // Retirer le client
      const clientManager = await ClientManagerService.unassignClient(managerId);

      // Mettre à jour les stats
      await ClientManagerStatsService.updateAgentStats(clientManager.agent_id);

      res.json({
        success: true,
        message: 'Client unassigned successfully',
        data: clientManager
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error unassigning client:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to unassign client'
      });
    }
  }

  /**
   * GET /api/admin/client-managers/agent/:agentId
   * Récupérer les clients d'un agent
   */
  static async getAgentClients(req: Request, res: Response): Promise<void> {
    try {
      const { agentId } = req.params;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;

      if (!agentId) {
        res.status(400).json({
          success: false,
          error: 'agentId is required'
        });
        return;
      }

      // Récupérer les clients
      const result = await ClientManagerService.getAgentClients(agentId, page, limit);

      res.json({
        success: true,
        data: result
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error getting agent clients:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get agent clients'
      });
    }
  }

  /**
   * GET /api/admin/client-managers/agent/:agentId/dashboard
   * Récupérer le dashboard d'un agent
   */
  static async getAgentDashboard(req: Request, res: Response): Promise<void> {
    try {
      const { agentId } = req.params;

      if (!agentId) {
        res.status(400).json({
          success: false,
          error: 'agentId is required'
        });
        return;
      }

      // Récupérer le dashboard
      const dashboard = await ClientManagerStatsService.getAgentDashboard(agentId);

      res.json({
        success: true,
        data: dashboard
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error getting dashboard:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get dashboard'
      });
    }
  }

  /**
   * GET /api/admin/client-managers/agents/stats
   * Récupérer les stats de tous les agents
   */
  static async getAllAgentsStats(req: Request, res: Response): Promise<void> {
    try {
      const sortBy = (req.query.sort as string) || 'total_revenue';
      const order = (req.query.order as 'asc' | 'desc') || 'desc';

      // Valider le champ de tri
      const validSortFields = ['total_revenue', 'total_clients', 'total_orders'];
      if (!validSortFields.includes(sortBy)) {
        res.status(400).json({
          success: false,
          error: `Invalid sort field. Must be one of: ${validSortFields.join(', ')}`
        });
        return;
      }

      // Récupérer les stats
      const stats = await ClientManagerStatsService.getAllAgentsStats(sortBy, order);

      res.json({
        success: true,
        data: {
          agents: stats
        }
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error getting all agents stats:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get agents stats'
      });
    }
  }

  /**
   * PATCH /api/admin/client-managers/:managerId
   * Mettre à jour les notes d'un client
   */
  static async updateClientNotes(req: Request, res: Response): Promise<void> {
    try {
      const { managerId } = req.params;
      const { notes } = req.body;

      if (!managerId) {
        res.status(400).json({
          success: false,
          error: 'managerId is required'
        });
        return;
      }

      if (!notes || typeof notes !== 'string') {
        res.status(400).json({
          success: false,
          error: 'notes is required and must be a string'
        });
        return;
      }

      // Mettre à jour les notes
      const clientManager = await ClientManagerService.updateClientNotes(managerId, notes);

      res.json({
        success: true,
        data: clientManager
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error updating notes:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to update notes'
      });
    }
  }

  /**
   * GET /api/admin/client-managers/agent/:agentId/inactive
   * Récupérer les clients inactifs d'un agent
   */
  static async getInactiveClients(req: Request, res: Response): Promise<void> {
    try {
      const { agentId } = req.params;
      const inactiveDays = parseInt(req.query.days as string) || 7;

      if (!agentId) {
        res.status(400).json({
          success: false,
          error: 'agentId is required'
        });
        return;
      }

      // Récupérer les clients inactifs
      const inactiveClients = await ClientManagerService.getInactiveClients(
        agentId,
        inactiveDays
      );

      res.json({
        success: true,
        data: {
          inactive_clients: inactiveClients,
          inactive_days: inactiveDays
        }
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error getting inactive clients:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get inactive clients'
      });
    }
  }

  /**
   * GET /api/admin/client-managers/available-agents
   * Récupérer tous les ADMIN disponibles pour l'assignation
   */
  static async getAvailableAgents(req: Request, res: Response): Promise<void> {
    try {
      const prisma = require('../../config/prisma').default;

      // Récupérer tous les ADMIN et SUPER_ADMIN
      const agents = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        },
        select: {
          id: true,
          first_name: true,
          last_name: true,
          email: true,
          role: true,
          created_at: true
        },
        orderBy: {
          first_name: 'asc'
        }
      });

      // Enrichir avec le nombre de clients assignés
      const enrichedAgents = await Promise.all(
        agents.map(async (agent: any) => {
          const clientCount = await prisma.client_managers.count({
            where: {
              agent_id: agent.id,
              is_active: true
            }
          });

          return {
            id: agent.id,
            name: `${agent.first_name} ${agent.last_name}`,
            email: agent.email,
            role: agent.role,
            total_clients: clientCount,
            created_at: agent.created_at
          };
        })
      );

      res.json({
        success: true,
        data: {
          agents: enrichedAgents,
          total: enrichedAgents.length
        }
      });
    } catch (error: any) {
      console.error('[ClientManagerController] Error getting available agents:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get available agents'
      });
    }
  }
}
