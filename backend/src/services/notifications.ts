import { db } from './firebase';
import { Notification, NotificationType } from '../models/notification';
import * as admin from 'firebase-admin';

export class NotificationService {
  private readonly notificationsRef = db.collection('notifications');

  async createNotification(notification: Omit<Notification, 'id' | 'createdAt'>): Promise<string> {
    const newNotification = {
      ...notification,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    };

    const docRef = await this.notificationsRef.add(newNotification);
    return docRef.id;
  }

  async sendOrderStatusNotification(
    orderId: string,
    userId: string,
    status: string,
    additionalData?: Record<string, any>
  ) {
    const notification = {
      type: NotificationType.ORDER_STATUS_UPDATE,
      recipientId: userId,
      recipientRole: 'customer' as 'customer' | 'affiliate' | 'admin',  // Fixed type
      title: 'Order Status Update',
      message: `Your order #${orderId} status has been updated to: ${status}`,
      data: {
        orderId,
        status,
        ...additionalData
      },
      isRead: false
    };

    return this.createNotification(notification);
  }
  async sendAffiliateCommissionNotification(
    affiliateId: string,
    amount: number,
    orderId: string
  ) {
    const notification = {
      type: NotificationType.COMMISSION_EARNED,
      recipientId: affiliateId,
      recipientRole: 'affiliate' as 'customer' | 'affiliate' | 'admin',
      title: 'Commission Earned',
      message: `You've earned a commission of ${amount} from order #${orderId}`,
      data: {
        orderId,
        amount
      },
      isRead: false
    };

    return this.createNotification(notification);
  }

  async sendLoyaltyPointsReminder(
    userId: string,
    points: number
  ) {
    const notification = {
      type: NotificationType.LOYALTY_POINTS_REMINDER,
      recipientId: userId,
      recipientRole: 'customer' as 'customer' | 'affiliate' | 'admin',
      title: 'Redeem Your Loyalty Points',
      message: `You have ${points} points available to redeem for discounts or gifts!`,
      data: {
        points
      },
      isRead: false
    };

    return this.createNotification(notification);
  }
  async broadcastPromotion(
    title: string,
    message: string,
    userRole: 'customer' | 'affiliate',
    expiresAt?: Date
  ) {
    const batch = db.batch();
    
    const usersSnapshot = await db.collection('users')
      .where('role', '==', userRole)
      .get();

    usersSnapshot.docs.forEach(doc => {
      const notificationRef = this.notificationsRef.doc();
      batch.set(notificationRef, {
        type: NotificationType.PROMOTION_AVAILABLE,
        recipientId: doc.id,
        recipientRole: userRole,
        title,
        message,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt
      });
    });

    return batch.commit();
  }

  async markAsRead(notificationId: string, userId: string): Promise<boolean> {
    try {
      await this.notificationsRef.doc(notificationId).update({
        isRead: true,
        readAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return true;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      return false;
    }
  }

  async getUserNotifications(userId: string, limit = 50): Promise<Notification[]> {
    const snapshot = await this.notificationsRef
      .where('recipientId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Notification));
  }
}