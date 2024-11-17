import { admin, db } from '../config/firebase';
import AppError from '../utils/AppError';
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
            await this.createNotification({
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

    /**
     * Send a referral invitation email
     * @param email Email address of the person being referred
     * @param referralCode Unique referral code for tracking
     */
    async sendReferralInvitation(email: string, referralCode: string): Promise<void> {
        try {
            // Email template for referral invitation
            const emailTemplate = {
                to: email, // Add 'to' property
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
            await sendEmail(emailTemplate); // Fix sendEmail usage

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
            throw new AppError('Failed to send referral invitation', 500, errorCodes.NOTIFICATION_SEND_ERROR);
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
            // Get affiliate details
            const affiliateDoc = await db.collection('affiliates').doc(affiliateId).get();
            const affiliate = affiliateDoc.data();

            if (!affiliate) {
                throw new AppError('Affiliate not found', 404, errorCodes.AFFILIATE_NOT_FOUND);
            }

            // Create notification
            await this.createNotification({
                userId: affiliateId,
                title: 'Commission Approved',
                message: `Your commission of ${commission.commissionAmount} FCFA for order #${commission.orderId} has been approved.`,
                type: NotificationType.PAYMENT_STATUS,
                status: NotificationStatus.UNREAD,
                data: {
                    orderId: commission.orderId,
                    orderAmount: commission.orderAmount,
                    commissionAmount: commission.commissionAmount
                }
            });

            // Send email notification if email is available
            if (affiliate.email) {
                const emailData = { // Create email data object
                    to: affiliate.email,
                    subject: 'Commission Approved - Alpha Laundry',
                    html: `
                        <h2>Commission Approved</h2>
                        <p>Hello ${affiliate.fullName},</p>
                        <p>Your commission for order #${commission.orderId} has been approved.</p>
                        <p><strong>Order Amount:</strong> ${commission.orderAmount} FCFA</p>
                        <p><strong>Commission Amount:</strong> ${commission.commissionAmount} FCFA</p>
                        <p>This amount has been added to your available balance. You can request a withdrawal at any time.</p>
                        <p>Thank you for being a valued affiliate partner!</p>
                        <br>
                        <p>Best regards,</p>
                        <p>Alpha Laundry Team</p>
                    `
                };
                await sendEmail(emailData); // Pass email data object to sendEmail
            }
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(
                'Failed to send commission approval notification',
                500,
                errorCodes.NOTIFICATION_SEND_ERROR
            );
        }
    }
}

export const notificationService = new NotificationService();
