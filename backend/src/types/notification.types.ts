/**
 * 🔔 Notification Types - Types spécifiques pour les 18 événements de notification
 * 
 * Ce fichier définit tous les types et interfaces nécessaires pour le système
 * de notifications avec les 18 événements essentiels.
 */

/**
 * Les 18 types de notifications essentiels
 */
export type NotificationType =
  // LOYALTY (2)
  | 'REWARD_CLAIM_APPROVED'
  | 'REWARD_CLAIM_REJECTED'
  // ORDERS (5)
  | 'ORDER_PLACED'
  | 'PAYMENT_FAILED'
  | 'ORDER_STATUS_CHANGED'
  | 'ORDER_READY_PICKUP'
  | 'ORDER_CANCELLED'
  // DELIVERY (3)
  | 'DELIVERY_ASSIGNED'
  | 'DELIVERY_COMPLETED'
  | 'DELIVERY_PROBLEM'
  // AFFILIATION (4)
  | 'REFERRAL_CODE_USED'
  | 'COMMISSION_EARNED'
  | 'WITHDRAWAL_APPROVED'
  | 'WITHDRAWAL_REJECTED'
  // SUBSCRIPTION (2)
  | 'SUBSCRIPTION_ACTIVATED'
  | 'SUBSCRIPTION_CANCELLED'
  // ADMIN (2)
  | 'NEW_ORDER_ALERT'
  | 'PAYMENT_SYSTEM_ISSUE';

/**
 * Canaux de notification disponibles
 */
export type NotificationChannel = 'PUSH' | 'EMAIL' | 'IN_APP';

/**
 * Niveaux de priorité des notifications
 */
export type NotificationPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

/**
 * Payload générique pour envoyer une notification
 */
export interface NotificationPayload {
  userId?: string;
  role?: string;
  type: NotificationType;
  title: string;
  message: string;
  data: Record<string, any>;
  channels: NotificationChannel[];
  priority: NotificationPriority;
}

/**
 * Préférences de notification utilisateur
 * Alignées avec les champs existants en BD (schema.prisma)
 */
export interface NotificationPreferences {
  id: string;
  userId: string;
  email: boolean;           // Notifications par email
  push: boolean;            // Notifications push
  sms: boolean;             // Notifications SMS
  order_updates: boolean;   // Mises à jour de commandes
  promotions: boolean;      // Promotions
  payments: boolean;        // Paiements
  loyalty: boolean;         // Loyauté/Récompenses
  created_at?: Date;
  updated_at?: Date;
}

/**
 * Paramètres pour créer une notification pour un utilisateur spécifique
 */
export interface CreateNotificationParams {
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  data?: Record<string, any>;
  channels: NotificationChannel[];
  priority: NotificationPriority;
}

/**
 * Paramètres pour créer une notification pour un rôle spécifique
 */
export interface CreateNotificationForRoleParams {
  role: string;
  type: NotificationType;
  title: string;
  message: string;
  data?: Record<string, any>;
  channels: NotificationChannel[];
  priority: NotificationPriority;
}

/**
 * Réponse lors de l'envoi d'une notification
 */
export interface NotificationResponse {
  success: boolean;
  message: string;
  notificationId?: string;
  error?: string;
}

/**
 * Données spécifiques pour chaque type de notification
 */

// LOYALTY
export interface RewardApprovedData {
  rewardId: string;
  rewardName: string;
  pointsValue: number;
  claimId: string;
}

export interface RewardRejectedData {
  rewardId: string;
  rewardName: string;
  rejectionReason: string;
  pointsRefunded: number;
  claimId: string;
}

// ORDERS
export interface OrderPlacedData {
  orderId: string;
  totalAmount: number;
  itemCount: number;
  clientName?: string;
}

export interface PaymentFailedData {
  orderId: string;
  failureReason: string;
  totalAmount: number;
  retryUrl?: string;
}

export interface OrderStatusChangedData {
  orderId: string;
  oldStatus: string;
  newStatus: string;
  totalAmount: number;
}

