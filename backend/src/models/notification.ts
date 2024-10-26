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

export interface Notification {
  id: string;
  type: NotificationType;
  recipientId: string;
  recipientRole: 'customer' | 'affiliate' | 'admin';
  title: string;
  message: string;
  data?: Record<string, any>;
  isRead: boolean;
  createdAt: Date;
  expiresAt?: Date;
}
