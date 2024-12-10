import { admin, db } from '../../config/firebase';
import AppError from '../../utils/AppError';
import { errorCodes } from '../../utils/errors';
import { Notification, NotificationStatus, NotificationType } from '../notificationService';

class NotificationManagement {
    private notificationsRef = db.collection('notifications');

    /**
     * Create a new notification
     */
    async createNotification(notification: Omit<Notification, 'id' | 'createdAt' | 'updatedAt'>): Promise<Notification> {
        try {
            const newNotification = {
                ...notification,
                createdAt: admin.firestore.Timestamp.now(),
                updatedAt: admin.firestore.Timestamp.now()
            };

            const docRef = await this.notificationsRef.add(newNotification);
            return { id: docRef.id, ...newNotification };
        } catch (error) {
            throw new AppError('Failed to create notification', 500, errorCodes.NOTIFICATION_CREATE_ERROR);
        }
    }

    /**
     * Get notifications for a user
     */
    async getUserNotifications(userId: string, status?: NotificationStatus): Promise<Notification[]> {
        try {
            let query = this.notificationsRef.where('userId', '==', userId);
            
            if (status) {
                query = query.where('status', '==', status);
            }

            const snapshot = await query.orderBy('createdAt', 'desc').get();
            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            })) as Notification[];
        } catch (error) {
            throw new AppError('Failed to fetch notifications', 500, errorCodes.NOTIFICATION_FETCH_ERROR);
        }
    }

    /**
     * Get notification by id
     */
    async getNotification(notificationId: string): Promise<Notification> {
        try {
            const doc = await this.notificationsRef.doc(notificationId).get();
            if (!doc.exists) {
                throw new AppError('Notification not found', 404, errorCodes.NOTIFICATION_NOT_FOUND);
            }
            return { id: doc.id, ...doc.data() } as Notification;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to fetch notification', 500, errorCodes.NOTIFICATION_FETCH_ERROR);
        }
    }

    /**
     * Update notification
     */
    async updateNotification(notificationId: string, update: Partial<Notification>): Promise<void> {
        try {
            const doc = await this.notificationsRef.doc(notificationId).get();
            if (!doc.exists) {
                throw new AppError('Notification not found', 404, errorCodes.NOTIFICATION_NOT_FOUND);
            }

            await this.notificationsRef.doc(notificationId).update({
                ...update,
                updatedAt: admin.firestore.Timestamp.now()
            });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to update notification', 500, errorCodes.NOTIFICATION_UPDATE_ERROR);
        }
    }

    /**
     * Mark notification as read
     */
    async markAsRead(notificationId: string, userId: string): Promise<void> {
        try {
            await this.updateNotification(notificationId, { status: NotificationStatus.READ });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to mark notification as read', 500, errorCodes.NOTIFICATION_UPDATE_ERROR);
        }
    }

    /**
     * Delete notification
     */
    async deleteNotification(notificationId: string, userId: string): Promise<void> {
        try {
            const doc = await this.notificationsRef.doc(notificationId).get();
            if (!doc.exists) {
                throw new AppError('Notification not found', 404, errorCodes.NOTIFICATION_NOT_FOUND);
            }

            const notification = doc.data() as Notification;
            if (notification.userId !== userId) {
                throw new AppError('Unauthorized access to notification', 403, errorCodes.UNAUTHORIZED);
            }

            await this.notificationsRef.doc(notificationId).delete();
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to delete notification', 500, errorCodes.NOTIFICATION_DELETE_ERROR);
        }
    }
}

export const notificationManagement = new NotificationManagement();
