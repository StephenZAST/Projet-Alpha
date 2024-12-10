import { admin, db } from '../../config/firebase';
import AppError from '../../utils/AppError';
import { errorCodes } from '../../utils/errors';
import { NotificationStatus, NotificationType } from '../notificationService';
import { notificationManagement } from './notificationManagement';

class PushNotification {
    /**
     * Send push notification
     */
    async sendPushNotification(userId: string, title: string, message: string, data?: any): Promise<void> {
        try {
            // Get user's push notification token
            const userDoc = await db.collection('users').doc(userId).get();
            if (!userDoc.exists) {
                throw new AppError('User not found', 404, errorCodes.USER_NOT_FOUND);
            }

            const userData = userDoc.data();
            const pushToken = userData?.fcmToken;

            if (!pushToken) {
                console.log('No push token found for user:', userId);
                return;
            }

            // Create notification in database
            await notificationManagement.createNotification({
                userId,
                title,
                message,
                type: NotificationType.SYSTEM,
                status: NotificationStatus.UNREAD
            });

            // Send push notification (implementation depends on your push notification service)
            // Example using Firebase Cloud Messaging:
            try {
                await admin.messaging().send({
                    token: pushToken,
                    notification: {
                        title,
                        body: message
                    },
                    data: data || {}
                });
            } catch (error) {
                console.error('Failed to send push notification:', error);
                throw new AppError('Failed to send push notification', 500, errorCodes.PUSH_NOTIFICATION_ERROR);
            }
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to process notification', 500, errorCodes.NOTIFICATION_CREATE_ERROR);
        }
    }
}

export const pushNotification = new PushNotification();
