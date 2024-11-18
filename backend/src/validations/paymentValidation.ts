import { z } from 'zod';

const paymentMethodSchema = z.object({
  type: z.enum(['CARD', 'BANK_ACCOUNT']),
  token: z.string(),
  isDefault: z.boolean().optional(),
});

const processPaymentSchema = z.object({
  orderId: z.string(),
  amount: z.number().positive(),
  currency: z.enum(['USD', 'EUR', 'GBP']),
  paymentMethodId: z.string(),
  description: z.string().optional(),
});

const refundSchema = z.object({
  paymentId: z.string(),
  amount: z.number().positive().optional(),
  reason: z.enum(['REQUESTED_BY_CUSTOMER', 'DUPLICATE', 'FRAUDULENT']).optional(),
});

const paymentHistoryQuerySchema = z.object({
  page: z.number().int().positive().optional().default(1),
  limit: z.number().int().positive().max(100).optional().default(10),
  status: z.enum(['SUCCEEDED', 'PENDING', 'FAILED']).optional(),
});

export const paymentValidation = {
  addPaymentMethod: paymentMethodSchema,
  removePaymentMethod: z.object({
    id: z.string(),
  }),
  setDefaultPaymentMethod: z.object({
    id: z.string(),
  }),
  processPayment: processPaymentSchema,
  processRefund: refundSchema,
  getPaymentHistory: paymentHistoryQuerySchema,
};
