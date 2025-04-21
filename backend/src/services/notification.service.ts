import { PrismaClient, Prisma, orders, order_items } from '@prisma/client';
import { NotificationType, User, NotificationCreate, NotificationTemplate, Order } from '../models/types';

const prisma = new PrismaClient();

interface OrderWithRelations extends orders {
  order_items?: (order_items & {
    article: {
      name: string;
    };
  })[];
  service_types?: {
    name: string;
  };
}

export class NotificationService {
  static async sendNotification(
    userId: string,
    type: NotificationType,
    data: any = {}
  ): Promise<void> {
    try {
      const user = await prisma.users.findUnique({
        where: { id: userId }
      });

      if (!user) throw new Error('User not found');

      const rule = await prisma.notification_rules.findFirst({
        where: {
          event_type: type,
          user_role: user.role || 'CLIENT',
          is_active: true
        }
      });

      if (!rule) {
        console.log(`No notification rule found for type ${type} and role ${user.role || 'CLIENT'}`);
        return;
      }

      const message = this.buildNotificationMessage(rule.template || '', {
        ...data,
        userName: `${user.first_name} ${user.last_name}`,
      });

      await this.createDatabaseNotification(userId, type, message, data);

    } catch (error) {
      console.error('[NotificationService] Error sending notification:', error);
      throw error;
    }
  }

