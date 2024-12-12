import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export type PaymentMethodType = 'CARD' | 'BANK_ACCOUNT';
export type PaymentStatus = 'SUCCEEDED' | 'PENDING' | 'FAILED' | 'REFUNDED';
export type RefundReason = 'REQUESTED_BY_CUSTOMER' | 'DUPLICATE' | 'FRAUDULENT';
export type Currency = 'USD' | 'EUR' | 'GBP';

export interface PaymentMethod {
  id: string;
  userId: string;
  type: PaymentMethodType;
  token: string;
  last4?: string;
  brand?: string;
  expiryMonth?: number;
  expiryYear?: number;
  isDefault: boolean;
  createdAt: string;
}

export interface Payment {
  id: string;
  userId: string;
  orderId: string;
  amount: number;
  currency: Currency;
  paymentMethodId: string;
  status: PaymentStatus;
  description?: string;
  createdAt: string;
}

export interface Refund {
  id: string;
  userId: string;
  paymentId: string;
  amount: number;
  reason?: RefundReason;
  status: PaymentStatus;
  createdAt: string;
}

// Use Supabase to store payment method data
const paymentMethodsTable = 'paymentMethods';

// Function to get payment method data
export async function getPaymentMethod(id: string): Promise<PaymentMethod | null> {
  const { data, error } = await supabase.from(paymentMethodsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch payment method', 'INTERNAL_SERVER_ERROR');
  }

  return data as PaymentMethod;
}

// Function to create payment method
export async function createPaymentMethod(methodData: PaymentMethod): Promise<PaymentMethod> {
  const { data, error } = await supabase.from(paymentMethodsTable).insert([methodData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create payment method', 'INTERNAL_SERVER_ERROR');
  }

  return data as PaymentMethod;
}

// Function to update payment method
export async function updatePaymentMethod(id: string, methodData: Partial<PaymentMethod>): Promise<PaymentMethod> {
  const currentMethod = await getPaymentMethod(id);

  if (!currentMethod) {
    throw new AppError(404, 'Payment method not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(paymentMethodsTable).update(methodData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update payment method', 'INTERNAL_SERVER_ERROR');
  }

  return data as PaymentMethod;
}

// Function to delete payment method
export async function deletePaymentMethod(id: string): Promise<void> {
  const method = await getPaymentMethod(id);

  if (!method) {
    throw new AppError(404, 'Payment method not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(paymentMethodsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete payment method', 'INTERNAL_SERVER_ERROR');
  }
}

// Use Supabase to store payment data
const paymentsTable = 'payments';

// Function to get payment data
export async function getPayment(id: string): Promise<Payment | null> {
  const { data, error } = await supabase.from(paymentsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch payment', 'INTERNAL_SERVER_ERROR');
  }

  return data as Payment;
}

// Function to create payment
export async function createPayment(paymentData: Payment): Promise<Payment> {
  const { data, error } = await supabase.from(paymentsTable).insert([paymentData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create payment', 'INTERNAL_SERVER_ERROR');
  }

  return data as Payment;
}

// Function to update payment
export async function updatePayment(id: string, paymentData: Partial<Payment>): Promise<Payment> {
  const currentPayment = await getPayment(id);

  if (!currentPayment) {
    throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(paymentsTable).update(paymentData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update payment', 'INTERNAL_SERVER_ERROR');
  }

  return data as Payment;
}

// Function to delete payment
export async function deletePayment(id: string): Promise<void> {
  const payment = await getPayment(id);

  if (!payment) {
    throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(paymentsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete payment', 'INTERNAL_SERVER_ERROR');
  }
}

// Use Supabase to store refund data
const refundsTable = 'refunds';

// Function to get refund data
export async function getRefund(id: string): Promise<Refund | null> {
  const { data, error } = await supabase.from(refundsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch refund', 'INTERNAL_SERVER_ERROR');
  }

  return data as Refund;
}

// Function to create refund
export async function createRefund(refundData: Refund): Promise<Refund> {
  const { data, error } = await supabase.from(refundsTable).insert([refundData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create refund', 'INTERNAL_SERVER_ERROR');
  }

  return data as Refund;
}

// Function to update refund
export async function updateRefund(id: string, refundData: Partial<Refund>): Promise<Refund> {
  const currentRefund = await getRefund(id);

  if (!currentRefund) {
    throw new AppError(404, 'Refund not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(refundsTable).update(refundData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update refund', 'INTERNAL_SERVER_ERROR');
  }

  return data as Refund;
}

// Function to delete refund
export async function deleteRefund(id: string): Promise<void> {
  const refund = await getRefund(id);

  if (!refund) {
    throw new AppError(404, 'Refund not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(refundsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete refund', 'INTERNAL_SERVER_ERROR');
  }
}
