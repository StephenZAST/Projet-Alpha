import Joi from 'joi';

const paymentMethodSchema = Joi.object({
  type: Joi.string().valid('CARD', 'BANK_ACCOUNT').required(),
  token: Joi.string().required(),
  isDefault: Joi.boolean().optional(),
});

const processPaymentSchema = Joi.object({
  orderId: Joi.string().required(),
  amount: Joi.number().positive().required(),
  currency: Joi.string().valid('USD', 'EUR', 'GBP').required(),
  paymentMethodId: Joi.string().required(),
  description: Joi.string().optional(),
});

const refundSchema = Joi.object({
  paymentId: Joi.string().required(),
  amount: Joi.number().positive().optional(),
  reason: Joi.string().valid('REQUESTED_BY_CUSTOMER', 'DUPLICATE', 'FRAUDULENT').optional(),
});

const paymentHistoryQuerySchema = Joi.object({
  page: Joi.number().integer().positive().optional().default(1),
  limit: Joi.number().integer().positive().max(100).optional().default(10),
  status: Joi.string().valid('SUCCEEDED', 'PENDING', 'FAILED').optional(),
});

export const paymentValidation = {
  addPaymentMethod: paymentMethodSchema,
  removePaymentMethod: Joi.object({
    id: Joi.string().required(),
  }),
  setDefaultPaymentMethod: Joi.object({
    id: Joi.string().required(),
  }),
  processPayment: processPaymentSchema,
  processRefund: refundSchema,
  getPaymentHistory: paymentHistoryQuerySchema,
};
