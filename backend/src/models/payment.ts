import { AppError, errorCodes } from '../utils/errors';

export type PaymentMethodType = 'CARD' | 'BANK_ACCOUNT';
export type PaymentStatus = 'SUCCEEDED' | 'PENDING' | 'FAILED' | 'REFUNDED';
export type RefundReason = 'REQUESTED_BY_CUSTOMER' | 'DUPLICATE' | 'FRAUDULENT';
export type Currency = 'USD' | 'EUR' | 'GBP';

export interface PaymentMethod {
  id?: string;
  userId: string;
  type: PaymentMethodType;
  token: string;
  last4?: string;
  brand?: string;
  expiryMonth?: number;
  expiryYear?: number;
  isDefault: boolean;
  createdAt?: string;
}

export interface Payment {
  error: any;
  data: any;
  id?: string;
  userId: string;
  orderId: string;
  amount: number;
  currency: Currency;
  paymentMethodId: string;
  status: PaymentStatus;
  description?: string;
  createdAt?: string;
}

export interface Refund {
  data: any;
  error: any;
  id?: string;
  userId: string;
  paymentId: string;
  amount: number;
  reason?: RefundReason;
  status: PaymentStatus;
  createdAt?: string;
}
