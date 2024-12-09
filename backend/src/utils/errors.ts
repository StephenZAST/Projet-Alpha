export class AppError extends Error {
  statusCode: number;
  errorCode: string;

  constructor(statusCode: number, message: string, errorCode: string) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
  }
}

export const errorCodes = {
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  USER_ALREADY_EXISTS: 'USER_ALREADY_EXISTS',
  INVALID_TOKEN: 'INVALID_TOKEN',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  EMAIL_NOT_VERIFIED: 'EMAIL_NOT_VERIFIED',
  PASSWORD_RESET_FAILED: 'PASSWORD_RESET_FAILED',
  INVALID_PASSWORD_RESET_TOKEN: 'INVALID_PASSWORD_RESET_TOKEN',
  INVALID_EMAIL: 'INVALID_EMAIL',
  INVALID_PASSWORD: 'INVALID_PASSWORD',
  INVALID_ROLE: 'INVALID_ROLE',
  INVALID_PHONE_NUMBER: 'INVALID_PHONE_NUMBER',
  INVALID_STATUS: 'INVALID_STATUS',
  INVALID_ADMIN_DATA: 'INVALID_ADMIN_DATA',
  ADMIN_NOT_FOUND: 'ADMIN_NOT_FOUND',
  ADMIN_CREATION_FAILED: 'ADMIN_CREATION_FAILED',
  ADMIN_UPDATE_FAILED: 'ADMIN_UPDATE_FAILED',
  ADMIN_DELETION_FAILED: 'ADMIN_DELETION_FAILED',
  MASTER_ADMIN_EXISTS: 'MASTER_ADMIN_EXISTS',
  MASTER_ADMIN_MODIFICATION: 'MASTER_ADMIN_MODIFICATION',
  MASTER_ADMIN_DELETION: 'MASTER_ADMIN_DELETION',
  INVALID_PERMISSION_DATA: 'INVALID_PERMISSION_DATA',
  PERMISSION_NOT_FOUND: 'PERMISSION_NOT_FOUND',
  PERMISSION_CREATION_FAILED: 'PERMISSION_CREATION_FAILED',
  PERMISSION_UPDATE_FAILED: 'PERMISSION_UPDATE_FAILED',
  PERMISSION_DELETION_FAILED: 'PERMISSION_DELETION_FAILED',
  INVALID_AFFILIATE_DATA: 'INVALID_AFFILIATE_DATA',
  AFFILIATE_NOT_FOUND: 'AFFILIATE_NOT_FOUND',
  AFFILIATE_CREATION_FAILED: 'AFFILIATE_CREATION_FAILED',
  AFFILIATE_UPDATE_FAILED: 'AFFILIATE_UPDATE_FAILED',
  AFFILIATE_DELETION_FAILED: 'AFFILIATE_DELETION_FAILED',
  EMAIL_ALREADY_REGISTERED: 'EMAIL_ALREADY_REGISTERED',
  AFFILIATE_ALREADY_ACTIVE: 'AFFILIATE_ALREADY_ACTIVE',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  MINIMUM_WITHDRAWAL_AMOUNT: 'MINIMUM_WITHDRAWAL_AMOUNT',
  WITHDRAWAL_REQUEST_NOT_FOUND: 'WITHDRAWAL_REQUEST_NOT_FOUND',
  INVALID_CATEGORY_DATA: 'INVALID_CATEGORY_DATA',
  CATEGORY_NOT_FOUND: 'CATEGORY_NOT_FOUND',
  CATEGORY_CREATION_FAILED: 'CATEGORY_CREATION_FAILED',
  CATEGORY_UPDATE_FAILED: 'CATEGORY_UPDATE_FAILED',
  CATEGORY_DELETION_FAILED: 'CATEGORY_DELETION_FAILED',
  INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
  ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
  ARTICLE_CREATION_FAILED: 'ARTICLE_CREATION_FAILED',
  ARTICLE_UPDATE_FAILED: 'ARTICLE_UPDATE_FAILED',
  ARTICLE_DELETION_FAILED: 'ARTICLE_DELETION_FAILED',
  INVALID_ORDER_DATA: 'INVALID_ORDER_DATA',
  ORDER_NOT_FOUND: 'ORDER_NOT_FOUND',
  ORDER_CREATION_FAILED: 'ORDER_CREATION_FAILED',
  ORDER_UPDATE_FAILED: 'ORDER_UPDATE_FAILED',
  ORDER_DELETION_FAILED: 'ORDER_DELETION_FAILED',
  INVALID_DELIVERY_TASK_DATA: 'INVALID_DELIVERY_TASK_DATA',
  DELIVERY_TASK_NOT_FOUND: 'DELIVERY_TASK_NOT_FOUND',
  DELIVERY_TASK_CREATION_FAILED: 'DELIVERY_TASK_CREATION_FAILED',
  DELIVERY_TASK_UPDATE_FAILED: 'DELIVERY_TASK_UPDATE_FAILED',
  DELIVERY_TASK_DELETION_FAILED: 'DELIVERY_TASK_DELETION_FAILED',
  INVALID_DELIVERY_DATA: 'INVALID_DELIVERY_DATA',
  DELIVERY_NOT_FOUND: 'DELIVERY_NOT_FOUND',
  DELIVERY_CREATION_FAILED: 'DELIVERY_CREATION_FAILED',
  DELIVERY_UPDATE_FAILED: 'DELIVERY_UPDATE_FAILED',
  DELIVERY_DELETION_FAILED: 'DELIVERY_DELETION_FAILED',
  INVALID_PAYMENT_DATA: 'INVALID_PAYMENT_DATA',
  PAYMENT_NOT_FOUND: 'PAYMENT_NOT_FOUND',
  PAYMENT_CREATION_FAILED: 'PAYMENT_CREATION_FAILED',
  PAYMENT_UPDATE_FAILED: 'PAYMENT_UPDATE_FAILED',
  PAYMENT_DELETION_FAILED: 'PAYMENT_DELETION_FAILED',
  INVALID_SUBSCRIPTION_DATA: 'INVALID_SUBSCRIPTION_DATA',
  SUBSCRIPTION_NOT_FOUND: 'SUBSCRIPTION_NOT_FOUND',
  SUBSCRIPTION_CREATION_FAILED: 'SUBSCRIPTION_CREATION_FAILED',
  SUBSCRIPTION_UPDATE_FAILED: 'SUBSCRIPTION_UPDATE_FAILED',
  SUBSCRIPTION_DELETION_FAILED: 'SUBSCRIPTION_DELETION_FAILED',
  INVALID_TEAM_DATA: 'INVALID_TEAM_DATA',
  TEAM_NOT_FOUND: 'TEAM_NOT_FOUND',
  TEAM_CREATION_FAILED: 'TEAM_CREATION_FAILED',
  TEAM_UPDATE_FAILED: 'TEAM_UPDATE_FAILED',
  TEAM_DELETION_FAILED: 'TEAM_DELETION_FAILED',
  INVALID_ZONE_DATA: 'INVALID_ZONE_DATA',
  ZONE_NOT_FOUND: 'ZONE_NOT_FOUND',
  ZONE_CREATION_FAILED: 'ZONE_CREATION_FAILED',
  ZONE_UPDATE_FAILED: 'ZONE_UPDATE_FAILED',
  ZONE_DELETION_FAILED: 'ZONE_DELETION_FAILED',
  INVALID_NOTIFICATION_DATA: 'INVALID_NOTIFICATION_DATA',
  NOTIFICATION_NOT_FOUND: 'NOTIFICATION_NOT_FOUND',
  NOTIFICATION_CREATION_FAILED: 'NOTIFICATION_CREATION_FAILED',
  NOTIFICATION_UPDATE_FAILED: 'NOTIFICATION_UPDATE_FAILED',
  NOTIFICATION_DELETE_ERROR: 'NOTIFICATION_DELETE_ERROR',
  NOTIFICATION_SEND_ERROR: 'NOTIFICATION_SEND_ERROR',
  NOTIFICATION_CREATE_ERROR: 'NOTIFICATION_CREATE_ERROR',
  NOTIFICATION_FETCH_ERROR: 'NOTIFICATION_FETCH_ERROR',
  NOTIFICATION_UPDATE_ERROR: 'NOTIFICATION_UPDATE_ERROR',
  INVALID_LOYALTY_DATA: 'INVALID_LOYALTY_DATA',
  LOYALTY_NOT_FOUND: 'LOYALTY_NOT_FOUND',
  LOYALTY_CREATION_FAILED: 'LOYALTY_CREATION_FAILED',
  LOYALTY_UPDATE_FAILED: 'LOYALTY_UPDATE_FAILED',
  LOYALTY_DELETION_FAILED: 'LOYALTY_DELETION_FAILED',
  INVALID_ANALYTICS_DATA: 'INVALID_ANALYTICS_DATA',
  ANALYTICS_NOT_FOUND: 'ANALYTICS_NOT_FOUND',
  ANALYTICS_CREATION_FAILED: 'ANALYTICS_CREATION_FAILED',
  ANALYTICS_UPDATE_FAILED: 'ANALYTICS_UPDATE_FAILED',
  ANALYTICS_DELETION_FAILED: 'ANALYTICS_DELETION_FAILED',
  INVALID_ACTION: 'INVALID_ACTION',
  INVALID_DATE: 'INVALID_DATE',
  INVALID_ITEMS: 'INVALID_ITEMS',
  INVALID_PAGINATION: 'INVALID_PAGINATION',
  INVALID_RECURRING_ORDER_DATA: 'INVALID_RECURRING_ORDER_DATA',
  INVALID_FREQUENCY: 'INVALID_FREQUENCY',
  INVALID_BASE_ORDER: 'INVALID_BASE_ORDER',
  INVALID_ACTIVE_STATUS: 'INVALID_ACTIVE_STATUS',
  INVALID_INVOICE_DATA: 'INVALID_INVOICE_DATA',
  INVOICE_NOT_FOUND: 'INVOICE_NOT_FOUND',
  INVOICE_CREATION_FAILED: 'INVOICE_CREATION_FAILED',
  INVOICE_UPDATE_FAILED: 'INVOICE_UPDATE_FAILED',
  INVOICE_DELETION_FAILED: 'INVOICE_DELETION_FAILED',
  INVOICE_GENERATION_FAILED: 'INVOICE_GENERATION_FAILED',
  DELIVERY_PERSON_NOT_FOUND: 'DELIVERY_PERSON_NOT_FOUND',
  DELIVERY_PERSON_UNAVAILABLE: 'DELIVERY_PERSON_UNAVAILABLE',
  ZONE_ASSIGNMENT_FAILED: 'ZONE_ASSIGNMENT_FAILED',
  ZONE_STATS_FETCH_FAILED: 'ZONE_STATS_FETCH_FAILED',
  ZONES_FETCH_FAILED: 'ZONES_FETCH_FAILED',
  ZONE_HAS_ACTIVE_ORDERS: 'ZONE_HAS_ACTIVE_ORDERS',
  BILL_CREATION_FAILED: 'BILL_CREATION_FAILED',
  BILL_NOT_FOUND: 'BILL_NOT_FOUND',
  BILL_UPDATE_FAILED: 'BILL_UPDATE_FAILED',
  BILL_ALREADY_PAID: 'BILL_ALREADY_PAID',
  INSUFFICIENT_PAYMENT: 'INSUFFICIENT_PAYMENT',
  PAYMENT_PROCESSING_FAILED: 'PAYMENT_PROCESSING_FAILED',
  INVALID_REFUND_REQUEST: 'INVALID_REFUND_REQUEST',
  INVALID_REFUND_AMOUNT: 'INVALID_REFUND_AMOUNT',
  REFUND_PROCESSING_FAILED: 'REFUND_PROCESSING_FAILED',
  LOYALTY_POINTS_UPDATE_FAILED: 'LOYALTY_POINTS_UPDATE_FAILED',
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  REWARD_NOT_FOUND: 'REWARD_NOT_FOUND',
  INSUFFICIENT_POINTS: 'INSUFFICIENT_POINTS',
  SUBSCRIPTION_PLAN_NOT_FOUND: 'SUBSCRIPTION_PLAN_NOT_FOUND',
  BILL_FETCH_FAILED: 'BILL_FETCH_FAILED',
  BILLING_STATS_FETCH_FAILED: 'BILLING_STATS_FETCH_FAILED',
  INVALID_ID: 'INVALID_ID',
  INVALID_URL: 'INVALID_URL',
  INVALID_LANGUAGE: 'INVALID_LANGUAGE',
  INVALID_ADDRESS_DATA: 'INVALID_ADDRESS_DATA',
  INVALID_LOCATION: 'INVALID_LOCATION',
  INVALID_USER_DATA: 'INVALID_USER_DATA',
  INVALID_ACCOUNT_CREATION_METHOD: 'INVALID_ACCOUNT_CREATION_METHOD',
  INVALID_PASSWORD_DATA: 'INVALID_PASSWORD_DATA',
  INVALID_COORDINATES: 'INVALID_COORDINATES',
  INVALID_CARD_NUMBER: 'INVALID_CARD_NUMBER',
  INVALID_EXPIRY_DATE: 'INVALID_EXPIRY_DATE',
  INVALID_CVV: 'INVALID_CVV',
  INVALID_AMOUNT: 'INVALID_AMOUNT',
  INVALID_REFUND_DATA: 'INVALID_REFUND_DATA',
  INVALID_REWARD_DATA: 'INVALID_REWARD_DATA',
  INVALID_POINTS_REQUIRED: 'INVALID_POINTS_REQUIRED',
  INVALID_DISCOUNT_AMOUNT: 'INVALID_DISCOUNT_AMOUNT',
  INVALID_POINTS_PER_EURO: 'INVALID_POINTS_PER_EURO',
  INVALID_WELCOME_POINTS: 'INVALID_WELCOME_POINTS',
  INVALID_REFERRAL_POINTS: 'INVALID_REFERRAL_POINTS',
  INVALID_POINTS: 'INVALID_POINTS',
  INVALID_REASON: 'INVALID_REASON',
  INVALID_RATING: 'INVALID_RATING',
  ORDER_FETCH_FAILED: 'ORDER_FETCH_FAILED',
  ORDER_CANCELLATION_FAILED: 'ORDER_CANCELLATION_FAILED',
  ORDER_HISTORY_FETCH_FAILED: 'ORDER_HISTORY_FETCH_FAILED',
  ORDER_ALREADY_RATED: 'ORDER_ALREADY_RATED',
  ORDER_RATING_FAILED: 'ORDER_RATING_FAILED',
  INVALID_REQUEST: 'INVALID_REQUEST',
  AFFILIATE_FETCH_FAILED: 'AFFILIATE_FETCH_FAILED',
  WITHDRAWAL_PROCESSING_FAILED: 'WITHDRAWAL_PROCESSING_FAILED',
  AFFILIATE_STATS_FETCH_FAILED: 'AFFILIATE_STATS_FETCH_FAILED',
  WITHDRAWAL_HISTORY_FETCH_FAILED: 'WITHDRAWAL_HISTORY_FETCH_FAILED',
  PENDING_WITHDRAWALS_FETCH_FAILED: 'PENDING_WITHDRAWALS_FETCH_FAILED',
  INVALID_RESOURCE: 'INVALID_RESOURCE',
  INVALID_JSON: 'INVALID_JSON',
  FORBIDDEN_ORIGIN: 'FORBIDDEN_ORIGIN',
  METHOD_NOT_ALLOWED: 'METHOD_NOT_ALLOWED',
  INVALID_PRICE_RANGE: 'INVALID_PRICE_RANGE',
  INVALID_SERVICE: 'INVALID_SERVICE',
  COMMISSION_NOT_FOUND: 'COMMISSION_NOT_FOUND',
  INVALID_COMMISSION_STATUS: 'INVALID_COMMISSION_STATUS',
  COMMISSION_RULE_NOT_FOUND: 'COMMISSION_RULE_NOT_FOUND',
  PAYMENT_METHOD_REQUIRED: 'PAYMENT_METHOD_REQUIRED',
  PAYMENT_METHOD_MISSING: 'PAYMENT_METHOD_MISSING',
  PUSH_NOTIFICATION_ERROR: 'PUSH_NOTIFICATION_ERROR',
  SLOT_NOT_AVAILABLE: 'SLOT_NOT_AVAILABLE',
  ONE_CLICK_ORDER_FAILED: 'ONE_CLICK_ORDER_FAILED',
  INVALID_USER_PROFILE: 'INVALID_USER_PROFILE',
  ROUTE_GENERATION_FAILED: 'ROUTE_GENERATION_FAILED',
  STATS_FETCH_FAILED: 'STATS_FETCH_FAILED',
  REFERRAL_ALREADY_EXISTS: 'REFERRAL_ALREADY_EXISTS',
  INVALID_REFERRAL_CODE: 'INVALID_REFERRAL_CODE',
  REFERRAL_NOT_FOUND: 'REFERRAL_NOT_FOUND',
  REWARD_ALREADY_PROCESSED: 'REWARD_ALREADY_PROCESSED',
  NO_ACTIVE_PROGRAM: 'NO_ACTIVE_PROGRAM',
  ADMIN_ALREADY_IN_TEAM: 'ADMIN_ALREADY_IN_TEAM',
  ADMIN_NOT_IN_TEAM: 'ADMIN_NOT_IN_TEAM',
  PASSWORD_HASH_ERROR: 'PASSWORD_HASH_ERROR',
  PASSWORD_COMPARE_ERROR: 'PASSWORD_COMPARE_ERROR',
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  AI_INITIALIZATION_ERROR: 'AI_INITIALIZATION_ERROR',
  AI_PARSING_ERROR: 'AI_PARSING_ERROR',
  AI_INVALID_RESPONSE: 'AI_INVALID_RESPONSE',
  AI_GENERATION_ERROR: 'AI_GENERATION_ERROR',
  INVALID_PAID_DATE: 'INVALID_PAID_DATE',
  INVALID_DATE_RANGE: 'INVALID_DATE_RANGE',
  INVALID_PAGE_NUMBER: 'INVALID_PAGE_NUMBER',
  INVALID_PAGE_SIZE: 'INVALID_PAGE_SIZE',
  INVALID_SORT_BY: 'INVALID_SORT_BY',
  INVALID_SORT_ORDER: 'INVALID_SORT_ORDER',
  INVALID_INVOICE_ID: 'INVALID_INVOICE_ID',
  INVALID_TRANSACTION_ID: 'INVALID_TRANSACTION_ID',
  INVALID_NOTES: 'INVALID_NOTES'
};
