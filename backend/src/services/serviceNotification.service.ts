import { PrismaClient } from '@prisma/client';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

const prisma = new PrismaClient();

export class ServiceNotificationService {
  static async notifyServiceChange(
    serviceId: string,
    changes: { [key: string]: any }
  ): Promise<void> {
    try {
      const service = await prisma.services.findUnique({
        where: {
          id: serviceId
        },
        select: {
          name: true
        }
      });

      if (!service) throw new Error('Service not found');

      // 1. Notifier les administrateurs
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        },
        select: {
          id: true
        }
      });

      if (admins.length > 0) {
        await Promise.all(
          admins.map(admin =>
            NotificationService.sendNotification(
              admin.id,
              NotificationType.SERVICE_UPDATED,
              {
                title: 'Service mis à jour',
                message: `Le service "${service.name}" a été mis à jour`,
                data: {
                  serviceId,
                  serviceName: service.name,
                  changes
                }
              }
            )
          )
        );
      }

      // 2. Notifier les utilisateurs avec des commandes actives
      const activeOrders = await prisma.orders.findMany({
        where: {
          serviceId,
          status: {
            in: ['PENDING', 'PROCESSING']
          },
          userId: {
            notIn: admins.map(a => a.id)
          }
        },
        select: {
          userId: true
        }
      });

      if (activeOrders.length > 0) {
        const uniqueUserIds = [...new Set(activeOrders.map(order => order.userId))];

        await Promise.all(
          uniqueUserIds.map(userId =>
            NotificationService.sendNotification(
              userId,
              NotificationType.SERVICE_UPDATED,
              {
                title: 'Mise à jour de service',
                message: `Le service "${service.name}" que vous utilisez a été mis à jour`,
                data: {
                  serviceId,
                  serviceName: service.name,
                  changes
                }
              }
            )
          )
        );
      }
    } catch (error) {
      console.error('[ServiceNotificationService] Notification error:', error);
      throw error;
    }
  }
}
