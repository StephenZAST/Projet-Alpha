export const errorCodes = {
  // Erreurs générales
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
  
  // Erreurs liées aux articles
  ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
  INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
  INVALID_PRICE_RANGE: 'INVALID_PRICE_RANGE',
  
  // Erreurs liées aux utilisateurs
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  USER_ALREADY_EXISTS: 'USER_ALREADY_EXISTS',
  INVALID_USER_DATA: 'INVALID_USER_DATA',
  INVALID_USER_PROFILE: 'INVALID_USER_PROFILE',
  
  // Erreurs liées aux commandes
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
  
  // Erreurs liées à la facturation
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
  
  // Erreurs liées aux points de fidélité
  LOYALTY_POINTS_UPDATE_FAILED: 'LOYALTY_POINTS_UPDATE_FAILED',
  INSUFFICIENT_POINTS: 'INSUFFICIENT_POINTS',
  REWARD_NOT_FOUND: 'REWARD_NOT_FOUND',
  
  // Erreurs liées aux abonnements
  SUBSCRIPTION_NOT_FOUND: 'SUBSCRIPTION_NOT_FOUND',
  SUBSCRIPTION_PLAN_NOT_FOUND: 'SUBSCRIPTION_PLAN_NOT_FOUND',
  SUBSCRIPTION_UPDATE_FAILED: 'SUBSCRIPTION_UPDATE_FAILED',
  SUBSCRIPTION_FETCH_FAILED: 'SUBSCRIPTION_FETCH_FAILED',
  SUBSCRIPTION_CANCELLATION_FAILED: 'SUBSCRIPTION_CANCELLATION_FAILED',
  SUBSCRIPTION_RENEWAL_FAILED: 'SUBSCRIPTION_RENEWAL_FAILED',
  SUBSCRIPTION_PAYMENT_FAILED: 'SUBSCRIPTION_PAYMENT_FAILED',
  
  // Erreurs liées aux zones
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
  
  // Erreurs liées aux livreurs
  DELIVERY_PERSON_NOT_FOUND: 'DELIVERY_PERSON_NOT_FOUND',
  DELIVERY_PERSON_UNAVAILABLE: 'DELIVERY_PERSON_UNAVAILABLE',
  DELIVERY_PERSON_ASSIGNMENT_FAILED: 'DELIVERY_PERSON_ASSIGNMENT_FAILED',
  
  // Erreurs liées aux adresses
  ADDRESS_NOT_FOUND: 'ADDRESS_NOT_FOUND',
  INVALID_ADDRESS_DATA: 'INVALID_ADDRESS_DATA',
  GEOCODING_FAILED: 'GEOCODING_FAILED'
} as const;

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code: keyof typeof errorCodes
  ) {
    super(message);
    this.name = 'AppError';
  }
}