export interface OrderReadyPickupData {
  orderId: string;
  pickupDeadline: string;
  totalAmount: number;
}

export interface OrderCancelledData {
  orderId: string;
  cancellationReason: string;
  refundAmount: number;
}

// DELIVERY
export interface DeliveryAssignedData {
  orderId: string;
  deliveryPersonName: string;
  deliveryPersonPhone: string;
  clientName: string;
  address: string;
}

export interface DeliveryCompletedData {
  orderId: string;
  deliveryPersonName: string;
  totalAmount: number;
}

export interface DeliveryProblemData {
  orderId: string;
  problemType: 'CLIENT_ABSENT' | 'WRONG_ADDRESS' | 'DAMAGED_GOODS' | 'OTHER';
  problemDetails: string;
  deliveryPersonName: string;
}

// AFFILIATION
export interface ReferralCodeUsedData {
  affiliateCode: string;
  newClientName: string;
  orderId: string;
  orderAmount: number;
}

export interface CommissionEarnedData {
  orderId: string;
  commissionAmount: number;
  commissionRate: number;
  totalEarned: number;
}

export interface WithdrawalApprovedData {
  withdrawalAmount: number;
  withdrawalId: string;
  estimatedPaymentDate: string;
}

export interface WithdrawalRejectedData {
  withdrawalAmount: number;
  rejectionReason: string;
  withdrawalId: string;
}

// SUBSCRIPTION
export interface SubscriptionActivatedData {
  planName: string;
  planId: string;
  startDate: string;
  endDate: string;
  price: number;
}

export interface SubscriptionCancelledData {
  planName: string;
  planId: string;
  endDate: string;
  refundAmount?: number;
}

// ADMIN
export interface NewOrderAlertData {
  orderId: string;
  clientName: string;
  totalAmount: number;
  itemCount: number;
  createdAt: string;
}

export interface PaymentSystemIssueData {
  failureCount: number;
  failureRate: string;
  affectedOrders: number;
  lastFailureTime: string;
}

/**
 * Énumération des types de notifications pour validation
 */
export const NOTIFICATION_TYPES: Record<NotificationType, NotificationType> = {
  // LOYALTY
  REWARD_CLAIM_APPROVED: 'REWARD_CLAIM_APPROVED',
  REWARD_CLAIM_REJECTED: 'REWARD_CLAIM_REJECTED',
  // ORDERS
  ORDER_PLACED: 'ORDER_PLACED',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  ORDER_STATUS_CHANGED: 'ORDER_STATUS_CHANGED',
  ORDER_READY_PICKUP: 'ORDER_READY_PICKUP',
  ORDER_CANCELLED: 'ORDER_CANCELLED',
  // DELIVERY
  DELIVERY_ASSIGNED: 'DELIVERY_ASSIGNED',
  DELIVERY_COMPLETED: 'DELIVERY_COMPLETED',
  DELIVERY_PROBLEM: 'DELIVERY_PROBLEM',
  // AFFILIATION
  REFERRAL_CODE_USED: 'REFERRAL_CODE_USED',
  COMMISSION_EARNED: 'COMMISSION_EARNED',
  WITHDRAWAL_APPROVED: 'WITHDRAWAL_APPROVED',
  WITHDRAWAL_REJECTED: 'WITHDRAWAL_REJECTED',
  // SUBSCRIPTION
  SUBSCRIPTION_ACTIVATED: 'SUBSCRIPTION_ACTIVATED',
  SUBSCRIPTION_CANCELLED: 'SUBSCRIPTION_CANCELLED',
  // ADMIN
  NEW_ORDER_ALERT: 'NEW_ORDER_ALERT',
  PAYMENT_SYSTEM_ISSUE: 'PAYMENT_SYSTEM_ISSUE',
};

/**
 * Mapping des types de notifications par catégorie
 */
