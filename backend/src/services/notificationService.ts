import { admin } from '../config/firebase';
import { notificationManagement } from './notification/notificationManagement';
import { pushNotification } from './notification/pushNotification';
import { referral } from './notification/referral';
import { commissionNotification } from './notification/commissionNotification';

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
    /**
     * Create a new notification
     */
    async createNotification(notification: Omit<Notification, 'id' | 'createdAt' | 'updatedAt'>): Promise<Notification> {
        return notificationManagement.createNotification(notification);
    }

    /**
     * Get notifications for a user
     */
    async getUserNotifications(userId: string, status?: NotificationStatus): Promise<Notification[]> {
        return notificationManagement.getUserNotifications(userId, status);
    }

    /**
     * Get notification by id
     */
    async getNotification(notificationId: string): Promise<Notification> {
        return notificationManagement.getNotification(notificationId);
    }

    /**
     * Update notification
     */
    async updateNotification(notificationId: string, update: Partial<Notification>): Promise<void> {
        return notificationManagement.updateNotification(notificationId, update);
    }

    /**
     * Mark notification as read
     */
    async markAsRead(notificationId: string, userId: string): Promise<void> {
        return notificationManagement.markAsRead(notificationId, userId);
    }

    /**
     * Send push notification
     */
    async sendPushNotification(userId: string, title: string, message: string, data?: any): Promise<void> {
        return pushNotification.sendPushNotification(userId, title, message, data);
    }

    /**
     * Delete notification
     */
    async deleteNotification(notificationId: string, userId: string): Promise<void> {
        return notificationManagement.deleteNotification(notificationId, userId);
    }

    /**
     * Send a referral invitation email
     * @param email Email address of the person being referred
     * @param referralCode Unique referral code for tracking
     */
    async sendReferralInvitation(email: string, referralCode: string): Promise<void> {
        return referral.sendReferralInvitation(email, referralCode);
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
        return commissionNotification.sendCommissionApprovalNotification(affiliateId, commission);
    }
}

export const notificationService = new NotificationService();
