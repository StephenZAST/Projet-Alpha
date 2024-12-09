import { z } from 'zod';

// Schema for getting payment methods
export const getPaymentMethodsSchema = z.object({
  // No specific validation needed for this route
});

// Schema for adding a payment method
export const addPaymentMethodSchema = z.object({
  body: z.object({
    paymentMethodId: z.string().min(1, 'Payment method ID is required'),
    cardNumber: z.string().regex(/^\d{16}$/, 'Invalid card number'),
    expiryDate: z.string().regex(/^(0[1-9]|1[0-2])\/\d{2}$/, 'Invalid expiry date'),
    cvv: z.string().regex(/^\d{3,4}$/, 'Invalid CVV'),
  }),
});

// Schema for removing a payment method
export const removePaymentMethodSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Payment method ID is required'),
  }),
});

// Schema for setting a default payment method
export const setDefaultPaymentMethodSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Payment method ID is required'),
  }),
});

// Schema for processing a payment
export const processPaymentSchema = z.object({
  body: z.object({
    amount: z.number().positive('Amount must be positive'),
    currency: z.string().min(1, 'Currency is required'),
    paymentMethodId: z.string().min(1, 'Payment method ID is required'),
  }),
});

// Schema for processing a refund
export const processRefundSchema = z.object({
  body: z.object({
    paymentId: z.string().min(1, 'Payment ID is required'),
    amount: z.number().positive('Amount must be positive'),
    reason: z.string().min(1, 'Reason is required'),
  }),
});

// Schema for getting payment history
export const getPaymentHistorySchema = z.object({
  query: z.object({
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).optional(),
    status: z.string().optional(),
  }),
});
