export const errorCodes = {
  // General errors
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
  
  // Article-related errors
  ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
  INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
  INVALID_PRICE_RANGE: 'INVALID_PRICE_RANGE',
  
  // User-related errors
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  USER_ALREADY_EXISTS: 'USER_ALREADY_EXISTS',
  INVALID_USER_DATA: 'INVALID_USER_DATA',
  INVALID_USER_PROFILE: 'INVALID_USER_PROFILE',
  DUPLICATE_EMAIL: 'DUPLICATE_EMAIL',

  // Order-related errors
  ORDER_NOT_FOUND: 'ORDER_NOT_FOUND',
  ORDER_CREATION_FAILED: 'ORDER_CREATION_FAILED',
  ORDER_UPDATE_FAILED: 'ORDER_UPDATE_FAILED',
  ORDER_STATUS_UPDATE_FAILED: 'ORDER_STATUS_UPDATE_FAILED',
  INVALID_ORDER_STATUS: 'INVALID_ORDER_STATUS',
  INVALID_ORDER_DATA: 'INVALID_ORDER_DATA',
  ORDERS_FETCH_FAILED: 'ORDERS_FETCH_FAILED',
  ONE_CLICK_ORDER_FAILED: 'ONE_CLICK_ORDER_FAILED',
  SLOT_NOT_AVAILABLE: 'SLOT_NOT_AVAILABLE',
  ROUTE_GENERATION_FAILED: 'ROUTE_GENERATION_FAILED',
  STATS_FETCH_FAILED: 'STATS_FETCH_FAILED',
  INVALID_SERVICE: 'INVALID_SERVICE',
  
  // Billing-related errors
  BILL_NOT_FOUND: 'BILL_NOT_FOUND',
  BILL_CREATION_FAILED: 'BILL_CREATION_FAILED',
  BILL_UPDATE_FAILED: 'BILL_UPDATE_FAILED',
  BILL_ALREADY_PAID: 'BILL_ALREADY_PAID',
  INSUFFICIENT_PAYMENT: 'INSUFFICIENT_PAYMENT',
  PAYMENT_PROCESSING_FAILED: 'PAYMENT_PROCESSING_FAILED',
  INVALID_REFUND_REQUEST: 'INVALID_REFUND_REQUEST',
  INVALID_REFUND_AMOUNT: 'INVALID_REFUND_AMOUNT',
  REFUND_PROCESSING_FAILED: 'REFUND_PROCESSING_FAILED',
  BILLING_STATS_FETCH_FAILED: 'BILLING_STATS_FETCH_FAILED',
  
  // Loyalty points-related errors
  LOYALTY_POINTS_UPDATE_FAILED: 'LOYALTY_POINTS_UPDATE_FAILED',
  INSUFFICIENT_POINTS: 'INSUFFICIENT_POINTS',
  REWARD_NOT_FOUND: 'REWARD_NOT_FOUND',
  
  // Subscription-related errors
  SUBSCRIPTION_NOT_FOUND: 'SUBSCRIPTION_NOT_FOUND',
  SUBSCRIPTION_PLAN_NOT_FOUND: 'SUBSCRIPTION_PLAN_NOT_FOUND',
  SUBSCRIPTION_UPDATE_FAILED: 'SUBSCRIPTION_UPDATE_FAILED',
  SUBSCRIPTION_FETCH_FAILED: 'SUBSCRIPTION_FETCH_FAILED',
  SUBSCRIPTION_CANCELLATION_FAILED: 'SUBSCRIPTION_CANCELLATION_FAILED',
  SUBSCRIPTION_RENEWAL_FAILED: 'SUBSCRIPTION_RENEWAL_FAILED',
  SUBSCRIPTION_PAYMENT_FAILED: 'SUBSCRIPTION_PAYMENT_FAILED',
  
  // Zone-related errors
  ZONE_NOT_FOUND: 'ZONE_NOT_FOUND',
  ZONE_CREATION_FAILED: 'ZONE_CREATION_FAILED',
  ZONE_UPDATE_FAILED: 'ZONE_UPDATE_FAILED',
  ZONE_DELETION_FAILED: 'ZONE_DELETION_FAILED',
  ZONE_STATS_FETCH_FAILED: 'ZONE_STATS_FETCH_FAILED',
  ZONE_FETCH_FAILED: 'ZONE_FETCH_FAILED',
  ZONES_FETCH_FAILED: 'ZONES_FETCH_FAILED',
  ZONE_HAS_ACTIVE_ORDERS: 'ZONE_HAS_ACTIVE_ORDERS',
  ZONE_ASSIGNMENT_FAILED: 'ZONE_ASSIGNMENT_FAILED',
  ZONE_ORDERS_FETCH_FAILED: 'ZONE_ORDERS_FETCH_FAILED',
  
  // Delivery person-related errors
  DELIVERY_PERSON_NOT_FOUND: 'DELIVERY_PERSON_NOT_FOUND',
  DELIVERY_PERSON_UNAVAILABLE: 'DELIVERY_PERSON_UNAVAILABLE',
  DELIVERY_PERSON_ASSIGNMENT_FAILED: 'DELIVERY_PERSON_ASSIGNMENT_FAILED',
  
  // Address-related errors
  ADDRESS_NOT_FOUND: 'ADDRESS_NOT_FOUND',
  INVALID_ADDRESS_DATA: 'INVALID_ADDRESS_DATA',
  GEOCODING_FAILED: 'GEOCODING_FAILED',

  // Rate limiting-related errors
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',

  // Affiliate-related errors
  AFFILIATE_NOT_FOUND: 'AFFILIATE_NOT_FOUND',
  AFFILIATE_CREATE_ERROR: 'AFFILIATE_CREATE_ERROR',
  AFFILIATE_UPDATE_ERROR: 'AFFILIATE_UPDATE_ERROR',
  AFFILIATE_FETCH_ERROR: 'AFFILIATE_FETCH_ERROR',
  INVALID_STATUS: 'INVALID_STATUS',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  INVALID_AMOUNT: 'INVALID_AMOUNT',
  WITHDRAWAL_CREATE_ERROR: 'WITHDRAWAL_CREATE_ERROR',
  WITHDRAWAL_NOT_FOUND: 'WITHDRAWAL_NOT_FOUND',
  WITHDRAWAL_PROCESS_ERROR: 'WITHDRAWAL_PROCESS_ERROR',
  ANALYTICS_FETCH_ERROR: 'ANALYTICS_FETCH_ERROR',

  // Referral-related errors
  REFERRAL_ALREADY_EXISTS: 'REFERRAL_ALREADY_EXISTS',
  INVALID_REFERRAL_CODE: 'INVALID_REFERRAL_CODE',
  REFERRAL_NOT_FOUND: 'REFERRAL_NOT_FOUND',
  REWARD_ALREADY_PROCESSED: 'REWARD_ALREADY_PROCESSED',
  NO_ACTIVE_PROGRAM: 'NO_ACTIVE_PROGRAM',

  // Permission-related errors
  INVALID_ROLE: 'INVALID_ROLE',
  INVALID_RESOURCE: 'INVALID_RESOURCE',
  INVALID_ACTION: 'INVALID_ACTION',
  PERMISSION_NOT_FOUND: 'PERMISSION_NOT_FOUND',

  // Admin-related errors
  INVALID_EMAIL: 'INVALID_EMAIL',
  INVALID_PASSWORD: 'INVALID_PASSWORD',
  INVALID_PHONE_NUMBER: 'INVALID_PHONE_NUMBER',
  MASTER_ADMIN_EXISTS: 'MASTER_ADMIN_EXISTS',
  ADMIN_NOT_FOUND: 'ADMIN_NOT_FOUND',
  MASTER_ADMIN_MODIFICATION: 'MASTER_ADMIN_MODIFICATION',
  MASTER_ADMIN_DELETION: 'MASTER_ADMIN_DELETION',

  // Security-related errors
  INVALID_JSON: 'INVALID_JSON',
  FORBIDDEN_ORIGIN: 'FORBIDDEN_ORIGIN',
  METHOD_NOT_ALLOWED: 'METHOD_NOT_ALLOWED',

  // Commission-related errors
  COMMISSION_NOT_FOUND: 'COMMISSION_NOT_FOUND',
  INVALID_COMMISSION_STATUS: 'INVALID_COMMISSION_STATUS',
  COMMISSION_RULE_NOT_FOUND: 'COMMISSION_RULE_NOT_FOUND',

  // Notification-related errors
  NOTIFICATION_CREATE_ERROR: 'NOTIFICATION_CREATE_ERROR',
  NOTIFICATION_FETCH_ERROR: 'NOTIFICATION_FETCH_ERROR',
  NOTIFICATION_NOT_FOUND: 'NOTIFICATION_NOT_FOUND',
  NOTIFICATION_UPDATE_ERROR: 'NOTIFICATION_UPDATE_ERROR',
  PUSH_NOTIFICATION_ERROR: 'PUSH_NOTIFICATION_ERROR',
  NOTIFICATION_DELETE_ERROR: 'NOTIFICATION_DELETE_ERROR',
  NOTIFICATION_SEND_ERROR: 'NOTIFICATION_SEND_ERROR',

  // Auth-related errors
  INVALID_INPUT: 'INVALID_INPUT',
  PASSWORD_HASH_ERROR: 'PASSWORD_HASH_ERROR',
  PASSWORD_COMPARE_ERROR: 'PASSWORD_COMPARE_ERROR',

  // Team-related errors
  TEAM_NOT_FOUND: 'TEAM_NOT_FOUND',
  ADMIN_ALREADY_IN_TEAM: 'ADMIN_ALREADY_IN_TEAM',
  ADMIN_NOT_IN_TEAM: 'ADMIN_NOT_IN_TEAM',

  // Internal Server Error
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR'
} as const;

export class AppError extends Error {
  public errorCode: keyof typeof errorCodes; // Add errorCode property

  constructor(
    public statusCode: number,
    message: string,
    code: keyof typeof errorCodes
  ) {
    super(message);
    this.name = 'AppError';
    this.errorCode = code; // Assign errorCode
  }
}
