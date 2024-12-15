import { Notification, NotificationType, NotificationPriority, NotificationStatus, DeliveryChannel } from '../models/notification';
import { AppError, errorCodes } from '../utils/errors';
import { notificationManagement } from './notification/notificationManagement';
import { pushNotification } from './notification/pushNotification';
import { referral } from './notification/referral';
import { commissionNotification } from './notification/commissionNotification';

export class NotificationService {
  /**
   * Create a new notification
   */
  async createNotification(notification: Omit<Notification, 'id' | 'createdAt'>): Promise<Notification> {
    try {
      const newNotification = {
        ...notification,
        createdAt: new Date().toISOString(),
        isRead: false
      };

      const { data } = await notificationManagement.createNotification(newNotification);

      if (!data) {
        throw new AppError(500, 'Failed to create notification', errorCodes.NOTIFICATION_CREATE_ERROR);
      }

      return { id: data.id, ...newNotification };
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to create notification', errorCodes.NOTIFICATION_CREATE_ERROR);
    }
  }

  /**
   * Get notifications for a user
   */
  async getUserNotifications(userId: string, status?: NotificationStatus): Promise<Notification[]> {
    try {
      return await notificationManagement.getUserNotifications(userId, status);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch user notifications', errorCodes.NOTIFICATION_FETCH_ERROR);
    }
  }

  /**
   * Get notification by id
   */
  async getNotification(notificationId: string): Promise<Notification> {
    try {
      return await notificationManagement.getNotification(notificationId);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch notification', errorCodes.NOTIFICATION_FETCH_ERROR);
    }
  }

  /**
   * Update notification
   */
  async updateNotification(notificationId: string, update: Partial<Notification>): Promise<void> {
    try {
      await notificationManagement.updateNotification(notificationId, update);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update notification', errorCodes.NOTIFICATION_UPDATE_ERROR);
    }
  }

  /**
   * Mark notification as read
   */
  async markAsRead(notificationId: string, userId: string): Promise<void> {
    try {
      await notificationManagement.markAsRead(notificationId, userId);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to mark notification as read', errorCodes.NOTIFICATION_UPDATE_ERROR);
    }
  }

  /**
   * Send push notification
   */
  async sendPushNotification(userId: string, title: string, message: string, data?: any): Promise<void> {
    try {
      await pushNotification.sendPushNotification(userId, title, message, data);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to send push notification', errorCodes.PUSH_NOTIFICATION_ERROR);
    }
  }

  /**
   * Delete notification
   */
  async deleteNotification(notificationId: string, userId: string): Promise<void> {
    try {
      await notificationManagement.deleteNotification(notificationId, userId);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to delete notification', errorCodes.NOTIFICATION_DELETE_ERROR);
    }
  }

  /**
   * Send a referral invitation email
   * @param email Email address of the person being referred
   * @param referralCode Unique referral code for tracking
   */
  async sendReferralInvitation(email: string, referralCode: string): Promise<void> {
    try {
      await referral.sendReferralInvitation(email, referralCode);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to send referral invitation', errorCodes.NOTIFICATION_SEND_ERROR);
    }
  }

  /**
   * Send a notification when a commission is approved
   */
  async sendCommissionApprovalNotification(
    affiliateId: string,
    commission: {
      orderId: string;
      orderAmount: number;
      commissionAmount: number;
    }
  ): Promise<void> {
    try {
      await commissionNotification.sendCommissionApprovalNotification(affiliateId, commission);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to send commission approval notification', errorCodes.NOTIFICATION_SEND_ERROR);
    }
  }
}

export const notificationService = new NotificationService();
