/**
 * 🗑️ Notification Cleanup Service
 * 
 * Gère la suppression automatique des notifications selon leur âge et statut de lecture
 * Exécuté via une tâche cron pour maintenir la base de données propre
 */

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class NotificationCleanupService {
  /**
   * 🗑️ Supprimer les anciennes notifications
   * 
   * Politique de suppression:
   * - Notifications lues > 7 jours → Supprimer
   * - Notifications non-lues > 30 jours → Supprimer
   * - Notifications critiques (PAYMENT_FAILED, ORDER_CANCELLED) > 90 jours → Supprimer
   */
  static async cleanupOldNotifications(): Promise<{
    readDeleted: number;
    unreadDeleted: number;
    criticalDeleted: number;
    totalDeleted: number;
  }> {
    try {
      console.log('🗑️ [NotificationCleanup] Démarrage du nettoyage des notifications...');

      const now = new Date();
      let readDeleted = 0;
      let unreadDeleted = 0;
      let criticalDeleted = 0;

      // 1️⃣ Supprimer les notifications LUES > 7 jours
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const readResult = await prisma.notifications.deleteMany({
        where: {
          read: true,
          created_at: {
            lt: sevenDaysAgo
          }
        }
      });
      readDeleted = readResult.count;
      console.log(`✅ [NotificationCleanup] ${readDeleted} notifications lues supprimées (> 7 jours)`);

      // 2️⃣ Supprimer les notifications NON-LUES > 30 jours
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      const unreadResult = await prisma.notifications.deleteMany({
        where: {
          read: false,
          created_at: {
            lt: thirtyDaysAgo
          }
        }
      });
      unreadDeleted = unreadResult.count;
      console.log(`✅ [NotificationCleanup] ${unreadDeleted} notifications non-lues supprimées (> 30 jours)`);

      // 3️⃣ Supprimer les notifications CRITIQUES > 90 jours
      const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      const criticalTypes = ['PAYMENT_FAILED', 'ORDER_CANCELLED', 'DELIVERY_PROBLEM'];
      
      const criticalResult = await prisma.notifications.deleteMany({
        where: {
          type: {
            in: criticalTypes
          },
          created_at: {
            lt: ninetyDaysAgo
          }
        }
      });
      criticalDeleted = criticalResult.count;
      console.log(`✅ [NotificationCleanup] ${criticalDeleted} notifications critiques supprimées (> 90 jours)`);

      const totalDeleted = readDeleted + unreadDeleted + criticalDeleted;

      // 📊 Log de résumé
      console.log('═══════════════════════════════════════════════════════════');
      console.log('📊 [NotificationCleanup] Résumé du nettoyage');
      console.log('═══════════════════════════════════════════════════════════');
      console.log(`📝 Notifications lues supprimées (> 7j): ${readDeleted}`);
      console.log(`📝 Notifications non-lues supprimées (> 30j): ${unreadDeleted}`);
      console.log(`⚠️  Notifications critiques supprimées (> 90j): ${criticalDeleted}`);
      console.log(`📊 Total supprimé: ${totalDeleted}`);
      console.log(`⏰ Exécution: ${now.toISOString()}`);
      console.log('═══════════════════════════════════════════════════════════');

      // 📈 Enregistrer les statistiques de nettoyage
      await this.logCleanupStats({
        readDeleted,
        unreadDeleted,
        criticalDeleted,
        totalDeleted,
        executedAt: now
      });

      return {
        readDeleted,
        unreadDeleted,
        criticalDeleted,
        totalDeleted
      };
    } catch (error) {
      console.error('❌ [NotificationCleanup] Erreur lors du nettoyage:', error);
      throw error;
    }
  }

  /**
   * 📈 Enregistrer les statistiques de nettoyage pour audit
   */
  private static async logCleanupStats(stats: {
    readDeleted: number;
    unreadDeleted: number;
    criticalDeleted: number;
    totalDeleted: number;
    executedAt: Date;
  }): Promise<void> {
    try {
      // Créer une notification système pour les admins
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        },
        select: { id: true }
      });

      if (admins.length === 0) return;

      const message = `Nettoyage automatique des notifications: ${stats.totalDeleted} supprimées (${stats.readDeleted} lues, ${stats.unreadDeleted} non-lues, ${stats.criticalDeleted} critiques)`;

      // Créer une notification système pour chaque admin
      await Promise.all(
        admins.map(admin =>
          prisma.notifications.create({
            data: {
              userId: admin.id,
              type: 'SYSTEM',
              message,
              data: {
                type: 'NOTIFICATION_CLEANUP_REPORT',
                stats
              },
              read: false,
              created_at: new Date(),
              updated_at: new Date()
            }
          })
        )
      );

      console.log(`📧 [NotificationCleanup] Rapport envoyé à ${admins.length} admin(s)`);
    } catch (error) {
      console.error('[NotificationCleanup] Erreur lors de l\'enregistrement des stats:', error);
      // Ne pas bloquer le processus si l'enregistrement échoue
    }
  }

  /**
   * 🔍 Obtenir les statistiques de notifications
   */
  static async getNotificationStats(): Promise<{
    total: number;
    read: number;
    unread: number;
    byType: Record<string, number>;
    oldestNotification: Date | null;
    newestNotification: Date | null;
  }> {
    try {
      const [total, read, unread, oldest, newest] = await Promise.all([
        prisma.notifications.count(),
        prisma.notifications.count({ where: { read: true } }),
        prisma.notifications.count({ where: { read: false } }),
        prisma.notifications.findFirst({
          orderBy: { created_at: 'asc' },
          select: { created_at: true }
        }),
        prisma.notifications.findFirst({
          orderBy: { created_at: 'desc' },
          select: { created_at: true }
        })
      ]);

      // Compter par type
      const byTypeRaw = await prisma.notifications.groupBy({
        by: ['type'],
        _count: true
      });

      const byType: Record<string, number> = {};
      byTypeRaw.forEach(item => {
        byType[item.type] = item._count;
      });

      return {
        total,
        read,
        unread,
        byType,
        oldestNotification: oldest?.created_at || null,
        newestNotification: newest?.created_at || null
      };
    } catch (error) {
      console.error('[NotificationCleanup] Erreur lors de la récupération des stats:', error);
      throw error;
    }
  }

  /**
   * 🧹 Nettoyer les notifications d'un utilisateur spécifique
   */
  static async cleanupUserNotifications(userId: string): Promise<number> {
    try {
      console.log(`🧹 [NotificationCleanup] Nettoyage des notifications de l'utilisateur ${userId}`);

      const now = new Date();
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

      const result = await prisma.notifications.deleteMany({
        where: {
          userId,
          created_at: {
            lt: thirtyDaysAgo
          }
        }
      });

      console.log(`✅ [NotificationCleanup] ${result.count} notifications supprimées pour l'utilisateur ${userId}`);
      return result.count;
    } catch (error) {
      console.error('[NotificationCleanup] Erreur lors du nettoyage utilisateur:', error);
      throw error;
    }
  }

  /**
   * 🗑️ Supprimer les notifications lues d'un utilisateur
   */
  static async deleteReadNotifications(userId: string): Promise<number> {
    try {
      console.log(`🗑️ [NotificationCleanup] Suppression des notifications lues de l'utilisateur ${userId}`);

      const result = await prisma.notifications.deleteMany({
        where: {
          userId,
          read: true
        }
      });

      console.log(`✅ [NotificationCleanup] ${result.count} notifications lues supprimées`);
      return result.count;
    } catch (error) {
      console.error('[NotificationCleanup] Erreur lors de la suppression:', error);
      throw error;
    }
  }

  /**
   * 📊 Obtenir les notifications à supprimer (sans les supprimer)
   */
  static async getNotificationsToDelete(): Promise<{
    readToDelete: number;
    unreadToDelete: number;
    criticalToDelete: number;
  }> {
    try {
      const now = new Date();
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);

      const [readToDelete, unreadToDelete, criticalToDelete] = await Promise.all([
        prisma.notifications.count({
          where: {
            read: true,
            created_at: { lt: sevenDaysAgo }
          }
        }),
        prisma.notifications.count({
          where: {
            read: false,
            created_at: { lt: thirtyDaysAgo }
          }
        }),
        prisma.notifications.count({
          where: {
            type: { in: ['PAYMENT_FAILED', 'ORDER_CANCELLED', 'DELIVERY_PROBLEM'] },
            created_at: { lt: ninetyDaysAgo }
          }
        })
      ]);

      return {
        readToDelete,
        unreadToDelete,
        criticalToDelete
      };
    } catch (error) {
      console.error('[NotificationCleanup] Erreur lors du calcul:', error);
      throw error;
    }
  }
}
