import { SupabaseClient } from '@supabase/supabase-js';
import supabase from '../config/database';
import { PaginationParams } from '../utils/pagination';
import { Notification, NotificationType, Order } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class NotificationService {
  static async create(
    userId: string,
    type: string,
    title: string,
    message: string,
    data: any = {}
  ): Promise<any> {
    try {
      console.log('Creating notification:', { userId, type, title, message, data });

      const { data: notification, error } = await supabase
        .from('notifications')
        .insert([{
          user_id: userId,
          type,
          title,
          message,
          data: JSON.stringify(data), // Assurer que data est une chaîne JSON
          read: false,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) {
        console.error('Notification creation error:', error);
        // Ne pas bloquer le processus si la notification échoue
        return null;
      }

      return notification;
    } catch (error) {
      console.error('Notification error:', error);
      // Ne pas bloquer le processus si la notification échoue
      return null;
    }
  }

  static async createOrderNotification(
    userId: string,
    orderId: string,
    type: NotificationType,
    additionalData: any = {}
  ): Promise<void> {
    try {
      // Vérifier les préférences de l'utilisateur
      const { data: prefs } = await supabase
        .from('notification_preferences')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (!prefs?.order_updates) {
        console.log('User has disabled order notifications');
        return;
      }

      const notification = {
        user_id: userId,
        type,
        title: this.getNotificationTitle(type),
        message: this.getNotificationMessage(type, orderId),
        data: { orderId, ...additionalData },
        read: false,
        created_at: new Date(),
        updated_at: new Date()
      };

      const { error } = await supabase
        .from('notifications')
        .insert([notification]);

      if (error) throw error;

      // Si l'email est activé, envoyer un email
      if (prefs.email) {
        // Implémenter l'envoi d'email ici
      }

      // Si le push est activé, envoyer une notification push
      if (prefs.push) {
        // Implémenter les notifications push ici
      }

    } catch (error) {
      console.error('Error creating notification:', error);
    }
  }

  private static getNotificationTitle(type: NotificationType): string {
    const titles = {
      ORDER_CREATED: 'New Order Created',
      ORDER_STATUS_UPDATED: 'Order Status Updated',
      ORDER_COLLECTED: 'Order Collected',
      ORDER_READY: 'Order Ready',
      ORDER_DELIVERED: 'Order Delivered',
      PAYMENT_RECEIVED: 'Payment Received',
      POINTS_EARNED: 'Points Earned',
      SPECIAL_OFFER: 'Special Offer Available'
    };
    return titles[type] || 'Notification';
  }

  private static getNotificationMessage(type: NotificationType, orderId: string): string {
    const messages = {
      ORDER_CREATED: `Your order #${orderId} has been created successfully.`,
      ORDER_STATUS_UPDATED: `The status of your order #${orderId} has been updated.`,
      ORDER_COLLECTED: `Your order #${orderId} has been collected.`,
      ORDER_READY: `Your order #${orderId} is ready for delivery.`,
      ORDER_DELIVERED: `Your order #${orderId} has been delivered.`,
      PAYMENT_RECEIVED: `Payment received for order #${orderId}.`,
      POINTS_EARNED: `You've earned points for order #${orderId}!`,
      SPECIAL_OFFER: 'Check out our special offer just for you!'
    };
    return messages[type] || 'You have a new notification';
  }

  static async createAffiliateNotification(
    affiliateId: string, 
    customerId: string,
    orderId: string,
    commission: number
  ): Promise<void> {
    const title = 'New Customer Order';
    const message = `A customer has placed an order using your affiliate code. Commission earned: $${commission}`;
    
    await this.create(
      affiliateId,
      'AFFILIATE_ORDER',
      title,
      message,
      { 
        orderId,
        customerId,
        commission 
      }
    );
  }

  private static getOrderNotificationContent(type: NotificationType, order: Order) {
    const notifications: Record<NotificationType, { title: string; message: string }> = {
      ORDER_CREATED: {
        title: 'Order Confirmed',
        message: `Your order #${order.id.slice(0, 8)} has been confirmed and is being processed.`
      },
      ORDER_STATUS_UPDATED: {
        title: 'Order Status Updated',
        message: `Your order #${order.id.slice(0, 8)} status has been updated to ${order.status}.`
      },
      ORDER_COLLECTED: {
        title: 'Items Collected',
        message: `Your items have been collected for order #${order.id.slice(0, 8)}.`
      },
      ORDER_READY: {
        title: 'Order Ready',
        message: `Your order #${order.id.slice(0, 8)} is ready for delivery!`
      },
      ORDER_DELIVERED: {
        title: 'Order Delivered',
        message: `Your order #${order.id.slice(0, 8)} has been delivered successfully.`
      },
      PAYMENT_RECEIVED: {
        title: 'Payment Received',
        message: `Payment for order #${order.id.slice(0, 8)} has been received.`
      },
      POINTS_EARNED: {
        title: 'Points Earned',
        message: `You've earned points for order #${order.id.slice(0, 8)}.`
      },
      SPECIAL_OFFER: {
        title: 'Special Offer',
        message: `Special offer available for your next order!`
      }
    };

    return notifications[type] || {
      title: 'Order Update',
      message: `Your order #${order.id.slice(0, 8)} has been updated.`
    };
  }

  static async getNotifications<T>(userId: string, pagination: PaginationParams): Promise<T[]> {
    const { offset = 0, limit = 10 } = pagination;
    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;
    return (data as T[]) || [];
  }

  static async getUserNotifications(
    userId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<{ notifications: Notification[], total: number }> {
    const offset = (page - 1) * limit;

    const { data, error, count } = await supabase
      .from('notifications')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return {
      notifications: data || [],
      total: count || 0
    };
  }

  static async getUnreadCount(userId: string): Promise<number> {
    const { count, error } = await supabase
      .from('notifications')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .eq('read', false);

    if (error) throw error;
    return count || 0;
  }

  static async markAsRead<T>(userId: string, notificationId: string): Promise<T> {
    const { data, error } = await supabase
      .from('notifications')
      .update({ read: true })
      .eq('user_id', userId)
      .eq('id', notificationId)
      .single();

    if (error) throw error;
    return data as T;
  }

  static async markAllAsRead(userId: string): Promise<void> {
    const { error } = await supabase
      .from('notifications')
      .update({ read: true })
      .eq('user_id', userId)
      .eq('read', false);

    if (error) throw error;
  }

  static async deleteNotification<T>(userId: string, notificationId: string): Promise<T> {
    const { data, error } = await supabase
      .from('notifications')
      .delete()
      .eq('user_id', userId)
      .eq('id', notificationId)
      .single();

    if (error) throw error;
    return data as T;
  }

  static async getNotificationPreferences<T>(userId: string): Promise<T | undefined> {
    const { data, error } = await supabase
      .from('notification_preferences')
      .select('preferences')
      .eq('user_id', userId)
      .single();

    if (error) throw error;
    return data?.preferences as T;
  }

  static async updateNotificationPreferences<T>(userId: string, preferences: any): Promise<T> {
    const { data, error } = await supabase
      .from('notification_preferences')
      .update({ preferences })
      .eq('user_id', userId)
      .single();

    if (error) throw error;
    return data as T;
  }
}
