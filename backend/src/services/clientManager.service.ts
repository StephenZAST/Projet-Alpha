/**
 * 👤 Service: Client Manager (SVA)
 * Gère la liaison entre agents et clients
 * 
 * Fonctionnalités :
 * - Assigner un client à un agent
 * - Retirer un client d'un agent
 * - Récupérer les clients d'un agent
 * - Mettre à jour les notes
 * - Enregistrer les logs d'activité
 */

import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export class ClientManagerService {
  /**
   * Assigner un client à un agent
   * 
   * @param agentId - ID de l'agent
   * @param clientId - ID du client
   * @param assignedBy - ID de l'admin qui assigne
   * @param notes - Notes optionnelles
   * @returns La liaison créée
   */
  static async assignClientToAgent(
    agentId: string,
    clientId: string,
    assignedBy: string,
    notes?: string
  ) {
    try {
      console.log(
        `[ClientManagerService] Assigning client ${clientId} to agent ${agentId}`
      );

      // Vérifier que l'agent existe et est un ADMIN ou CUSTOMER_SERVICE
      const agent = await prisma.users.findUnique({
        where: { id: agentId }
      });

      if (!agent) {
        throw new Error(`Agent not found: ${agentId}`);
      }

      if (!['ADMIN', 'SUPER_ADMIN', 'CUSTOMER_SERVICE'].includes(agent.role || '')) {
        throw new Error(`User is not an agent: ${agentId}`);
      }

      // Vérifier que le client existe et est un CLIENT
      const client = await prisma.users.findUnique({
        where: { id: clientId }
      });

      if (!client) {
        throw new Error(`Client not found: ${clientId}`);
      }

      if (client.role !== 'CLIENT') {
        throw new Error(`User is not a client: ${clientId}`);
      }

      // Vérifier qu'il n'y a pas déjà une liaison active
      const existingLink = await prisma.client_managers.findFirst({
        where: {
          agent_id: agentId,
          client_id: clientId
        }
      });

      if (existingLink && existingLink.is_active) {
        throw new Error(`Client is already assigned to this agent`);
      }

      // Créer ou réactiver la liaison
      let clientManager;
      if (existingLink) {
        clientManager = await prisma.client_managers.update({
          where: { id: existingLink.id },
          data: {
            is_active: true,
            assigned_at: new Date(),
            assigned_by: assignedBy,
            notes: notes || null,
            updated_at: new Date()
          }
        });
      } else {
        clientManager = await prisma.client_managers.create({
          data: {
            agent_id: agentId,
            client_id: clientId,
            assigned_by: assignedBy,
            notes: notes || null,
            assigned_at: new Date(),
            is_active: true
          }
        });
      }

      // Enregistrer l'activité
      await this.logActivity(agentId, clientId, 'ASSIGNED', {
        assigned_by: assignedBy,
        notes
      });

      console.log(
        `[ClientManagerService] Client ${clientId} assigned to agent ${agentId}`
      );

      return clientManager;
    } catch (error) {
      console.error('[ClientManagerService] Error assigning client:', error);
      throw error;
    }
  }

  /**
   * Retirer un client d'un agent
   * 
   * @param managerId - ID de la liaison
   * @returns La liaison mise à jour
   */
  static async unassignClient(managerId: string) {
    try {
      console.log(`[ClientManagerService] Unassigning client manager ${managerId}`);

      const clientManager = await prisma.client_managers.findUnique({
        where: { id: managerId }
      });

      if (!clientManager) {
        throw new Error(`Client manager not found: ${managerId}`);
      }

      // Marquer comme inactif au lieu de supprimer
      const updated = await prisma.client_managers.update({
        where: { id: managerId },
        data: {
          is_active: false,
          updated_at: new Date()
        }
      });

      // Enregistrer l'activité
      await this.logActivity(
        clientManager.agent_id,
        clientManager.client_id,
        'UNASSIGNED',
        {}
      );

      console.log(`[ClientManagerService] Client manager ${managerId} unassigned`);

      return updated;
    } catch (error) {
      console.error('[ClientManagerService] Error unassigning client:', error);
      throw error;
    }
  }

  /**
   * Récupérer les clients d'un agent
   * 
   * @param agentId - ID de l'agent
   * @param page - Numéro de page
   * @param limit - Nombre de résultats par page
   * @returns Liste des clients avec leurs stats
   */
  static async getAgentClients(agentId: string, page: number = 1, limit: number = 20) {
    try {
      console.log(
        `[ClientManagerService] Getting clients for agent ${agentId} (page ${page}, limit ${limit})`
      );

      const skip = (page - 1) * limit;

      // Récupérer les liaisons actives
      const clientManagers = await prisma.client_managers.findMany({
        where: {
          agent_id: agentId,
          is_active: true
        },
        include: {
          users_client_managers_client_idTousers: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true,
              created_at: true
            }
          }
        },
        skip,
        take: limit,
        orderBy: { assigned_at: 'desc' }
      });

      // Compter le total
      const total = await prisma.client_managers.count({
        where: {
          agent_id: agentId,
          is_active: true
        }
      });

      // Enrichir avec les stats de chaque client
      const clientsWithStats = await Promise.all(
        clientManagers.map(async (cm) => {
          const client = cm.users_client_managers_client_idTousers;
          
          // Compter les commandes
          const orderCount = await prisma.orders.count({
            where: { userId: client.id }
          });

          // Calculer le total dépensé
          const orderStats = await prisma.orders.aggregate({
            where: { userId: client.id },
            _sum: { totalAmount: true }
          });

          // Récupérer la dernière commande
          const lastOrder = await prisma.orders.findFirst({
            where: { userId: client.id },
            orderBy: { createdAt: 'desc' },
            select: { createdAt: true }
          });

          const daysSinceLastOrder = lastOrder && lastOrder.createdAt
            ? Math.floor(
                (Date.now() - new Date(lastOrder.createdAt).getTime()) /
                  (1000 * 60 * 60 * 24)
              )
            : null;

          return {
            id: client.id,
            name: `${client.first_name} ${client.last_name}`,
            email: client.email,
            phone: client.phone,
            total_orders: orderCount,
            total_spent: Number(orderStats._sum.totalAmount || 0),
            last_order_date: lastOrder?.createdAt || null,
            days_since_last_order: daysSinceLastOrder,
            is_inactive: daysSinceLastOrder && daysSinceLastOrder > 7,
            assigned_at: cm.assigned_at,
            notes: cm.notes
          };
        })
      );

      return {
        clients: clientsWithStats,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('[ClientManagerService] Error getting agent clients:', error);
      throw error;
    }
  }

  /**
   * Mettre à jour les notes d'un client
   * 
   * @param managerId - ID de la liaison
   * @param notes - Nouvelles notes
   * @returns La liaison mise à jour
   */
  static async updateClientNotes(managerId: string, notes: string) {
    try {
      console.log(`[ClientManagerService] Updating notes for manager ${managerId}`);

      const clientManager = await prisma.client_managers.findUnique({
        where: { id: managerId }
      });

      if (!clientManager) {
        throw new Error(`Client manager not found: ${managerId}`);
      }

      const updated = await prisma.client_managers.update({
        where: { id: managerId },
        data: {
          notes,
          updated_at: new Date()
        }
      });

      // Enregistrer l'activité
      await this.logActivity(
        clientManager.agent_id,
        clientManager.client_id,
        'NOTES_UPDATED',
        { notes }
      );

      return updated;
    } catch (error) {
      console.error('[ClientManagerService] Error updating notes:', error);
      throw error;
    }
  }

  /**
   * Enregistrer une activité
   * 
   * @param agentId - ID de l'agent
   * @param clientId - ID du client
   * @param actionType - Type d'action
   * @param details - Détails de l'action
   */
  static async logActivity(
    agentId: string,
    clientId: string,
    actionType: string,
    details: any
  ) {
    try {
      await prisma.client_manager_activity_logs.create({
        data: {
          agent_id: agentId,
          client_id: clientId,
          action_type: actionType,
          details: details || {},
          created_at: new Date()
        }
      });
    } catch (error) {
      console.error('[ClientManagerService] Error logging activity:', error);
      // Ne pas lever l'erreur, juste logger
    }
  }

  /**
   * Récupérer les clients inactifs d'un agent
   * 
   * @param agentId - ID de l'agent
   * @param inactiveDays - Nombre de jours d'inactivité (défaut: 7)
   * @returns Liste des clients inactifs
   */
  static async getInactiveClients(agentId: string, inactiveDays: number = 7) {
    try {
      console.log(
        `[ClientManagerService] Getting inactive clients for agent ${agentId} (>${inactiveDays} days)`
      );

      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - inactiveDays);

      // Récupérer les clients de l'agent
      const clientManagers = await prisma.client_managers.findMany({
        where: {
          agent_id: agentId,
          is_active: true
        },
        select: { client_id: true }
      });

      const clientIds = clientManagers.map((cm) => cm.client_id);

      if (clientIds.length === 0) {
        return [];
      }

      // Trouver les clients sans commande récente
      const inactiveClients = await prisma.users.findMany({
        where: {
          id: { in: clientIds },
          orders: {
            none: {
              createdAt: { gte: cutoffDate }
            }
          }
        },
        select: {
          id: true,
          first_name: true,
          last_name: true,
          email: true
        }
      });

      // Enrichir avec la date de dernière commande
      const enriched = await Promise.all(
        inactiveClients.map(async (client) => {
          const lastOrder = await prisma.orders.findFirst({
            where: { userId: client.id },
            orderBy: { createdAt: 'desc' },
            select: { createdAt: true }
          });

          const daysSinceLastOrder = lastOrder && lastOrder.createdAt
            ? Math.floor(
                (Date.now() - new Date(lastOrder.createdAt).getTime()) /
                  (1000 * 60 * 60 * 24)
              )
            : null;

          return {
            id: client.id,
            name: `${client.first_name} ${client.last_name}`,
            email: client.email,
            last_order_date: lastOrder?.createdAt || null,
            days_since_last_order: daysSinceLastOrder
          };
        })
      );

      return enriched;
    } catch (error) {
      console.error('[ClientManagerService] Error getting inactive clients:', error);
      throw error;
    }
  }
}