export const NOTIFICATION_CATEGORIES = {
  LOYALTY: ['REWARD_CLAIM_APPROVED', 'REWARD_CLAIM_REJECTED'],
  ORDERS: ['ORDER_PLACED', 'PAYMENT_FAILED', 'ORDER_STATUS_CHANGED', 'ORDER_READY_PICKUP', 'ORDER_CANCELLED'],
  DELIVERY: ['DELIVERY_ASSIGNED', 'DELIVERY_COMPLETED', 'DELIVERY_PROBLEM'],
  AFFILIATION: ['REFERRAL_CODE_USED', 'COMMISSION_EARNED', 'WITHDRAWAL_APPROVED', 'WITHDRAWAL_REJECTED'],
  SUBSCRIPTION: ['SUBSCRIPTION_ACTIVATED', 'SUBSCRIPTION_CANCELLED'],
  ADMIN: ['NEW_ORDER_ALERT', 'PAYMENT_SYSTEM_ISSUE'],
} as const;

/**
 * Mapping des canaux par type de notification
 */
export const NOTIFICATION_CHANNELS_MAP: Record<NotificationType, NotificationChannel[]> = {
  // LOYALTY
  REWARD_CLAIM_APPROVED: ['PUSH', 'IN_APP'],
  REWARD_CLAIM_REJECTED: ['PUSH', 'IN_APP', 'EMAIL'],
  // ORDERS
  ORDER_PLACED: ['PUSH', 'IN_APP', 'EMAIL'],
  PAYMENT_FAILED: ['PUSH', 'IN_APP', 'EMAIL'],
  ORDER_STATUS_CHANGED: ['PUSH', 'IN_APP'],
  ORDER_READY_PICKUP: ['PUSH', 'EMAIL'],
  ORDER_CANCELLED: ['PUSH', 'IN_APP', 'EMAIL'],
  // DELIVERY
  DELIVERY_ASSIGNED: ['PUSH'],
  DELIVERY_COMPLETED: ['PUSH', 'IN_APP'],
  DELIVERY_PROBLEM: ['PUSH', 'IN_APP'],
  // AFFILIATION
  REFERRAL_CODE_USED: ['PUSH', 'IN_APP'],
  COMMISSION_EARNED: ['PUSH', 'IN_APP'],
  WITHDRAWAL_APPROVED: ['PUSH', 'IN_APP', 'EMAIL'],
  WITHDRAWAL_REJECTED: ['PUSH', 'IN_APP'],
  // SUBSCRIPTION
  SUBSCRIPTION_ACTIVATED: ['PUSH', 'IN_APP', 'EMAIL'],
  SUBSCRIPTION_CANCELLED: ['PUSH', 'IN_APP', 'EMAIL'],
  // ADMIN
  NEW_ORDER_ALERT: ['PUSH', 'IN_APP'],
  PAYMENT_SYSTEM_ISSUE: ['PUSH', 'IN_APP', 'EMAIL'],
};

/**
 * Mapping des priorités par type de notification
 */
export const NOTIFICATION_PRIORITY_MAP: Record<NotificationType, NotificationPriority> = {
  // LOYALTY
  REWARD_CLAIM_APPROVED: 'HIGH',
  REWARD_CLAIM_REJECTED: 'HIGH',
  // ORDERS
  ORDER_PLACED: 'HIGH',
  PAYMENT_FAILED: 'CRITICAL',
  ORDER_STATUS_CHANGED: 'HIGH',
  ORDER_READY_PICKUP: 'HIGH',
  ORDER_CANCELLED: 'HIGH',
  // DELIVERY
  DELIVERY_ASSIGNED: 'HIGH',
  DELIVERY_COMPLETED: 'HIGH',
  DELIVERY_PROBLEM: 'CRITICAL',
  // AFFILIATION
  REFERRAL_CODE_USED: 'HIGH',
  COMMISSION_EARNED: 'HIGH',
  WITHDRAWAL_APPROVED: 'HIGH',
  WITHDRAWAL_REJECTED: 'HIGH',
  // SUBSCRIPTION
  SUBSCRIPTION_ACTIVATED: 'HIGH',
  SUBSCRIPTION_CANCELLED: 'HIGH',
  // ADMIN
  NEW_ORDER_ALERT: 'HIGH',
  PAYMENT_SYSTEM_ISSUE: 'CRITICAL',
};
