import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export enum NotificationType {
  // Order related
  NEW_ORDER = 'new_order',
  ORDER_STATUS_UPDATE = 'order_status_update',
  ORDER_COMPLETED = 'order_completed',
  
  // Affiliate related
  NEW_REFERRAL = 'new_referral',
  COMMISSION_EARNED = 'commission_earned',
  SUB_AFFILIATE_ACTIVITY = 'sub_affiliate_activity',
  AFFILIATE_PERFORMANCE = 'affiliate_performance',
  WITHDRAWAL_REQUEST = 'withdrawal_request',
  WITHDRAWAL_PROCESSED = 'withdrawal_processed',
  
  // Customer related
  LOYALTY_POINTS_REMINDER = 'loyalty_points_reminder',
  SAVINGS_ALERT = 'savings_alert',
  PROMOTION_AVAILABLE = 'promotion_available',
  
  // Admin broadcasts
  SERVICE_UPDATE = 'service_update',
  GENERAL_ANNOUNCEMENT = 'general_announcement'
}

export enum NotificationPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high'
}

export enum NotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed'
}

export enum DeliveryChannel {
  EMAIL = 'email',
  SMS = 'sms',
  IN_APP = 'in_app'
}

export interface Notification {
  id: string;
  type: NotificationType;
  recipientId: string;
  recipientRole: 'customer' | 'affiliate' | 'admin';
  title: string;
  message: string;
  data?: Record<string, any>;
  priority: NotificationPriority;
  status: NotificationStatus;
  deliveryChannel: DeliveryChannel;
  isRead: boolean;
  createdAt: string;
  expiresAt?: string;
}

// Use Supabase to store notification data
const notificationsTable = 'notifications';

// Function to get notification data
export async function getNotification(id: string): Promise<Notification | null> {
  const { data, error } = await supabase.from(notificationsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as Notification;
}

// Function to create notification
export async function createNotification(notificationData: Notification): Promise<Notification> {
  const { data, error } = await supabase.from(notificationsTable).insert([notificationData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as Notification;
}

// Function to update notification
export async function updateNotification(id: string, notificationData: Partial<Notification>): Promise<Notification> {
  const currentNotification = await getNotification(id);

  if (!currentNotification) {
    throw new AppError(404, 'Notification not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(notificationsTable).update(notificationData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as Notification;
}

// Function to delete notification
export async function deleteNotification(id: string): Promise<void> {
  const notification = await getNotification(id);

  if (!notification) {
    throw new AppError(404, 'Notification not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(notificationsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete notification', 'INTERNAL_SERVER_ERROR');
  }
}
