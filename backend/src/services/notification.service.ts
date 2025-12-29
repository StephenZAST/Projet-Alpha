import { PrismaClient, Prisma, orders, order_items } from '@prisma/client';
import { NotificationType, User, NotificationCreate, NotificationTemplate, Order } from '../models/types';
import { NotificationChannels } from './notificationChannels';
import { 
  NotificationChannel, 
  NotificationPriority,
  NOTIFICATION_CHANNELS_MAP,
  NOTIFICATION_PRIORITY_MAP
} from '../types/notification.types';

const prisma = new PrismaClient();

interface OrderWithRelations extends orders {
  order_items?: (order_items & {
    article: {
      name: string;
    };
  })[];
  service_types?: {
    name: string;
  };
}

export class NotificationService {
  static async sendNotification(
    userId: string,
    type: NotificationType,
    data: any = {}
  ): Promise<void> {
    try {
      const user = await prisma.users.findUnique({
        where: { id: userId }
      });

      if (!user) throw new Error('User not found');

      const rule = await prisma.notification_rules.findFirst({
        where: {
          event_type: type,
          user_role: user.role || 'CLIENT',
          is_active: true
        }
      });

      if (!rule) {
        console.log(`No notification rule found for type ${type} and role ${user.role || 'CLIENT'}`);
        return;
      }

      const message = this.buildNotificationMessage(rule.template || '', {
        ...data,
        userName: `${user.first_name} ${user.last_name}`,
      });

      await this.createDatabaseNotification(userId, type, message, data);

    } catch (error) {
      console.error('[NotificationService] Error sending notification:', error);
      throw error;
    }
  }

