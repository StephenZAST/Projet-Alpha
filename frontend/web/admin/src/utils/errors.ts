import { AxiosResponse } from 'axios';

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
  BILLING_STATS_FETCH_FAILED: 'BILLING_STATS_FETCH_FAILED',

  // Admin-related errors
  ADMIN_NOT_FOUND: 'ADMIN_NOT_FOUND',
  ADMIN_ALREADY_EXISTS: 'ADMIN_ALREADY_EXISTS',
  INVALID_ADMIN_DATA: 'INVALID_ADMIN_DATA',
  INVALID_ADMIN_ROLE: 'INVALID_ADMIN_ROLE',
  ADMIN_CREATION_FAILED: 'ADMIN_CREATION_FAILED',
  ADMIN_UPDATE_FAILED: 'ADMIN_UPDATE_FAILED',
  ADMIN_DELETE_FAILED: 'ADMIN_DELETE_FAILED',
  ADMIN_NOT_IN_TEAM: 'ADMIN_NOT_IN_TEAM',

  // Loyalty-related errors
  LOYALTY_POINTS_UPDATE_FAILED: 'LOYALTY_POINTS_UPDATE_FAILED',
  INSUFFICIENT_POINTS: 'INSUFFICIENT_POINTS',
  REWARD_NOT_FOUND: 'REWARD_NOT_FOUND',
  REWARD_ALREADY_CLAIMED: 'REWARD_ALREADY_CLAIMED',
  REWARD_EXPIRED: 'REWARD_EXPIRED',

  // Commission-related errors
  COMMISSION_NOT_FOUND: 'COMMISSION_NOT_FOUND',
  INVALID_COMMISSION_STATUS: 'INVALID_COMMISSION_STATUS',
  COMMISSION_ALREADY_PROCESSED: 'COMMISSION_ALREADY_PROCESSED',

  // Authentication-related errors
  GOOGLE_AUTH_FAILED: 'GOOGLE_AUTH_FAILED',

  // Internal Server Error
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',

  // Network Error
  NETWORK_ERROR: 'NETWORK_ERROR',

  // Unexpected Error
  UNEXPECTED_ERROR: 'UNEXPECTED_ERROR'
} as const;

export type ErrorCode = keyof typeof errorCodes;

export class AppError extends Error {
  constructor(
    public readonly message: string,
    public readonly statusCode: number,
    public readonly code: ErrorCode = 'INTERNAL_SERVER_ERROR'
  ) {
    super(message);
    this.name = 'AppError';
  }

  static fromAxiosError(error: unknown): AppError {
    if (error instanceof Error) {
      if ('response' in error && error.response) {
        const response = error.response as AxiosResponse;
        const { message, statusCode, code } = response.data || {};
        return new AppError(
          message || 'An unexpected error occurred',
          statusCode || 500,
          code || 'INTERNAL_SERVER_ERROR'
        );
      }
      return new AppError(
        error.message || 'Network error occurred',
        500,
        'DATABASE_ERROR'
      );
    }
    return new AppError(
      'Unknown error occurred',
      500,
      'INTERNAL_SERVER_ERROR'
    );
  }
}
