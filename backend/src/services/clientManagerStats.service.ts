/**
 * 📊 Service: Client Manager Stats
 * Calcule et met à jour les statistiques des agents
 * 
 * Statistiques :
 * - Nombre de clients gérés
 * - Nombre total de commandes
 * - Revenus générés
 * - Valeur moyenne des commandes
 * - Nombre de clients inactifs
 */

import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export class ClientManagerStatsService {
  /**
   * Calculer et mettre à jour les stats d'un agent
   * 
   * @param agentId - ID de l'agent
   * @returns Les stats mises à jour
   */
  static async updateAgentStats(agentId: string) {
    try {
      console.log(`[ClientManagerStatsService] Updating stats for agent ${agentId}`);

      // Récupérer les clients actifs de l'agent
      const clientManagers = await prisma.client_managers.findMany({
        where: {
          agent_id: agentId,
          is_active: true
        },
        select: { client_id: true }
      });

      const clientIds = clientManagers.map((cm) => cm.client_id);

      // Calculer les stats
      const stats = await this.calculateStats(clientIds);

      // Mettre à jour ou créer les stats
      const updatedStats = await prisma.client_manager_stats.upsert({
        where: { agent_id: agentId },
        update: {
          total_clients: stats.totalClients,
          total_orders: stats.totalOrders,
          total_revenue: new Prisma.Decimal(stats.totalRevenue),
          avg_order_value: new Prisma.Decimal(stats.avgOrderValue),
          inactive_clients_count: stats.inactiveClientsCount,
          last_updated: new Date()
        },
        create: {
          agent_id: agentId,
          total_clients: stats.totalClients,
          total_orders: stats.totalOrders,
          total_revenue: new Prisma.Decimal(stats.totalRevenue),
          avg_order_value: new Prisma.Decimal(stats.avgOrderValue),
          inactive_clients_count: stats.inactiveClientsCount,
          last_updated: new Date()
        }
      });

      console.log(`[ClientManagerStatsService] Stats updated for agent ${agentId}:`, {
        totalClients: stats.totalClients,
        totalOrders: stats.totalOrders,
        totalRevenue: stats.totalRevenue,
        avgOrderValue: stats.avgOrderValue,
        inactiveClientsCount: stats.inactiveClientsCount
      });

      return updatedStats;
    } catch (error) {
      console.error('[ClientManagerStatsService] Error updating agent stats:', error);
      throw error;
    }
  }

  /**
   * Calculer les stats pour une liste de clients
   * 
   * @param clientIds - Liste des IDs de clients
   * @returns Les stats calculées
   */
  private static async calculateStats(clientIds: string[]) {
    try {
      const totalClients = clientIds.length;

      if (totalClients === 0) {
        return {
          totalClients: 0,
          totalOrders: 0,
          totalRevenue: 0,
          avgOrderValue: 0,
          inactiveClientsCount: 0
        };
      }

      // Compter les commandes
      const totalOrders = await prisma.orders.count({
        where: { userId: { in: clientIds } }
      });

      // Calculer le revenu total
      const revenueResult = await prisma.orders.aggregate({
        where: { userId: { in: clientIds } },
        _sum: { totalAmount: true }
      });

      const totalRevenue = Number(revenueResult._sum.totalAmount || 0);
      const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

      // Compter les clients inactifs (>7 jours)
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - 7);

      const inactiveClientsCount = await prisma.users.count({
        where: {
          id: { in: clientIds },
          orders: {
            none: {
              createdAt: { gte: cutoffDate }
            }
          }
        }
      });

      return {
        totalClients,
        totalOrders,
        totalRevenue,
        avgOrderValue,
        inactiveClientsCount
      };
    } catch (error) {
      console.error('[ClientManagerStatsService] Error calculating stats:', error);
      throw error;
    }
  }

  /**
   * Récupérer le dashboard d'un agent
   * 
   * @param agentId - ID de l'agent
   * @returns Dashboard avec stats et clients inactifs
   */
  static async getAgentDashboard(agentId: string) {
    try {
      console.log(`[ClientManagerStatsService] Getting dashboard for agent ${agentId}`);

      // Récupérer l'agent
      const agent = await prisma.users.findUnique({
        where: { id: agentId },
        select: {
          id: true,
          first_name: true,
          last_name: true,
          email: true
        }
      });

      if (!agent) {
        throw new Error(`Agent not found: ${agentId}`);
      }

      // Récupérer les stats
      const stats = await prisma.client_manager_stats.findUnique({
        where: { agent_id: agentId }
      });

      // Récupérer les clients inactifs
      const inactiveClients = await this.getInactiveClientsForAgent(agentId);

      // Récupérer les top clients
      const topClients = await this.getTopClientsForAgent(agentId);

      return {
        agent: {
          id: agent.id,
          name: `${agent.first_name} ${agent.last_name}`,
          email: agent.email
        },
        stats: {
          total_clients: stats?.total_clients || 0,
          total_orders: stats?.total_orders || 0,
          total_revenue: Number(stats?.total_revenue || 0),
          avg_order_value: Number(stats?.avg_order_value || 0),
          inactive_clients_count: stats?.inactive_clients_count || 0,
          last_updated: stats?.last_updated || null
        },
        inactive_clients: inactiveClients,
        top_clients: topClients
      };
    } catch (error) {
      console.error('[ClientManagerStatsService] Error getting dashboard:', error);
      throw error;
    }
  }

  /**
   * Récupérer les clients inactifs d'un agent
   * 
   * @param agentId - ID de l'agent
   * @returns Liste des clients inactifs
   */
  private static async getInactiveClientsForAgent(agentId: string) {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - 7);

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

      // Trouver les clients inactifs
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
        },
        take: 10
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
      console.error('[ClientManagerStatsService] Error getting inactive clients:', error);
      return [];
    }
  }

  /**
   * Récupérer les top clients d'un agent
   * 
   * @param agentId - ID de l'agent
   * @returns Liste des top clients
   */
  private static async getTopClientsForAgent(agentId: string) {
    try {
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

      // Récupérer les top clients par revenu
      const topClients = await prisma.users.findMany({
        where: { id: { in: clientIds } },
        select: {
          id: true,
          first_name: true,
          last_name: true,
          email: true
        },
        take: 5
      });

      // Enrichir avec les stats
      const enriched = await Promise.all(
        topClients.map(async (client) => {
          const orderStats = await prisma.orders.aggregate({
            where: { userId: client.id },
            _count: { id: true },
            _sum: { totalAmount: true }
          });

          return {
            id: client.id,
            name: `${client.first_name} ${client.last_name}`,
            email: client.email,
            total_orders: orderStats._count.id,
            total_spent: Number(orderStats._sum.totalAmount || 0)
          };
        })
      );

      // Trier par total_spent décroissant
      return enriched.sort((a, b) => b.total_spent - a.total_spent);
    } catch (error) {
      console.error('[ClientManagerStatsService] Error getting top clients:', error);
      return [];
    }
  }

  /**
   * Récupérer les stats de tous les agents
   * 
   * @param sortBy - Champ de tri (revenue, clients, orders)
   * @param order - Ordre de tri (asc, desc)
   * @returns Liste des agents avec leurs stats
   */
  static async getAllAgentsStats(
    sortBy: string = 'total_revenue',
    order: 'asc' | 'desc' = 'desc'
  ) {
    try {
      console.log(
        `[ClientManagerStatsService] Getting all agents stats (sort: ${sortBy}, order: ${order})`
      );

      // Récupérer les stats de tous les agents
      const agentsStats = await prisma.client_manager_stats.findMany({
        include: {
          users: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true
            }
          }
        },
        orderBy: {
          [sortBy]: order
        }
      });

      // Enrichir avec le classement
      const enriched = agentsStats.map((stat, index) => ({
        rank: index + 1,
        agent: {
          id: stat.users.id,
          name: `${stat.users.first_name} ${stat.users.last_name}`,
          email: stat.users.email
        },
        stats: {
          total_clients: stat.total_clients || 0,
          total_orders: stat.total_orders || 0,
          total_revenue: Number(stat.total_revenue || 0),
          avg_order_value: Number(stat.avg_order_value || 0),
          inactive_clients_count: stat.inactive_clients_count || 0,
          last_updated: stat.last_updated
        }
      }));

      return enriched;
    } catch (error) {
      console.error('[ClientManagerStatsService] Error getting all agents stats:', error);
      throw error;
    }
  }
}