  static async createOrderNotification(
    userId: string,
    orderId: string,
    type: NotificationType,
    additionalData: any = {}
  ): Promise<void> {
    try {
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          service_types: {
            select: {
              name: true
            }
          },
          order_items: {
            include: {
              article: {
                select: {
                  name: true
                }
              }
            }
          }
        }
      }) as OrderWithRelations | null;

      if (!order) throw new Error('Order not found');

      const notificationData = {
        orderId,
        orderStatus: order.status,
        serviceName: order.service_types?.name,
        totalAmount: order.totalAmount,
        items: order.order_items?.map(item => ({
          name: item.article?.name ?? 'Unknown Article',
          quantity: item.quantity
        })),
        ...additionalData
      };

      await this.sendNotification(userId, type, notificationData);

      if (order.affiliateCode) {
        const affiliate = await prisma.affiliate_profiles.findFirst({
          where: { affiliate_code: order.affiliateCode }
        });

        if (affiliate) {
          await this.sendAffiliateNotification(
            affiliate.userId,
            orderId,
            Number(order.totalAmount)
          );
        }
      }

      if (['READY', 'DELIVERED'].includes(order.status || '')) {
        await this.notifyAdminsInternal(NotificationType.ORDER_STATUS_UPDATED, {
          orderId,
          status: order.status,
          totalAmount: order.totalAmount
        });
      }

    } catch (error) {
      console.error('[NotificationService] Error creating order notification:', error);
      throw error;
    }
  }

  static async sendAffiliateNotification(
    affiliateUserId: string,
    orderId: string,
    orderAmount: number
  ): Promise<void> {
    try {
      const affiliate = await prisma.affiliate_profiles.findFirst({
        where: { userId: affiliateUserId }
      });

      if (!affiliate) return;

      const commissionAmount = orderAmount * (Number(affiliate.commission_rate) / 100);

      await this.sendNotification(affiliateUserId, NotificationType.ORDER_CREATED, {
        orderId,
        orderAmount,
        commissionAmount,
        currentBalance: Number(affiliate.commission_balance) + commissionAmount
      });

    } catch (error) {
      console.error('[NotificationService] Error sending affiliate notification:', error);
      throw error;
    }
  }

  private static async notifyAdminsInternal(
    type: NotificationType,
    data: any
  ): Promise<void> {
    try {
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        }
      });

      await Promise.all(
        admins.map(admin => this.sendNotification(admin.id, type, data))
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying admins:', error);
      throw error;
    }
  }

  private static async createDatabaseNotification(
    userId: string,
    type: NotificationType,
    message: string,
    data: any = {}
  ): Promise<void> {
    try {
      await prisma.notifications.create({
        data: {
          userId: userId,
          type,
          message,
          data,
          read: false,
          created_at: new Date(),
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error creating database notification:', error);
      throw error;
    }
  }

  static async getUserNotifications(userId: string, page = 1, limit = 20) {
    try {
      const [notifications, total] = await prisma.$transaction([
        prisma.notifications.findMany({
          where: { userId: userId },
          orderBy: { created_at: 'desc' },
          skip: (page - 1) * limit,
          take: limit
        }),
        prisma.notifications.count({
          where: { userId: userId }
        })
      ]);

      return {
        notifications,
        total,
        page,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('[NotificationService] Error getting user notifications:', error);
      throw error;
    }
  }

  static async getUnreadCount(userId: string): Promise<number> {
    try {
      return await prisma.notifications.count({
        where: {
          userId: userId,
          read: false
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error getting unread count:', error);
      throw error;
    }
  }

  static async markAsRead(userId: string, notificationId: string): Promise<void> {
    try {
      await prisma.notifications.updateMany({
        where: {
          id: notificationId,
          userId: userId
        },
        data: {
          read: true,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error marking notification as read:', error);
      throw error;
    }
  }

  static async markAllAsRead(userId: string): Promise<void> {
    try {
      await prisma.notifications.updateMany({
        where: {
          userId: userId,
          read: false
        },
        data: {
          read: true,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error marking all notifications as read:', error);
      throw error;
    }
  }

  static async deleteNotification(userId: string, notificationId: string): Promise<void> {
    try {
      await prisma.notifications.deleteMany({
        where: {
          id: notificationId,
          userId: userId
        }
      });
    } catch (error) {
      console.error('[NotificationService] Error deleting notification:', error);
      throw error;
    }
  }

  static async getNotificationPreferences(userId: string): Promise<any> {
    try {
      return await prisma.notification_preferences.findFirst({
        where: { userId: userId }
      });
    } catch (error) {
      console.error('[NotificationService] Error getting notification preferences:', error);
      throw error;
    }
  }

  static async updateNotificationPreferences(userId: string, preferences: any): Promise<void> {
    try {
      const existingPreferences = await prisma.notification_preferences.findFirst({
        where: { userId: userId }
      });

      if (existingPreferences) {
        await prisma.notification_preferences.update({
          where: { id: existingPreferences.id },
          data: {
            ...preferences,
            updated_at: new Date()
          }
        });
      } else {
        await prisma.notification_preferences.create({
          data: {
            userId: userId,
            ...preferences,
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }
    } catch (error) {
      console.error('[NotificationService] Error updating notification preferences:', error);
      throw error;
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

  static async createNotification(
    userId: string,
    type: NotificationType,
    message: string,
    data?: Record<string, any>
  ): Promise<void>;
  static async createNotification(notification: NotificationCreate): Promise<void>;
  static async createNotification(
    userIdOrNotification: string | NotificationCreate,
    type?: NotificationType,
    message?: string,
    data: Record<string, any> = {}
  ): Promise<void> {
    try {
      if (typeof userIdOrNotification === 'object') {
        const notification = userIdOrNotification;
        
        if (!Object.values(NotificationType).includes(notification.type)) {
          throw new Error(`Invalid notification type: ${notification.type}`);
        }

        await prisma.notifications.create({
          data: {
            userId: notification.user_id,
            type: notification.type,
            message: notification.message,
            data: notification.data || {},
            read: notification.read ?? false,
            created_at: notification.created_at ? new Date(notification.created_at) : new Date(),
            updated_at: notification.updated_at ? new Date(notification.updated_at) : new Date()
          }
        });
      } else {
        const existing = await prisma.notifications.findFirst({
          where: {
            userId: userIdOrNotification,
            type: type as string,
            message: message as string,
            read: false
          },
          orderBy: {
            created_at: 'desc'
          }
        });

        if (existing) {
          console.log('[NotificationService] Similar notification exists, skipping');
          return;
        }

        await prisma.notifications.create({
          data: {
            userId: userIdOrNotification,
            type: type as string,
            message: message as string,
            data,
            read: false,
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }
    } catch (error) {
      console.error('[NotificationService] Unexpected error:', error);
      throw error;
    }
  }

  static async sendOrderNotification(order: Order): Promise<void> {
    try {
      const rules = await prisma.notification_rules.findMany({
        where: {
          event_type: NotificationType.ORDER_CREATED,
          is_active: true
        }
      });

      if (!rules?.length) {
        console.log('[NotificationService] No active rules found');
        return;
      }

      const users = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN', 'DELIVERY']
          }
        }
      });

      if (!users?.length) return;

      await Promise.all(
        users.map(user =>
          this.sendNotification(
            user.id,
            NotificationType.ORDER_CREATED,
            {
              orderId: order.id,
              total: order.totalAmount,
              items: order.items?.length || 0,
              address: order.address_id
            }
          )
        )
      );
    } catch (error) {
      console.error('[NotificationService] Error sending order notification:', error);
      throw error;
    }
  }

  static async sendRoleBasedNotifications(
    order: Order,
    templateData: NotificationTemplate
  ): Promise<void> {
    try {
      const users = await prisma.users.findMany({
        where: {
          role: {
            in: ['SUPER_ADMIN', 'ADMIN', 'DELIVERY']
          }
        }
      });

      if (!users?.length) return;

      await Promise.all(
        users.map(user =>
          this.sendNotification(
            user.id,
            NotificationType.ORDER_CREATED,
            {
              orderId: order.id,
              title: templateData.title,
              clientName: templateData.clientName,
              message: templateData.message,
              deliveryZone: templateData.deliveryZone,
              itemCount: templateData.itemCount,
              amount: user.role === 'DELIVERY' ? undefined : templateData.amount
            }
          )
        )
      );
    } catch (error) {
      console.error('[NotificationService] Error sending role-based notifications:', error);
      throw error;
    }
  }

  // ============================================================================
  // 🔔 LES 18 MÉTHODES D'ÉVÉNEMENTS SPÉCIFIQUES
  // ============================================================================

  /**
   * LOYALTY (2 événements)
   */

  /**
   * Notifier l'utilisateur que sa réclamation de récompense a été approuvée
   */
  static async notifyRewardApproved(
    userId: string,
    rewardId: string,
    rewardName: string,
    pointsValue: number,
    claimId: string
  ): Promise<void> {
    try {
      console.log(`🎁 [NotificationService] Reward approved notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP'],
        '✅ Récompense Approuvée',
        `Votre récompense "${rewardName}" a été approuvée! Vous avez utilisé ${pointsValue} points.`,
        {
          rewardId,
          rewardName,
          pointsValue,
          claimId,
          type: 'REWARD_CLAIM_APPROVED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying reward approved:', error);
    }
  }

  /**
   * Notifier l'utilisateur que sa réclamation de récompense a été rejetée
   */
  static async notifyRewardRejected(
    userId: string,
    rewardId: string,
    rewardName: string,
    rejectionReason: string,
    pointsRefunded: number,
    claimId: string
  ): Promise<void> {
    try {
      console.log(`❌ [NotificationService] Reward rejected notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '❌ Récompense Rejetée',
        `Votre récompense "${rewardName}" a été rejetée. Raison: ${rejectionReason}. ${pointsRefunded} points ont été remboursés.`,
        {
          rewardId,
          rewardName,
          rejectionReason,
          pointsRefunded,
          claimId,
          type: 'REWARD_CLAIM_REJECTED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying reward rejected:', error);
    }
  }

  /**
   * ORDERS (5 événements)
   */

  /**
   * Notifier l'utilisateur que sa commande a été créée
   */
  static async notifyOrderPlaced(
    userId: string,
    orderId: string,
    totalAmount: number,
    itemCount: number,
    clientName?: string
  ): Promise<void> {
    try {
      console.log(`📦 [NotificationService] Order placed notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '📦 Commande Créée',
        `Votre commande #${orderId.substring(0, 8)} a été créée avec succès. Montant: ${totalAmount}€ (${itemCount} article(s)).`,
        {
          orderId,
          totalAmount,
          itemCount,
          clientName,
          type: 'ORDER_PLACED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying order placed:', error);
    }
  }

  /**
   * Notifier l'utilisateur que le paiement de sa commande a échoué
   */
  static async notifyPaymentFailed(
    userId: string,
    orderId: string,
    failureReason: string,
    totalAmount: number,
    retryUrl?: string
  ): Promise<void> {
    try {
      console.log(`💳 [NotificationService] Payment failed notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '⚠️ Paiement Échoué',
        `Le paiement de votre commande #${orderId.substring(0, 8)} a échoué. Raison: ${failureReason}. Montant: ${totalAmount}€.`,
        {
          orderId,
          failureReason,
          totalAmount,
          retryUrl,
          type: 'PAYMENT_FAILED'
        },
        true // Force send (priorité critique)
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying payment failed:', error);
    }
  }

  /**
   * Notifier l'utilisateur que le statut de sa commande a changé
   */
  static async notifyOrderStatusChanged(
    userId: string,
    orderId: string,
    oldStatus: string,
    newStatus: string,
    totalAmount: number
  ): Promise<void> {
    try {
      console.log(`🔄 [NotificationService] Order status changed notification for user ${userId}`);
      
      const statusMessages: Record<string, string> = {
        'PENDING': '⏳ En attente',
        'COLLECTING': '🚚 En collecte',
        'COLLECTED': '✅ Collectée',
        'PROCESSING': '⚙️ En traitement',
        'READY': '📦 Prête',
        'DELIVERING': '🚗 En livraison',
        'DELIVERED': '✅ Livrée',
        'CANCELLED': '❌ Annulée'
      };

      const statusEmoji = statusMessages[newStatus] || newStatus;
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP'],
        `${statusEmoji} Statut Mis à Jour`,
        `Votre commande #${orderId.substring(0, 8)} est maintenant ${statusEmoji.toLowerCase()}. Montant: ${totalAmount}€.`,
        {
          orderId,
          oldStatus,
          newStatus,
          totalAmount,
          type: 'ORDER_STATUS_CHANGED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying order status changed:', error);
    }
  }

  /**
   * Notifier l'utilisateur que sa commande est prête pour la collecte
   */
  static async notifyOrderReadyPickup(
    userId: string,
    orderId: string,
    pickupDeadline: string,
    totalAmount: number
  ): Promise<void> {
    try {
      console.log(`📦 [NotificationService] Order ready for pickup notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'EMAIL'],
        '📦 Commande Prête',
        `Votre commande #${orderId.substring(0, 8)} est prête pour la collecte! Délai limite: ${pickupDeadline}. Montant: ${totalAmount}€.`,
        {
          orderId,
          pickupDeadline,
          totalAmount,
          type: 'ORDER_READY_PICKUP'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying order ready pickup:', error);
    }
  }

  /**
   * Notifier l'utilisateur que sa commande a été annulée
   */
  static async notifyOrderCancelled(
    userId: string,
    orderId: string,
    cancellationReason: string,
    refundAmount: number
  ): Promise<void> {
    try {
      console.log(`❌ [NotificationService] Order cancelled notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '❌ Commande Annulée',
        `Votre commande #${orderId.substring(0, 8)} a été annulée. Raison: ${cancellationReason}. Remboursement: ${refundAmount}€.`,
        {
          orderId,
          cancellationReason,
          refundAmount,
          type: 'ORDER_CANCELLED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying order cancelled:', error);
    }
  }

  /**
   * DELIVERY (3 événements)
   */

  /**
   * Notifier le livreur qu'une livraison lui a été assignée
   */
  static async notifyDeliveryAssigned(
    deliveryPersonId: string,
    orderId: string,
    deliveryPersonName: string,
    deliveryPersonPhone: string,
    clientName: string,
    address: string
  ): Promise<void> {
    try {
      console.log(`🚗 [NotificationService] Delivery assigned notification for delivery person ${deliveryPersonId}`);
      
      await NotificationChannels.sendWithPreferences(
        deliveryPersonId,
        ['PUSH'],
        '🚗 Nouvelle Livraison',
        `Nouvelle livraison assignée! Client: ${clientName}, Adresse: ${address}. Commande: #${orderId.substring(0, 8)}.`,
        {
          orderId,
          deliveryPersonName,
          deliveryPersonPhone,
          clientName,
          address,
          type: 'DELIVERY_ASSIGNED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying delivery assigned:', error);
    }
  }

  /**
   * Notifier le client et l'admin que la livraison a été complétée
   */
  static async notifyDeliveryCompleted(
    clientId: string,
    orderId: string,
    deliveryPersonName: string,
    totalAmount: number
  ): Promise<void> {
    try {
      console.log(`✅ [NotificationService] Delivery completed notification for client ${clientId}`);
      
      // Notifier le client
      await NotificationChannels.sendWithPreferences(
        clientId,
        ['PUSH', 'IN_APP'],
        '✅ Livraison Complétée',
        `Votre commande #${orderId.substring(0, 8)} a été livrée par ${deliveryPersonName}. Montant: ${totalAmount}€.`,
        {
          orderId,
          deliveryPersonName,
          totalAmount,
          type: 'DELIVERY_COMPLETED'
        }
      );

      // Notifier les admins
      await this.notifyAdmins('DELIVERY_COMPLETED', {
        orderId,
        clientId,
        deliveryPersonName,
        totalAmount
      });
    } catch (error) {
      console.error('[NotificationService] Error notifying delivery completed:', error);
    }
  }

  /**
   * Notifier l'admin qu'un problème de livraison s'est produit
   */
  static async notifyDeliveryProblem(
    orderId: string,
    problemType: 'CLIENT_ABSENT' | 'WRONG_ADDRESS' | 'DAMAGED_GOODS' | 'OTHER',
    problemDetails: string,
    deliveryPersonName: string
  ): Promise<void> {
    try {
      console.log(`⚠️ [NotificationService] Delivery problem notification`);
      
      const problemMessages: Record<string, string> = {
        'CLIENT_ABSENT': '❌ Client absent',
        'WRONG_ADDRESS': '📍 Mauvaise adresse',
        'DAMAGED_GOODS': '📦 Marchandise endommagée',
        'OTHER': '⚠️ Autre problème'
      };

      const problemMessage = problemMessages[problemType] || problemType;

      // Notifier les admins
      await this.notifyAdmins('DELIVERY_PROBLEM', {
        orderId,
        problemType,
        problemMessage,
        problemDetails,
        deliveryPersonName
      });
    } catch (error) {
      console.error('[NotificationService] Error notifying delivery problem:', error);
    }
  }

  /**
   * AFFILIATION (4 événements)
   */

  /**
   * Notifier l'affilié que son code de parrainage a été utilisé
   */
  static async notifyReferralCodeUsed(
    affiliateId: string,
    newClientName: string,
    orderId: string,
    orderAmount: number
  ): Promise<void> {
    try {
      console.log(`🎯 [NotificationService] Referral code used notification for affiliate ${affiliateId}`);
      
      await NotificationChannels.sendWithPreferences(
        affiliateId,
        ['PUSH', 'IN_APP'],
        '🎯 Code de Parrainage Utilisé',
        `Votre code de parrainage a été utilisé par ${newClientName}! Commande: #${orderId.substring(0, 8)}, Montant: ${orderAmount}€.`,
        {
          newClientName,
          orderId,
          orderAmount,
          type: 'REFERRAL_CODE_USED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying referral code used:', error);
    }
  }

  /**
   * Notifier l'affilié qu'il a gagné une commission
   */
  static async notifyCommissionEarned(
    affiliateId: string,
    orderId: string,
    commissionAmount: number,
    commissionRate: number,
    totalEarned: number
  ): Promise<void> {
    try {
      console.log(`💰 [NotificationService] Commission earned notification for affiliate ${affiliateId}`);
      
      await NotificationChannels.sendWithPreferences(
        affiliateId,
        ['PUSH', 'IN_APP'],
        '💰 Commission Gagnée',
        `Vous avez gagné une commission de ${commissionAmount}€ (${commissionRate}%) sur la commande #${orderId.substring(0, 8)}. Total gagné: ${totalEarned}€.`,
        {
          orderId,
          commissionAmount,
          commissionRate,
          totalEarned,
          type: 'COMMISSION_EARNED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying commission earned:', error);
    }
  }

  /**
   * Notifier l'affilié que son retrait a été approuvé
   */
  static async notifyWithdrawalApproved(
    affiliateId: string,
    withdrawalAmount: number,
    withdrawalId: string,
    estimatedPaymentDate: string
  ): Promise<void> {
    try {
      console.log(`✅ [NotificationService] Withdrawal approved notification for affiliate ${affiliateId}`);
      
      await NotificationChannels.sendWithPreferences(
        affiliateId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '✅ Retrait Approuvé',
        `Votre retrait de ${withdrawalAmount}€ a été approuvé! Date de paiement estimée: ${estimatedPaymentDate}.`,
        {
          withdrawalAmount,
          withdrawalId,
          estimatedPaymentDate,
          type: 'WITHDRAWAL_APPROVED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying withdrawal approved:', error);
    }
  }

  /**
   * Notifier l'affilié que son retrait a été rejeté
   */
  static async notifyWithdrawalRejected(
    affiliateId: string,
    withdrawalAmount: number,
    rejectionReason: string,
    withdrawalId: string
  ): Promise<void> {
    try {
      console.log(`❌ [NotificationService] Withdrawal rejected notification for affiliate ${affiliateId}`);
      
      await NotificationChannels.sendWithPreferences(
        affiliateId,
        ['PUSH', 'IN_APP'],
        '❌ Retrait Rejeté',
        `Votre retrait de ${withdrawalAmount}€ a été rejeté. Raison: ${rejectionReason}.`,
        {
          withdrawalAmount,
          rejectionReason,
          withdrawalId,
          type: 'WITHDRAWAL_REJECTED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying withdrawal rejected:', error);
    }
  }

  /**
   * SUBSCRIPTION (2 événements)
   */

  /**
   * Notifier l'utilisateur que son abonnement a été activé
   */
  static async notifySubscriptionActivated(
    userId: string,
    planName: string,
    planId: string,
    startDate: string,
    endDate: string,
    price: number
  ): Promise<void> {
    try {
      console.log(`�� [NotificationService] Subscription activated notification for user ${userId}`);
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '📅 Abonnement Activé',
        `Votre abonnement "${planName}" a été activé! Valide du ${startDate} au ${endDate}. Prix: ${price}€.`,
        {
          planName,
          planId,
          startDate,
          endDate,
          price,
          type: 'SUBSCRIPTION_ACTIVATED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying subscription activated:', error);
    }
  }

  /**
   * Notifier l'utilisateur que son abonnement a été annulé
   */
  static async notifySubscriptionCancelled(
    userId: string,
    planName: string,
    planId: string,
    endDate: string,
    refundAmount?: number
  ): Promise<void> {
    try {
      console.log(`❌ [NotificationService] Subscription cancelled notification for user ${userId}`);
      
      const refundMessage = refundAmount ? ` Remboursement: ${refundAmount}€.` : '';
      
      await NotificationChannels.sendWithPreferences(
        userId,
        ['PUSH', 'IN_APP', 'EMAIL'],
        '❌ Abonnement Annulé',
        `Votre abonnement "${planName}" a été annulé. Date de fin: ${endDate}.${refundMessage}`,
        {
          planName,
          planId,
          endDate,
          refundAmount,
          type: 'SUBSCRIPTION_CANCELLED'
        }
      );
    } catch (error) {
      console.error('[NotificationService] Error notifying subscription cancelled:', error);
    }
  }

  /**
   * ADMIN (3 événements)
   */

  /**
   * Notifier les admins qu'un nouvel utilisateur client s'est inscrit
   */
  static async notifyAdminNewUserRegistered(
    userId: string,
    userName: string,
    userEmail: string,
    userPhone: string,
    userRole: string
  ): Promise<void> {
    try {
      console.log(`👤 [NotificationService] New user registration notification for admins`);
      
      await this.notifyAdmins('NEW_USER_REGISTERED', {
        userId,
        userName,
        userEmail,
        userPhone,
        userRole,
        registeredAt: new Date().toISOString(),
        type: 'NEW_USER_REGISTERED'
      });
    } catch (error) {
      console.error('[NotificationService] Error notifying admin new user registered:', error);
    }
  }

  /**
   * Notifier les admins qu'une nouvelle commande a été créée
   */
  static async notifyAdminNewOrder(
    orderId: string,
    clientName: string,
    totalAmount: number,
    itemCount: number,
    createdAt: string
  ): Promise<void> {
    try {
      console.log(`🔔 [NotificationService] New order alert notification for admins`);
      
      await this.notifyAdmins('NEW_ORDER_ALERT', {
        orderId,
        clientName,
        totalAmount,
        itemCount,
        createdAt,
        type: 'NEW_ORDER_ALERT'
      });
    } catch (error) {
      console.error('[NotificationService] Error notifying admin new order:', error);
    }
  }

  /**
   * Notifier les admins qu'il y a un problème avec le système de paiement
   */
  static async notifyAdminPaymentSystemIssue(
    failureCount: number,
    failureRate: string,
    affectedOrders: number,
    lastFailureTime: string
  ): Promise<void> {
    try {
      console.log(`🚨 [NotificationService] Payment system issue notification for admins`);
      
      await this.notifyAdmins('PAYMENT_SYSTEM_ISSUE', {
        failureCount,
        failureRate,
        affectedOrders,
        lastFailureTime,
        type: 'PAYMENT_SYSTEM_ISSUE'
      });
    } catch (error) {
      console.error('[NotificationService] Error notifying admin payment system issue:', error);
    }
  }

  /**
   * Méthode privée pour notifier les admins
   */
  private static async notifyAdmins(
    eventType: string,
    data: Record<string, any>
  ): Promise<void> {
    try {
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        },
        select: { id: true }
      });

      if (admins.length === 0) {
        console.warn(`⚠️ No admins found to notify for event: ${eventType}`);
        return;
      }

      console.log(`📢 Notifying ${admins.length} admin(s) for event: ${eventType}`);

      const promises = admins.map(admin =>
        NotificationChannels.sendWithPreferences(
          admin.id,
          ['PUSH', 'IN_APP'],
          `🔔 ${eventType}`,
          `Événement système: ${eventType}`,
          data
        )
      );

      await Promise.allSettled(promises);
    } catch (error) {
      console.error('[NotificationService] Error notifying admins:', error);
    }
  }
}
