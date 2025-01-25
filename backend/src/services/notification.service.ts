import supabase from '../config/database';
import { NotificationType, User } from '../models/types';

export class NotificationService {
  /**
   * Envoie une notification basée sur un événement et des règles
   */
  static async sendNotification(
    userId: string,
    type: NotificationType,
    data: any = {}
  ): Promise<void> {
    try {
      // 1. Récupérer l'utilisateur et ses préférences
      const { data: user } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();

      if (!user) throw new Error('User not found');

      // 2. Récupérer la règle de notification appropriée
      const { data: rule } = await supabase
        .from('notification_rules')
        .select('*')
        .eq('event_type', type)
        .eq('user_role', user.role)
        .eq('is_active', true)
        .single();

      if (!rule) {
        console.log(`No notification rule found for type ${type} and role ${user.role}`);
        return;
      }

      // 3. Construire le message à partir du template
      const message = this.buildNotificationMessage(rule.template, {
        ...data,
        userName: `${user.first_name} ${user.last_name}`,
      });

      // 4. Créer la notification en base
      await this.createDatabaseNotification(userId, type, message, data);

    } catch (error) {
      console.error('[NotificationService] Error sending notification:', error);
      throw new Error('Failed to send notification');
    }
  }

  /**
   * Envoie une notification concernant une commande
   */
  static async createOrderNotification(
    userId: string,
    orderId: string,
    type: NotificationType,
    additionalData: any = {}
  ): Promise<void> {
    try {
      // 1. Récupérer les détails de la commande
      const { data: order } = await supabase
        .from('orders')
        .select(`
          *,
          service:services(name),
          items:order_items(
            quantity,
            article:articles(name)
          )
        `)
        .eq('id', orderId)
        .single();

      if (!order) throw new Error('Order not found');

      // 2. Préparer les données pour la notification
      const notificationData = {
        orderId,
        orderStatus: order.status,
        serviceName: order.service?.name,
        totalAmount: order.totalAmount,
        items: order.items?.map((item: any) => ({
          name: item.article?.name,
          quantity: item.quantity
        })),
        ...additionalData
      };

      // 3. Envoyer la notification au client
      await this.sendNotification(userId, type, notificationData);

      // 4. Si la commande a un code affilié, notifier l'affilié
      if (order.affiliateCode) {
        const { data: affiliate } = await supabase
          .from('affiliate_profiles')
          .select('user_id')
          .eq('affiliate_code', order.affiliateCode)
          .single();

        if (affiliate) {
          await this.sendAffiliateNotification(
            affiliate.user_id,
            orderId,
            order.totalAmount
          );
        }
      }

      // 5. Notifier les admins si nécessaire
      if (['READY', 'DELIVERED'].includes(order.status)) {
        await this.notifyAdmins('ORDER_STATUS_UPDATED', {
          orderId,
          status: order.status,
          totalAmount: order.totalAmount
        });
      }

    } catch (error) {
      console.error('[NotificationService] Error creating order notification:', error);
      throw new Error('Failed to create order notification');
    }
  }

  /**
   * Envoie une notification à un affilié
   */
  static async sendAffiliateNotification(
    affiliateUserId: string,
    orderId: string,
    orderAmount: number
  ): Promise<void> {
    try {
      const { data: affiliate } = await supabase
        .from('affiliate_profiles')
        .select('*')
        .eq('user_id', affiliateUserId)
        .single();

      if (!affiliate) return;

      const commissionAmount = orderAmount * (affiliate.commission_rate / 100);

      await this.sendNotification(affiliateUserId, 'ORDER_CREATED', {
        orderId,
        orderAmount,
        commissionAmount,
        currentBalance: affiliate.commission_balance + commissionAmount
      });

    } catch (error) {
      console.error('[NotificationService] Error sending affiliate notification:', error);
      throw new Error('Failed to send affiliate notification');
    }
  }

  /**
   * Notifie tous les administrateurs
   */
  private static async notifyAdmins(
    type: NotificationType,
    data: any
  ): Promise<void> {
    try {
      // Récupérer tous les admins
      const { data: admins } = await supabase
        .from('users')
        .select('id')
        .in('role', ['ADMIN', 'SUPER_ADMIN']);

      if (!admins) return;

      // Envoyer la notification à chaque admin
      for (const admin of admins) {
        await this.sendNotification(admin.id, type, data);
      }

    } catch (error) {
      console.error('[NotificationService] Error notifying admins:', error);
      throw new Error('Failed to notify admins');
    }
  }

  /**
   * Crée une notification en base de données
   */
  private static async createDatabaseNotification(
    userId: string,
    type: NotificationType,
    message: string,
    data: any = {}
  ): Promise<void> {
    try {
      const { error } = await supabase
        .from('notifications')
        .insert([{
          user_id: userId,
          type,
          message,
          data,
          read: false
        }]);

      if (error) throw error;

    } catch (error) {
      console.error('[NotificationService] Error creating database notification:', error);
      throw new Error('Failed to create database notification');
    }
  }

  /**
   * Construit un message de notification à partir d'un template
   */
  static async getUserNotifications(userId: string, page = 1, limit = 20) {
    try {
      const { data, error, count } = await supabase
        .from('notifications')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1);

      if (error) throw error;

      return {
        notifications: data || [],
        total: count || 0,
        page,
        totalPages: Math.ceil((count || 0) / limit)
      };
    } catch (error) {
      console.error('[NotificationService] Error getting user notifications:', error);
      throw new Error('Failed to get user notifications');
    }
  }

  static async getUnreadCount(userId: string): Promise<number> {
    try {
      const { count, error } = await supabase
        .from('notifications')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)
        .eq('read', false);

      if (error) throw error;
      return count || 0;
    } catch (error) {
      console.error('[NotificationService] Error getting unread count:', error);
      throw new Error('Failed to get unread count');
    }
  }

  static async markAsRead(userId: string, notificationId: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ read: true })
        .eq('id', notificationId)
        .eq('user_id', userId);

      if (error) throw error;
    } catch (error) {
      console.error('[NotificationService] Error marking notification as read:', error);
      throw new Error('Failed to mark notification as read');
    }
  }

  static async markAllAsRead(userId: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ read: true })
        .eq('user_id', userId)
        .eq('read', false);

      if (error) throw error;
    } catch (error) {
      console.error('[NotificationService] Error marking all notifications as read:', error);
      throw new Error('Failed to mark all notifications as read');
    }
  }

  static async deleteNotification(userId: string, notificationId: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', userId);

      if (error) throw error;
    } catch (error) {
      console.error('[NotificationService] Error deleting notification:', error);
      throw new Error('Failed to delete notification');
    }
  }

  static async getNotificationPreferences(userId: string): Promise<any> {
    try {
      const { data, error } = await supabase
        .from('notification_preferences')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[NotificationService] Error getting notification preferences:', error);
      throw new Error('Failed to get notification preferences');
    }
  }

  static async updateNotificationPreferences(userId: string, preferences: any): Promise<void> {
    try {
      const { error } = await supabase
        .from('notification_preferences')
        .upsert({
          user_id: userId,
          ...preferences,
          updated_at: new Date().toISOString()
        });

      if (error) throw error;
    } catch (error) {
      console.error('[NotificationService] Error updating notification preferences:', error);
      throw new Error('Failed to update notification preferences');
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
}