  static async createOrderNotification(
    userId: string,
    orderId: string,
    type: NotificationType,
    additionalData: any = {}
  ): Promise<void> {
    try {
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          service_types: {
            select: {
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  name: true
                }
              }
            }
          }
        }
      }) as OrderWithRelations | null;

      if (!order) throw new Error('Order not found');

      const notificationData = {
        orderId,
        orderStatus: order.status,
        serviceName: order.service_types?.name,
        totalAmount: order.totalAmount,
        items: order.order_items?.map(item => ({
          name: item.article?.name ?? 'Unknown Article',
          quantity: item.quantity
        })),
        ...additionalData
      };

      await this.sendNotification(userId, type, notificationData);

      if (order.affiliateCode) {
        const affiliate = await prisma.affiliate_profiles.findFirst({
          where: { affiliate_code: order.affiliateCode }
        });

        if (affiliate) {
          await this.sendAffiliateNotification(
            affiliate.user_id,
            orderId,
            Number(order.totalAmount)
          );
        }
      }

      if (['READY', 'DELIVERED'].includes(order.status || '')) {
        await this.notifyAdmins(NotificationType.ORDER_STATUS_UPDATED, {
          orderId,
          status: order.status,
          totalAmount: order.totalAmount
        });
      }

    } catch (error) {
      console.error('[NotificationService] Error creating order notification:', error);
      throw error;
    }
  }

  static async sendAffiliateNotification(
    affiliateUserId: string,
    orderId: string,
    orderAmount: number
  ): Promise<void> {
    try {
      const affiliate = await prisma.affiliate_profiles.findFirst({
        where: { user_id: affiliateUserId }
      });

      if (!affiliate) return;

      const commissionAmount = orderAmount * (Number(affiliate.commission_rate) / 100);

      await this.sendNotification(affiliateUserId, NotificationType.ORDER_CREATED, {
        orderId,
        orderAmount,
        commissionAmount,
        currentBalance: Number(affiliate.commission_balance) + commissionAmount
      });

    } catch (error) {
      console.error('[NotificationService] Error sending affiliate notification:', error);
      throw error;
    }
  }

  private static async notifyAdmins(
    type: NotificationType,
    data: any
  ): Promise<void> {
    try {
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        }
      });

      await Promise.all(
        admins.map(admin => this.sendNotification(admin.id, type, data))
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying admins:', error);
      throw error;
    }
  }

  private static async createDatabaseNotification(
    userId: string,
    type: NotificationType,
    message: string,
    data: any = {}
  ): Promise<void> {
    try {
      await prisma.notifications.create({
        data: {
          user_id: userId,
          type,
          message,
          data,
          read: false,
          created_at: new Date(),
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error creating database notification:', error);
      throw error;
    }
  }

  static async getUserNotifications(userId: string, page = 1, limit = 20) {
    try {
      const [notifications, total] = await prisma.$transaction([
        prisma.notifications.findMany({
          where: { user_id: userId },
          orderBy: { created_at: 'desc' },
          skip: (page - 1) * limit,
          take: limit
        }),
        prisma.notifications.count({
          where: { user_id: userId }
        })
      ]);

      return {
        notifications,
        total,
        page,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('[NotificationService] Error getting user notifications:', error);
      throw error;
    }
  }

  static async getUnreadCount(userId: string): Promise<number> {
    try {
      return await prisma.notifications.count({
        where: {
          user_id: userId,
          read: false
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error getting unread count:', error);
      throw error;
    }
  }

  static async markAsRead(userId: string, notificationId: string): Promise<void> {
    try {
      await prisma.notifications.updateMany({
        where: {
          id: notificationId,
          user_id: userId
        },
        data: {
          read: true,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error marking notification as read:', error);
      throw error;
    }
  }

  static async markAllAsRead(userId: string): Promise<void> {
    try {
      await prisma.notifications.updateMany({
        where: {
          user_id: userId,
          read: false
        },
        data: {
          read: true,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error marking all notifications as read:', error);
      throw error;
    }
  }

  static async deleteNotification(userId: string, notificationId: string): Promise<void> {
    try {
      await prisma.notifications.deleteMany({
        where: {
          id: notificationId,
          user_id: userId
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error deleting notification:', error);
      throw error;
    }
  }

  static async getNotificationPreferences(userId: string): Promise<any> {
    try {
      return await prisma.notification_preferences.findFirst({
        where: { user_id: userId }
      });
    } catch (error) {
      console.error('[NotificationService] Error getting notification preferences:', error);
      throw error;
    }
  }

  static async updateNotificationPreferences(userId: string, preferences: any): Promise<void> {
    try {
      const existingPreferences = await prisma.notification_preferences.findFirst({
        where: { user_id: userId }
      });

      if (existingPreferences) {
        await prisma.notification_preferences.update({
          where: { id: existingPreferences.id },
          data: {
            ...preferences,
            updated_at: new Date()
          }
        });
      } else {
        await prisma.notification_preferences.create({
          data: {
            user_id: userId,
            ...preferences,
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }
    } catch (error) {
      console.error('[NotificationService] Error updating notification preferences:', error);
      throw error;
    }
  }

  private static buildNotificationMessage(
    template: string,
    data: Record<string, any>
  ): string {
    return template.replace(/\{(\w+)\}/g, (match, key) => {
      return data[key]?.toString() || match;
    });
  }

  static async createNotification(
    userId: string,
    type: NotificationType,
    message: string,
    data?: Record<string, any>
  ): Promise<void>;
  static async createNotification(notification: NotificationCreate): Promise<void>;
  static async createNotification(
    userIdOrNotification: string | NotificationCreate,
    type?: NotificationType,
    message?: string,
    data: Record<string, any> = {}
  ): Promise<void> {
    try {
      if (typeof userIdOrNotification === 'object') {
        const notification = userIdOrNotification;
        
        if (!Object.values(NotificationType).includes(notification.type)) {
          throw new Error(`Invalid notification type: ${notification.type}`);
        }

        await prisma.notifications.create({
          data: {
            user_id: notification.user_id,
            type: notification.type,
            message: notification.message,
            data: notification.data || {},
            read: notification.read ?? false,
            created_at: notification.created_at ? new Date(notification.created_at) : new Date(),
            updated_at: notification.updated_at ? new Date(notification.updated_at) : new Date()
          }
        });
      } else {
        const existing = await prisma.notifications.findFirst({
          where: {
            user_id: userIdOrNotification,
            type: type as string,
            message: message as string,
            read: false
          },
          orderBy: {
            created_at: 'desc'
          }
        });

        if (existing) {
          console.log('[NotificationService] Similar notification exists, skipping');
          return;
        }

        await prisma.notifications.create({
          data: {
            user_id: userIdOrNotification,
            type: type as string,
            message: message as string,
            data,
            read: false,
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }
    } catch (error) {
      console.error('[NotificationService] Unexpected error:', error);
      throw error;
    }
  }

  static async sendOrderNotification(order: Order): Promise<void> {
    try {
      const rules = await prisma.notification_rules.findMany({
        where: {
          event_type: NotificationType.ORDER_CREATED,
          is_active: true
        }
      });

      if (!rules?.length) {
        console.log('[NotificationService] No active rules found');
        return;
      }

      const users = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN', 'DELIVERY']
          }
        }
      });

      if (!users?.length) return;

      await Promise.all(
        users.map(user =>
          this.sendNotification(
            user.id,
            NotificationType.ORDER_CREATED,
            {
              orderId: order.id,
              total: order.totalAmount,
              items: order.items?.length || 0,
              address: order.address_id
            }
          )
        )
      );
    } catch (error) {
      console.error('[NotificationService] Error sending order notification:', error);
      throw error;
    }
  }

  static async sendRoleBasedNotifications(
    order: Order,
    templateData: NotificationTemplate
  ): Promise<void> {
    try {
      const users = await prisma.users.findMany({
        where: {
          role: {
            in: ['SUPER_ADMIN', 'ADMIN', 'DELIVERY']
          }
        }
      });

      if (!users?.length) return;

      await Promise.all(
        users.map(user =>
          this.sendNotification(
            user.id,
            NotificationType.ORDER_CREATED,
            {
              orderId: order.id,
              title: templateData.title,
              clientName: templateData.clientName,
              message: templateData.message,
              deliveryZone: templateData.deliveryZone,
              itemCount: templateData.itemCount,
              amount: user.role === 'DELIVERY' ? undefined : templateData.amount
            }
          )
        )
      );
    } catch (error) {
      console.error('[NotificationService] Error sending role-based notifications:', error);
      throw error;
    }
  }
}
