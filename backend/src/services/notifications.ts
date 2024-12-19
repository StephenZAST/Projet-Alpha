import { createClient } from '@supabase/supabase-js';
import { Notification, NotificationType, NotificationPriority, NotificationStatus, DeliveryChannel } from '../models/notification';
import { AppError, errorCodes } from '../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

export class NotificationService {
  private notificationsTable = 'notifications';

  async createNotification(notification: Omit<Notification, 'id' | 'createdAt'>): Promise<string> {
    const newNotification = {
      ...notification,
      createdAt: new Date().toISOString(),
      isRead: false
    };

    const { data, error } = await supabase.from(this.notificationsTable).insert([newNotification]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create notification', errorCodes.NOTIFICATION_CREATE_ERROR);
    }

    return data.id;
  }

  async sendNotification(userId: string, notification: { type: NotificationType; title: string; message: string; data: { orderId?: string; recurringOrderId?: string; } }): Promise<void> {
    const newNotification = {
      type: notification.type,
      recipientId: userId,
      recipientRole: 'customer' as 'customer' | 'affiliate' | 'admin',
      title: notification.title,
      message: notification.message,
      data: notification.data,
      priority: NotificationPriority.MEDIUM,
      status: NotificationStatus.UNREAD,
      deliveryChannel: DeliveryChannel.IN_APP,
      isRead: false
    };

    await this.createNotification(newNotification);
  }

  async sendOrderStatusNotification(orderId: string, userId: string, status: string, additionalData?: Record<string, any>): Promise<string> {
    const notification = {
      type: NotificationType.ORDER_STATUS_UPDATE,
      recipientId: userId,
      recipientRole: 'customer' as 'customer' | 'affiliate' | 'admin',
      title: 'Order Status Update',
      message: `Your order #${orderId} status has been updated to: ${status}`,
      data: {
        orderId,
        status,
        ...additionalData
      },
      priority: NotificationPriority.MEDIUM,
      status: NotificationStatus.UNREAD,
      deliveryChannel: DeliveryChannel.IN_APP,
      isRead: false
    };

    return this.createNotification(notification);
  }

  async sendAffiliateCommissionNotification(affiliateId: string, amount: number, orderId: string): Promise<string> {
    const notification = {
      type: NotificationType.COMMISSION_APPROVED,
      recipientId: affiliateId,
      recipientRole: 'affiliate' as 'customer' | 'affiliate' | 'admin',
      title: 'Commission Approved',
      message: `You've earned a commission of ${amount} from order #${orderId}`,
      data: {
        orderId,
        amount
      },
      priority: NotificationPriority.MEDIUM,
      status: NotificationStatus.UNREAD,
      deliveryChannel: DeliveryChannel.IN_APP,
      isRead: false
    };

    return this.createNotification(notification);
  }

  async sendLoyaltyPointsReminder(userId: string, points: number): Promise<string> {
    const notification = {
      type: NotificationType.LOYALTY_POINTS_REMINDER,
      recipientId: userId,
      recipientRole: 'customer' as 'customer' | 'affiliate' | 'admin',
      title: 'Redeem Your Loyalty Points',
      message: `You have ${points} points available to redeem for discounts or gifts!`,
      data: {
        points
      },
      priority: NotificationPriority.MEDIUM,
      status: NotificationStatus.UNREAD,
      deliveryChannel: DeliveryChannel.IN_APP,
      isRead: false
    };

    return this.createNotification(notification);
  }

  async broadcastPromotion(title: string, message: string, userRole: 'customer' | 'affiliate', expiresAt?: Date): Promise<void> {
    const usersTable = 'users';
    const { data: users, error: usersError } = await supabase.from(usersTable).select('id').eq('role', userRole);

    if (usersError) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }

    const notifications = users.map((user: { id: string }) => ({
      type: NotificationType.PROMOTION_AVAILABLE,
      recipientId: user.id,
      recipientRole: userRole,
      title,
      message,
      priority: NotificationPriority.MEDIUM,
      status: NotificationStatus.UNREAD,
      deliveryChannel: DeliveryChannel.IN_APP,
      isRead: false,
      createdAt: new Date().toISOString(),
      expiresAt: expiresAt?.toISOString()
    }));

    for (const notification of notifications) {
      await this.createNotification(notification);
    }
  }

  async markAsRead(notificationId: string, userId: string): Promise<boolean> {
    try {
      const { error } = await supabase.from(this.notificationsTable).update({ isRead: true, readAt: new Date().toISOString() }).eq('id', notificationId).eq('recipientId', userId);

      if (error) {
        throw new AppError(500, 'Failed to mark notification as read', errorCodes.NOTIFICATION_UPDATE_ERROR);
      }

      return true;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      return false;
    }
  }

  async getUserNotifications(userId: string, limit = 50): Promise<Notification[]> {
    const { data, error } = await supabase.from(this.notificationsTable).select('*').eq('recipientId', userId).order('createdAt', { ascending: false }).limit(limit);

    if (error) {
      throw new AppError(500, 'Failed to fetch user notifications', errorCodes.NOTIFICATION_FETCH_ERROR);
    }

    return data as Notification[];
  }
}

export const notificationService = new NotificationService();
export { NotificationType };
