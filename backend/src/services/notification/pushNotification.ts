import { createClient } from '@supabase/supabase-js';
import { Notification, NotificationType, NotificationStatus, DeliveryChannel, NotificationPriority } from '../../models/notification';
import { AppError, errorCodes } from '../../utils/errors';
import { notificationManagement } from './notificationManagement';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

class PushNotification {
  /**
   * Send push notification
   */
  async sendPushNotification(userId: string, title: string, message: string, data?: any): Promise<void> {
    try {
      // Get user's push notification token
      const { data: user, error: userError } = await supabase.from('users').select('fcmToken').eq('id', userId).single();

      if (userError) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const pushToken = user?.fcmToken;

      if (!pushToken) {
        console.log('No push token found for user:', userId);
        return;
      }

      // Create notification in database
      await notificationManagement.createNotification({
          recipientId: userId,
          title,
          message,
          type: NotificationType.SYSTEM,
          status: NotificationStatus.UNREAD,
          deliveryChannel: DeliveryChannel.IN_APP,
          recipientRole: 'customer',
          priority: NotificationPriority.LOW,
          isRead: false
      });

      // Send push notification (implementation depends on your push notification service)
      // Example using Firebase Cloud Messaging:
      try {
        // Replace with your push notification service implementation
        console.log('Sending push notification to:', pushToken);
        // Example implementation:
        // await admin.messaging().send({
        //   token: pushToken,
        //   notification: {
        //     title,
        //     body: message
        //   },
        //   data: data || {}
        // });
      } catch (error) {
        console.error('Failed to send push notification:', error);
        throw new AppError(500, 'Failed to send push notification', errorCodes.PUSH_NOTIFICATION_ERROR);
      }
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to process notification', errorCodes.DATABASE_ERROR);
    }
  }
}

export const pushNotification = new PushNotification();
