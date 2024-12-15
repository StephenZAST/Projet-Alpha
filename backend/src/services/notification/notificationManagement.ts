import { createClient } from '@supabase/supabase-js';
import { Notification, NotificationType, NotificationStatus, DeliveryChannel } from '../../models/notification';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const notificationsTable = 'notifications';

class NotificationManagement {

  async createNotification(notification: Omit<Notification, 'id' | 'createdAt' | 'updatedAt'>): Promise<Notification> {
    try {
      const newNotification = {
        ...notification,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      const { data, error } = await supabase.from(notificationsTable).insert([newNotification]).select().single();

      if (error) {
        throw new AppError(500, 'Failed to create notification', errorCodes.NOTIFICATION_CREATE_ERROR);
      }

      return { id: data.id, ...newNotification };
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to create notification', errorCodes.NOTIFICATION_CREATE_ERROR);
    }
  }

  async getUserNotifications(userId: string, status?: NotificationStatus): Promise<Notification[]> {
    try {
      let query = supabase.from(notificationsTable).select('*').eq('recipientId', userId);

      if (status) {
        query = query.eq('status', status);
      }

      // Ensure the order method accepts the 'createdAt' string column name
      query = query.order('createdAt', { ascending: false });

      const { data, error } = await query;

      if (error) {
        throw new AppError(500, 'Failed to fetch notifications', errorCodes.NOTIFICATION_FETCH_ERROR);
      }

      return data as Notification[];
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch notifications', errorCodes.NOTIFICATION_FETCH_ERROR);
    }
  }

  async getNotification(notificationId: string): Promise<Notification> {
    try {
      const { data, error } = await supabase.from(notificationsTable).select('*').eq('id', notificationId).single();

      if (error) {
        throw new AppError(404, 'Notification not found', errorCodes.NOTIFICATION_NOT_FOUND);
      }

      return data as Notification;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch notification', errorCodes.NOTIFICATION_FETCH_ERROR);
    }
  }

  async updateNotification(notificationId: string, update: Partial<Notification>): Promise<void> {
    try {
      const { data, error } = await supabase.from(notificationsTable).update({
        ...update,
        updatedAt: new Date().toISOString()
      }).eq('id', notificationId);

      if (error) {
        throw new AppError(500, 'Failed to update notification', errorCodes.NOTIFICATION_UPDATE_ERROR);
      }

      if (!data) {
        throw new AppError(404, 'Notification not found', errorCodes.NOTIFICATION_NOT_FOUND);
      }
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update notification', errorCodes.NOTIFICATION_UPDATE_ERROR);
    }
  }

  async markAsRead(notificationId: string, userId: string): Promise<void> {
    try {
      await this.updateNotification(notificationId, { status: NotificationStatus.READ });
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to mark notification as read', errorCodes.NOTIFICATION_UPDATE_ERROR);
    }
  }

  async deleteNotification(notificationId: string, userId: string): Promise<void> {
    try {
      const { data, error } = await supabase.from(notificationsTable).select('*').eq('id', notificationId).single();

      if (error) {
        throw new AppError(404, 'Notification not found', errorCodes.NOTIFICATION_NOT_FOUND);
      }

      const notification = data as Notification;
      if (notification.recipientId !== userId) {
        throw new AppError(403, 'Unauthorized access to notification', errorCodes.UNAUTHORIZED);
      }

      const { error: deleteError } = await supabase.from(notificationsTable).delete().eq('id', notificationId);

      if (deleteError) {
        throw new AppError(500, 'Failed to delete notification', errorCodes.NOTIFICATION_DELETE_ERROR);
      }
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to delete notification', errorCodes.NOTIFICATION_DELETE_ERROR);
    }
  }
}

export const notificationManagement = new NotificationManagement();
