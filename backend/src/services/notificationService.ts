import { admin, db } from '../config/firebase';
import { AppError } from '../utils/AppError';
import { errorCodes } from '../utils/errors';
import { sendEmail } from '../utils/email';

export interface Notification {
    id?: string;
    userId: string;
    title: string;
    message: string;
    type: NotificationType;
    status: NotificationStatus;
    data?: any;
    createdAt: admin.firestore.Timestamp;
    updatedAt: admin.firestore.Timestamp;
}

export enum NotificationType {
    AFFILIATE_REQUEST = 'AFFILIATE_REQUEST',
    AFFILIATE_APPROVED = 'AFFILIATE_APPROVED',
    AFFILIATE_REJECTED = 'AFFILIATE_REJECTED',
    ORDER_STATUS = 'ORDER_STATUS',
    PAYMENT_STATUS = 'PAYMENT_STATUS',
    SYSTEM = 'SYSTEM',
    REFERRAL_INVITATION = 'REFERRAL_INVITATION'
}

export enum NotificationStatus {
    UNREAD = 'UNREAD',
    READ = 'READ',
    ARCHIVED = 'ARCHIVED'
}

class NotificationService {
    private notificationsRef = db.collection('notifications');

    /**
     * Create a new notification
     */
    async createNotification(notification: Omit<Notification, 'id' | 'createdAt' | 'updatedAt'>) {
        try {
            const now = admin.firestore.Timestamp.now();
            const newNotification = {
                ...notification,
                createdAt: now,
                updatedAt: now,
                status: NotificationStatus.UNREAD
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
    async getUserNotifications(userId: string, status?: NotificationStatus) {
        try {
            let query = this.notificationsRef.where('userId', '==', userId);
            
            if (status) {
                query = query.where('status', '==', status);
            }

            const snapshot = await query.orderBy('createdAt', 'desc').get();
            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
        } catch (error) {
            throw new AppError('Failed to fetch notifications', 500, errorCodes.NOTIFICATION_FETCH_ERROR);
        }
    }

    /**
     * Mark notification as read
     */
    async markAsRead(notificationId: string, userId: string) {
        try {
            const notificationRef = this.notificationsRef.doc(notificationId);
            const doc = await notificationRef.get();

            if (!doc.exists) {
                throw new AppError('Notification not found', 404, errorCodes.NOTIFICATION_NOT_FOUND);
            }

            const notification = doc.data() as Notification;
            if (notification.userId !== userId) {
                throw new AppError('Unauthorized access to notification', 403, errorCodes.UNAUTHORIZED);
            }

            await notificationRef.update({
                status: NotificationStatus.READ,
                updatedAt: admin.firestore.Timestamp.now()
            });

            return { success: true };
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to mark notification as read', 500, errorCodes.NOTIFICATION_UPDATE_ERROR);
        }
    }

    /**
     * Send push notification
     */
    async sendPushNotification(userId: string, title: string, message: string, data?: any) {
        try {
            const userDoc = await db.collection('users').doc(userId).get();
            if (!userDoc.exists) {
                throw new AppError('User not found', 404, errorCodes.USER_NOT_FOUND);
            }

            const userData = userDoc.data();
            if (!userData?.fcmToken) {
                return { success: false, reason: 'No FCM token found for user' };
            }

            const message = {
                notification: {
                    title,
                    body: message
                },
                data: data || {},
                token: userData.fcmToken
            };

            await admin.messaging().send(message);
            return { success: true };
        } catch (error) {
            throw new AppError('Failed to send push notification', 500, errorCodes.PUSH_NOTIFICATION_ERROR);
        }
    }

    /**
     * Delete notification
     */
    async deleteNotification(notificationId: string, userId: string) {
        try {
            const notificationRef = this.notificationsRef.doc(notificationId);
            const doc = await notificationRef.get();

            if (!doc.exists) {
                throw new AppError('Notification not found', 404, errorCodes.NOTIFICATION_NOT_FOUND);
            }

            const notification = doc.data() as Notification;
            if (notification.userId !== userId) {
                throw new AppError('Unauthorized access to notification', 403, errorCodes.UNAUTHORIZED);
            }

            await notificationRef.delete();
            return { success: true };
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to delete notification', 500, errorCodes.NOTIFICATION_DELETE_ERROR);
        }
    }

    /**
     * Send a referral invitation email
     * @param email Email address of the person being referred
     * @param referralCode Unique referral code for tracking
     */
    async sendReferralInvitation(email: string, referralCode: string): Promise<void> {
        try {
            // Email template for referral invitation
            const emailTemplate = {
                subject: 'You\'ve Been Invited to Join Our Platform!',
                html: `
                    <h2>Welcome to Our Platform!</h2>
                    <p>You've been invited to join our platform. Use the referral code below to get special benefits when you sign up:</p>
                    <div style="background-color: #f5f5f5; padding: 15px; margin: 20px 0; text-align: center; font-size: 24px; font-weight: bold;">
                        ${referralCode}
                    </div>
                    <p>Benefits of joining with this referral code:</p>
                    <ul>
                        <li>Special welcome bonus</li>
                        <li>Exclusive first-time offers</li>
                        <li>Additional rewards on your first purchase</li>
                    </ul>
                    <p>Click the link below to get started:</p>
                    <a href="${process.env.FRONTEND_URL}/signup?referralCode=${referralCode}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
                        Sign Up Now
                    </a>
                    <p>This referral code will expire in 30 days.</p>
                `
            };

            // Send the email
            await sendEmail(email, emailTemplate.subject, emailTemplate.html);

            // Log the invitation in notifications collection
            await this.createNotification({
                userId: email, // Using email as userId for non-registered users
                title: 'Referral Invitation Sent',
                message: `Referral invitation sent to ${email} with code ${referralCode}`,
                type: NotificationType.REFERRAL_INVITATION,
                status: NotificationStatus.UNREAD,
                data: {
                    referralCode,
                    email
                }
            });

        } catch (error) {
            throw new AppError(
                'Failed to send referral invitation',
                500,
                errorCodes.NOTIFICATION_SEND_ERROR
            );
        }
    }
}

export const notificationService = new NotificationService();
